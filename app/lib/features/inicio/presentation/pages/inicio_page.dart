import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/boton_cuenta.dart';
import 'package:prepion/app/modo_tema_provider.dart';
import 'package:prepion/app/theme.dart';
import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:prepion/features/progreso/domain/resumen_hoy.dart';
import 'package:prepion/features/progreso/presentation/providers/resumen_hoy_provider.dart';
import 'package:prepion/shared/widgets/logo_prepion.dart';

/// Vista principal de estudio tras completar el onboarding.
class InicioPage extends ConsumerWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencias = ref.watch(preferenciasEstudioProvider).asData?.value;
    final fechas =
        ref
            .watch(parametrosPublicosProvider)
            .asData
            ?.value
            .fechasTentativasExamen ??
        const <FechaTentativaExamen>[];
    final resumen = ref.watch(resumenHoyProvider).asData?.value;
    final tipografia = Theme.of(context).textTheme;
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: <Widget>[
            const LogoPrepion(),
            const SizedBox(width: 10),
            Text(
              'Prepion',
              style: tipografia.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          _BotonBarra(
            key: const Key('boton_cambiar_tema'),
            tooltip: 'Cambiar tema',
            icono: esOscuro
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            onPressed: () => ref.read(modoTemaProvider.notifier).state =
                esOscuro ? ThemeMode.light : ThemeMode.dark,
          ),
          const SizedBox(width: 8),
          const BotonCuenta(),
          const SizedBox(width: 8),
          _BotonBarra(
            key: const Key('boton_ir_ajustes'),
            tooltip: 'Ajustes',
            icono: Icons.settings_rounded,
            onPressed: () => context.push('/ajustes'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: <Widget>[
            _TarjetaMeta(
              preferencias: preferencias,
              opcion: _opcionDe(preferencias, fechas),
              respondidasHoy: resumen?.respondidasHoy ?? 0,
            ),
            const SizedBox(height: 12),
            _FilaIndicadores(resumen: resumen, meta: preferencias?.metaDiaria),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('boton_practicar_hoy'),
              onPressed: () => context.push('/practica'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Practicar hoy'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('boton_practica_libre'),
              onPressed: () => context.push('/materias'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.tokens.naranja,
                side: BorderSide(color: context.tokens.naranja, width: 1.5),
              ),
              icon: const Icon(Icons.category_rounded),
              label: const Text('Práctica libre por materia'),
            ),
            const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: _TarjetaAcceso(
                      key: const Key('boton_ver_banco'),
                      icono: Icons.menu_book_rounded,
                      acento: context.tokens.dorado,
                      titulo: 'Ver banco de preguntas',
                      descripcion: 'Explora exámenes',
                      onTap: () => context.push('/banco'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TarjetaAcceso(
                      key: const Key('boton_ver_progreso'),
                      icono: Icons.insights_rounded,
                      acento: context.tokens.azul,
                      titulo: 'Mi progreso',
                      descripcion: 'Racha y dominio',
                      onTap: () => context.push('/progreso'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Icon(
                  Icons.offline_pin_rounded,
                  color: context.tokens.azul,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    preferencias != null
                        ? 'Tus preferencias y tu avance se guardan en tu dispositivo.'
                        : 'Configura tu meta diaria en Ajustes.',
                    style: tipografia.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// "2.ª opción" si la fecha elegida coincide con una fecha oficial tentativa.
  static String? _opcionDe(
    PreferenciasEstudio? preferencias,
    List<FechaTentativaExamen> fechas,
  ) {
    if (preferencias == null) return null;
    final elegida = preferencias.fechaExamen;
    for (final fecha in fechas) {
      if (DateUtils.isSameDay(fecha.fecha, elegida)) {
        return fecha.etiqueta.split(' · ').first;
      }
    }
    return null;
  }
}

class _BotonBarra extends StatelessWidget {
  const _BotonBarra({
    required this.tooltip,
    required this.icono,
    required this.onPressed,
    super.key,
  });

  final String tooltip;
  final IconData icono;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icono),
      style: IconButton.styleFrom(
        foregroundColor: tokens.textoPrincipal,
        backgroundColor: tokens.superficie,
        minimumSize: const Size(48, 48),
        side: BorderSide(color: tokens.borde),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _TarjetaMeta extends StatelessWidget {
  const _TarjetaMeta({
    required this.preferencias,
    required this.opcion,
    required this.respondidasHoy,
  });

  final PreferenciasEstudio? preferencias;
  final String? opcion;
  final int respondidasHoy;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tipografia = Theme.of(context).textTheme;
    final prefs = preferencias;
    final avance = prefs == null || prefs.metaDiaria == 0
        ? 0.0
        : (respondidasHoy / prefs.metaDiaria).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: tokens.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.hourglass_bottom_rounded,
                size: 18,
                color: tokens.dorado,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  prefs != null
                      ? 'Faltan ${prefs.diasRestantes()} días para tu examen'
                      : 'Listo para practicar',
                  style: tipografia.titleSmall?.copyWith(color: tokens.dorado),
                ),
              ),
              if (opcion case final opcion?)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ColoresPrepion.azulCielo.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    opcion,
                    style: tipografia.labelSmall?.copyWith(color: tokens.azul),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            prefs != null
                ? 'Meta de hoy: ${prefs.metaDiaria} preguntas'
                : 'Empieza tu sesión diaria',
            style: tipografia.headlineSmall,
          ),
          if (prefs != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              prefs.recordatorioActivo
                  ? 'Examen: ${prefs.fechaExamenFormateada} · Recordatorio: ${prefs.horaEstudioFormateada}'
                  : 'Examen: ${prefs.fechaExamenFormateada} · Recordatorio: desactivado',
              style: tipografia.bodySmall,
            ),
            const SizedBox(height: 14),
            Semantics(
              label: 'Avance de hoy: $respondidasHoy de ${prefs.metaDiaria}',
              excludeSemantics: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: avance, minHeight: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilaIndicadores extends StatelessWidget {
  const _FilaIndicadores({required this.resumen, required this.meta});

  final ResumenHoy? resumen;
  final int? meta;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final datos = resumen;
    final racha = datos?.racha ?? 0;
    final precision = datos?.precision;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _Indicador(
              icono: Icons.local_fire_department_rounded,
              acento: tokens.naranja,
              valor: racha == 1 ? '1 día' : '$racha días',
              etiqueta: 'Racha',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Indicador(
              icono: Icons.check_circle_rounded,
              acento: tokens.azul,
              valor: meta == null
                  ? '${datos?.respondidasHoy ?? 0}'
                  : '${datos?.respondidasHoy ?? 0} / $meta',
              etiqueta: 'Hoy',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Indicador(
              icono: Icons.track_changes_rounded,
              acento: tokens.dorado,
              valor: precision == null ? '—' : '${(precision * 100).round()}%',
              etiqueta: 'Precisión',
              descripcion: precision == null
                  ? 'Precisión: sin respuestas'
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.icono,
    required this.acento,
    required this.valor,
    required this.etiqueta,
    this.descripcion,
  });

  final IconData icono;
  final Color acento;
  final String valor;
  final String etiqueta;

  /// Texto para el lector de pantalla cuando [valor] no se entiende solo.
  final String? descripcion;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tipografia = Theme.of(context).textTheme;
    return Semantics(
      label: descripcion ?? '$etiqueta: $valor',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: tokens.superficie,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.borde),
        ),
        child: Column(
          children: <Widget>[
            Icon(icono, color: acento, size: 22),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(valor, style: tipografia.titleMedium),
            ),
            Text(etiqueta, style: tipografia.labelMedium),
          ],
        ),
      ),
    );
  }
}

/// Acceso secundario compacto: ícono en insignia tintada, título y una pista.
class _TarjetaAcceso extends StatelessWidget {
  const _TarjetaAcceso({
    required this.icono,
    required this.acento,
    required this.titulo,
    required this.descripcion,
    required this.onTap,
    super.key,
  });

  final IconData icono;
  final Color acento;
  final String titulo;
  final String descripcion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final tipografia = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      child: Material(
        color: tokens.superficie,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: tokens.borde),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: acento.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, color: acento, size: 22),
                ),
                const SizedBox(height: 12),
                Text(titulo, style: tipografia.titleSmall),
                const SizedBox(height: 2),
                Text(descripcion, style: tipografia.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
