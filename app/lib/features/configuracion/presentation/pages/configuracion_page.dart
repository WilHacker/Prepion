import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';
import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:prepion/features/configuracion/presentation/widgets/selector_metas_card.dart';
import 'package:prepion/features/configuracion/presentation/widgets/tarjeta_apariencia.dart';
import 'package:prepion/shared/notifications/notificaciones_servicio.dart';

/// Pantalla de ajustes para modificar metas de estudio y recordatorios diarios.
class ConfiguracionPage extends ConsumerStatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  ConsumerState<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends ConsumerState<ConfiguracionPage> {
  DateTime? _fechaExamen;
  int? _metaDiaria;
  TimeOfDay? _horaEstudio;
  bool? _recordatorioActivo;
  bool _sincronizadoConPreferencias = false;
  bool _permisoDenegado = false;
  bool _guardando = false;

  void _inicializarDesde(
    PreferenciasEstudio? preferencias,
    ParametrosPublicos parametros,
  ) {
    if (preferencias != null && !_sincronizadoConPreferencias) {
      _fechaExamen = preferencias.fechaExamen;
      _metaDiaria = preferencias.metaDiaria;
      _horaEstudio = TimeOfDay(
        hour: preferencias.horaEstudio,
        minute: preferencias.minutoEstudio,
      );
      _recordatorioActivo = preferencias.recordatorioActivo;
      _sincronizadoConPreferencias = true;
      return;
    }
    if (_fechaExamen != null) {
      return;
    }
    final (hora, minuto) = parametros.horaEstudioRecomendada;
    _fechaExamen = parametros.fechaExamenRecomendada;
    _metaDiaria = parametros.metaDiariaSugerida;
    _horaEstudio = TimeOfDay(hour: hora, minute: minuto);
    _recordatorioActivo = true;
  }

  Future<void> _cambiarRecordatorioActivo(bool activar) async {
    if (activar) {
      final concedido = await ref
          .read(notificacionesServicioProvider)
          .solicitarPermiso();
      if (!mounted) {
        return;
      }
      setState(() {
        _recordatorioActivo = concedido;
        _permisoDenegado = !concedido;
      });
      if (!concedido) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Activa el permiso de notificaciones en los ajustes de tu teléfono.',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _recordatorioActivo = false;
      _permisoDenegado = false;
    });
  }

  Future<void> _seleccionarHoraRecordatorio(TimeOfDay horaActual) async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: horaActual,
      helpText: 'Hora del recordatorio diario',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (elegida != null && mounted) {
      setState(() => _horaEstudio = elegida);
    }
  }

  Future<void> _guardarCambios() async {
    if (_guardando ||
        _fechaExamen == null ||
        _metaDiaria == null ||
        _horaEstudio == null ||
        _recordatorioActivo == null) {
      return;
    }
    setState(() => _guardando = true);
    try {
      await ref
          .read(preferenciasEstudioProvider.notifier)
          .actualizarMetas(
            fechaExamen: _fechaExamen!,
            metaDiaria: _metaDiaria!,
            horaEstudio: _horaEstudio!.hour,
            minutoEstudio: _horaEstudio!.minute,
            recordatorioActivo: _recordatorioActivo,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Preferencias guardadas')));
        if (context.canPop()) {
          context.pop();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferenciasAsync = ref.watch(preferenciasEstudioProvider);
    final parametros =
        ref.watch(parametrosPublicosProvider).asData?.value ??
        ParametrosPublicos.porDefecto();

    final preferencias = preferenciasAsync.asData?.value;
    _inicializarDesde(preferencias, parametros);

    final fecha = _fechaExamen ?? parametros.fechaExamenRecomendada;
    final meta = _metaDiaria ?? parametros.metaDiariaSugerida;
    final hora =
        _horaEstudio ??
        const TimeOfDay(
          hour: horaEstudioPorDefecto,
          minute: minutoEstudioPorDefecto,
        );
    final recordatorioActivo = _recordatorioActivo ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de estudio')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            const TarjetaApariencia(),
            const SizedBox(height: 16),
            SelectorMetasCard(
              fechaExamen: fecha,
              metaDiaria: meta,
              horaEstudio: hora,
              opcionesMeta: parametros.metasDiariasOpciones,
              fechasSugeridas: parametros.fechasTentativasExamen,
              onCambiarFecha: (nueva) => setState(() => _fechaExamen = nueva),
              onCambiarMeta: (nueva) => setState(() => _metaDiaria = nueva),
              onCambiarHora: (nueva) => setState(() => _horaEstudio = nueva),
            ),
            const SizedBox(height: 16),
            _TarjetaRecordatorioDiario(
              activo: recordatorioActivo,
              hora: hora,
              permisoDenegado: _permisoDenegado,
              onCambiarActivo: _cambiarRecordatorioActivo,
              onElegirHora: () => _seleccionarHoraRecordatorio(hora),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.tokens.superficie,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.tokens.borde),
              ),
              child: Row(
                children: <Widget>[
                  Icon(Icons.shield_outlined, color: context.tokens.azul),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Modo anónimo local activo. Tus preferencias se guardan en este dispositivo sin exigir correo ni carnet.',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.tokens.textoSecundario,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('boton_guardar_ajustes'),
              onPressed: _guardando ? null : _guardarCambios,
              child: Text(_guardando ? 'Guardando...' : 'Guardar cambios'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key('boton_ver_bienvenida'),
              onPressed: _guardando ? null : () => context.push('/onboarding'),
              icon: const Icon(Icons.auto_stories_outlined),
              label: const Text('Ver pantalla de bienvenida'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaRecordatorioDiario extends StatelessWidget {
  const _TarjetaRecordatorioDiario({
    required this.activo,
    required this.hora,
    required this.permisoDenegado,
    required this.onCambiarActivo,
    required this.onElegirHora,
  });

  final bool activo;
  final TimeOfDay hora;
  final bool permisoDenegado;
  final ValueChanged<bool> onCambiarActivo;
  final VoidCallback onElegirHora;

  @override
  Widget build(BuildContext context) {
    final horaTexto = formatearHoraEstudio(hora.hour, hora.minute);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.tokens.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.tokens.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: activo
                      ? context.tokens.superficieHover
                      : context.tokens.fondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  activo
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_outlined,
                  color: activo
                      ? context.tokens.naranja
                      : context.tokens.textoSecundario,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Recordatorio diario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: context.tokens.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '100 % local, sin internet ni servidor.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: context.tokens.textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                key: const Key('switch_recordatorio_diario'),
                value: activo,
                activeTrackColor: ColoresPrepion.azulCielo,
                onChanged: onCambiarActivo,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activo
                ? 'Te avisaremos a las $horaTexto. Si ya completaste tu práctica del día, el aviso se omite automáticamente.'
                : 'Los recordatorios están pausados. Actívalos para mantener tu racha diaria.',
            style: TextStyle(
              fontSize: 13,
              color: context.tokens.textoSecundario,
              height: 1.35,
            ),
          ),
          if (permisoDenegado) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              'Permiso de notificaciones denegado en el sistema.',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: context.tokens.naranja,
              ),
            ),
          ],
          const SizedBox(height: 14),
          InkWell(
            key: const Key('selector_hora_recordatorio'),
            onTap: activo ? onElegirHora : null,
            borderRadius: BorderRadius.circular(14),
            child: Opacity(
              opacity: activo ? 1 : 0.5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: context.tokens.fondo,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.tokens.borde),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.alarm_rounded,
                      size: 20,
                      color: context.tokens.azul,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Hora del recordatorio',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.tokens.textoPrincipal,
                        ),
                      ),
                    ),
                    Text(
                      horaTexto,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: context.tokens.azul,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: context.tokens.textoSecundario,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
