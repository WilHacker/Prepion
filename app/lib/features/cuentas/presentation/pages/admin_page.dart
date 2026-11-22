import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/cuentas/domain/cuenta.dart';
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
    final usuarios = ref.watch(usuariosAdminProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        actions: <Widget>[
          IconButton(
            key: const Key('boton_actualizar_usuarios'),
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(usuariosAdminProvider),
          ),
          IconButton(
            key: const Key('boton_salir_admin'),
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(sesionProvider.notifier).cerrarSesion();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: usuarios.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error is ErrorCuentas
                  ? error.mensaje
                  : 'No se pudo cargar la lista.',
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
      ),
    );
  }

  static String _fecha(DateTime f) {
    final local = f.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }
}
