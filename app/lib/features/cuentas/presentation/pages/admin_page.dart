import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';
import 'package:prepion/features/cuentas/domain/cuenta.dart';
import 'package:prepion/features/cuentas/presentation/pages/examen_admin_preguntas_page.dart';
import 'package:prepion/features/cuentas/presentation/providers/cuentas_provider.dart';

/// Panel del administrador: todos los usuarios registrados y su actividad.
class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sesion = ref.watch(sesionProvider);
    final cuenta = sesion.asData?.value;
    if (sesion.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (cuenta == null || !cuenta.esAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Administración')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Esta sección es solo para administradores.',
                  key: Key('texto_acceso_restringido'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/iniciar-sesion'),
                  child: const Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administración'),
          actions: <Widget>[
            IconButton(
              key: const Key('boton_actualizar_usuarios'),
              tooltip: 'Actualizar',
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref
                  ..invalidate(usuariosAdminProvider)
                  ..invalidate(examenesAdminProvider)
                  ..invalidate(resumenAdminProvider);
              },
            ),
            IconButton(
              key: const Key('boton_salir_admin'),
              tooltip: 'Cerrar sesión',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(sesionProvider.notifier).cerrarSesion();
                if (context.mounted) {
                  context.go('/');
                }
              },
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(key: Key('pestana_usuarios'), text: 'Usuarios'),
              Tab(key: Key('pestana_examenes'), text: 'Exámenes'),
              Tab(key: Key('pestana_modelo'), text: 'Modelo'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[_Usuarios(), _Examenes(), _Modelo()],
        ),
      ),
    );
  }
}

String _mensajeError(Object error) =>
    error is ErrorCuentas ? error.mensaje : 'No se pudo cargar la información.';

void _avisar(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
}

class _Usuarios extends ConsumerWidget {
  const _Usuarios();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(usuariosAdminProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _mensajeError(error),
                key: const Key('error_usuarios'),
              ),
            ),
          ),
          data: (lista) => ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Usuarios registrados: ${lista.length}',
                  key: const Key('total_usuarios'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final u in lista)
                ListTile(
                  key: Key('usuario_${u.id}'),
                  leading: Icon(
                    u.esAdmin ? Icons.admin_panel_settings : Icons.person,
                  ),
                  title: Text(u.correo ?? 'Anónimo'),
                  subtitle: Text(
                    '${u.esAdmin ? 'Administrador' : 'Postulante'} · '
                    '${u.respuestas} respuestas · alta ${_fecha(u.creadoEn)}',
                  ),
                ),
            ],
          ),
        );
  }
}

class _Examenes extends ConsumerStatefulWidget {
  const _Examenes();

  @override
  ConsumerState<_Examenes> createState() => _ExamenesState();
}

class _ExamenesState extends ConsumerState<_Examenes> {
  bool _buscando = false;

  Future<void> _recolectar() async {
    setState(() => _buscando = true);
    try {
      final repo = await ref.read(repositorioCuentasProvider.future);
      final nuevos = await repo.recolectarExamenes();
      ref.invalidate(examenesAdminProvider);
      if (mounted) _avisar(context, 'Exámenes nuevos descargados: $nuevos');
    } on ErrorCuentas catch (error) {
      if (mounted) _avisar(context, error.mensaje);
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  static Color _color(String veredicto) => switch (veredicto) {
    'curable' => ColoresPrepion.exito,
    'revisar' => ColoresPrepion.ambar,
    _ => Colors.red.shade700,
  };

  static String _etiqueta(String veredicto) => switch (veredicto) {
    'curable' => 'Se puede curar',
    'revisar' => 'Revisar a mano',
    _ => 'No se puede curar',
  };

  @override
  Widget build(BuildContext context) {
    final examenes = ref.watch(examenesAdminProvider);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('boton_recolectar'),
              onPressed: _buscando ? null : _recolectar,
              icon: const Icon(Icons.cloud_download_outlined),
              label: Text(
                _buscando
                    ? 'Buscando en el portal...'
                    : 'Buscar exámenes nuevos',
              ),
            ),
          ),
        ),
        Expanded(
          child: examenes.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(
                _mensajeError(error),
                key: const Key('error_examenes'),
              ),
            ),
            data: (lista) => ListView(
              children: <Widget>[
                for (final e in lista)
                  ListTile(
                    key: Key('examen_${e.archivo}'),
                    title: Text(e.archivo),
                    subtitle: Text(
                      '${e.preguntas} preguntas · ${e.paginas} págs.\n${e.motivo}'
                      '${e.esCurable ? '\nToca para ver preguntas y cargar al banco' : ''}',
                    ),
                    isThreeLine: true,
                    onTap: e.esCurable
                        ? () => Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ExamenAdminPreguntasPage(archivo: e.archivo),
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          _etiqueta(e.veredicto),
                          style: TextStyle(
                            color: _color(e.veredicto),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (e.esCurable) const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Modelo extends ConsumerStatefulWidget {
  const _Modelo();

  @override
  ConsumerState<_Modelo> createState() => _ModeloState();
}

class _ModeloState extends ConsumerState<_Modelo> {
  bool _calibrando = false;

  Future<void> _recalibrar() async {
    setState(() => _calibrando = true);
    try {
      final repo = await ref.read(repositorioCuentasProvider.future);
      final version = await repo.recalibrar();
      ref.invalidate(resumenAdminProvider);
      if (mounted) {
        _avisar(context, 'Modelo recalibrado: paquete versión $version');
      }
    } on ErrorCuentas catch (error) {
      if (mounted) _avisar(context, error.mensaje);
    } finally {
      if (mounted) setState(() => _calibrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumen = ref.watch(resumenAdminProvider);
    return resumen.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(_mensajeError(error), key: const Key('error_modelo')),
      ),
      data: (r) => ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _Dato('Usuarios', '${r.usuarios}'),
          _Dato('Respuestas reales', '${r.respuestas}'),
          _Dato('Preguntas publicadas', '${r.preguntasPublicadas}'),
          _Dato('Exámenes descargados', '${r.examenesDescargados}'),
          _Dato(
            'Banco publicado',
            r.bancoVersion == null ? '—' : 'v${r.bancoVersion}',
          ),
          _Dato(
            'Modelo (paquete)',
            r.paqueteVersion == null
                ? '—'
                : 'v${r.paqueteVersion} · ${r.paqueteOrigen ?? 'sin dato'}',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('boton_recalibrar'),
            onPressed: _calibrando ? null : _recalibrar,
            icon: const Icon(Icons.model_training),
            label: Text(
              _calibrando ? 'Recalibrando...' : 'Recalibrar modelo ahora',
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(etiqueta),
      trailing: Text(
        valor,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

String _fecha(DateTime f) {
  final local = f.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/${local.year}';
}
