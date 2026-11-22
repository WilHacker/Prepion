import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';
import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:prepion/features/configuracion/presentation/widgets/selector_metas_card.dart';

/// Pantalla de ajustes para modificar metas de estudio tras el onboarding.
class ConfiguracionPage extends ConsumerStatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  ConsumerState<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends ConsumerState<ConfiguracionPage> {
  DateTime? _fechaExamen;
  int? _metaDiaria;
  TimeOfDay? _horaEstudio;
  bool _guardando = false;

  void _inicializarDesde(
    PreferenciasEstudio? preferencias,
    ParametrosPublicos parametros,
  ) {
    if (_fechaExamen != null) {
      return;
    }
    if (preferencias != null) {
      _fechaExamen = preferencias.fechaExamen;
      _metaDiaria = preferencias.metaDiaria;
      _horaEstudio = TimeOfDay(
        hour: preferencias.horaEstudio,
        minute: preferencias.minutoEstudio,
      );
    } else {
      final (hora, minuto) = parametros.horaEstudioRecomendada;
      _fechaExamen = parametros.fechaExamenRecomendada;
      _metaDiaria = parametros.metaDiariaSugerida;
      _horaEstudio = TimeOfDay(hour: hora, minute: minuto);
    }
  }

  Future<void> _guardarCambios() async {
    if (_guardando ||
        _fechaExamen == null ||
        _metaDiaria == null ||
        _horaEstudio == null) {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de estudio')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColoresPrepion.superficie,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColoresPrepion.borde),
              ),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.shield_outlined, color: ColoresPrepion.azulMedio),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Modo anónimo local activo. Tus preferencias se guardan en este dispositivo sin exigir correo ni carnet.',
                      style: TextStyle(
                        fontSize: 13,
                        color: ColoresPrepion.textoSecundario,
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
