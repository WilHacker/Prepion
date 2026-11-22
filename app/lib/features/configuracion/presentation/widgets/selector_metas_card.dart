import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';
import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';

/// Selector interactivo de fecha de examen, meta diaria y hora de estudio.
class SelectorMetasCard extends StatelessWidget {
  const SelectorMetasCard({
    required this.fechaExamen,
    required this.metaDiaria,
    required this.horaEstudio,
    required this.onCambiarFecha,
    required this.onCambiarMeta,
    required this.onCambiarHora,
    this.opcionesMeta = metasDiariasDisponibles,
    this.fechasSugeridas = const <FechaTentativaExamen>[],
    super.key,
  });

  final DateTime fechaExamen;
  final int metaDiaria;
  final TimeOfDay horaEstudio;
  final ValueChanged<DateTime> onCambiarFecha;
  final ValueChanged<int> onCambiarMeta;
  final ValueChanged<TimeOfDay> onCambiarHora;
  final List<int> opcionesMeta;
  final List<FechaTentativaExamen> fechasSugeridas;

  Future<void> _seleccionarFecha(BuildContext context) async {
    final ahora = DateTime.now();
    final inicio = DateTime(ahora.year, ahora.month, ahora.day);
    final inicial = fechaExamen.isBefore(inicio) ? inicio : fechaExamen;
    final elegida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: inicio,
      lastDate: DateTime(ahora.year + 3, 12, 31),
      helpText: 'Fecha tentativa de tu examen',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (elegida != null) {
      onCambiarFecha(elegida);
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: horaEstudio,
      helpText: 'Hora habitual de estudio',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (elegida != null) {
      onCambiarHora(elegida);
    }
  }

  String _tiempoEstimado(int preguntas) {
    if (preguntas <= 5) {
      return '~3 min';
    }
    if (preguntas <= 10) {
      return '~6 min';
    }
    return '~12 min';
  }

  @override
  Widget build(BuildContext context) {
    final horaTexto = formatearHoraEstudio(
      horaEstudio.hour,
      horaEstudio.minute,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColoresPrepion.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresPrepion.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Tu plan diario',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: ColoresPrepion.textoPrincipal,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Puedes ajustar estos valores cuando quieras en Ajustes.',
            style: TextStyle(
              fontSize: 13,
              color: ColoresPrepion.textoSecundario,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Meta diaria de preguntas',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ColoresPrepion.textoPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (var i = 0; i < opcionesMeta.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _OpcionMetaTile(
                    cantidad: opcionesMeta[i],
                    subtitulo: _tiempoEstimado(opcionesMeta[i]),
                    seleccionada: metaDiaria == opcionesMeta[i],
                    onTap: () => onCambiarMeta(opcionesMeta[i]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _SelectorCampo(
                  key: const Key('selector_fecha_examen'),
                  icono: Icons.event_rounded,
                  etiqueta: 'Fecha del examen',
                  valor: formatearFechaCorta(fechaExamen),
                  onTap: () => _seleccionarFecha(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SelectorCampo(
                  key: const Key('selector_hora_estudio'),
                  icono: Icons.schedule_rounded,
                  etiqueta: 'Hora de estudio',
                  valor: horaTexto,
                  onTap: () => _seleccionarHora(context),
                ),
              ),
            ],
          ),
          if (fechasSugeridas.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (final sugerida in fechasSugeridas) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(sugerida.etiqueta),
                        selected:
                            fechaExamen.year == sugerida.fecha.year &&
                            fechaExamen.month == sugerida.fecha.month &&
                            fechaExamen.day == sugerida.fecha.day,
                        onSelected: (_) => onCambiarFecha(sugerida.fecha),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpcionMetaTile extends StatelessWidget {
  const _OpcionMetaTile({
    required this.cantidad,
    required this.subtitulo,
    required this.seleccionada,
    required this.onTap,
  });

  final int cantidad;
  final String subtitulo;
  final bool seleccionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('chip_meta_$cantidad'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: seleccionada
              ? ColoresPrepion.azulMarino
              : ColoresPrepion.fondo,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionada
                ? ColoresPrepion.azulMarino
                : ColoresPrepion.borde,
            width: seleccionada ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
              '$cantidad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: seleccionada
                    ? Colors.white
                    : ColoresPrepion.textoPrincipal,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitulo,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: seleccionada
                      ? Colors.white.withValues(alpha: 0.85)
                      : ColoresPrepion.textoSecundario,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorCampo extends StatelessWidget {
  const _SelectorCampo({
    required this.icono,
    required this.etiqueta,
    required this.valor,
    required this.onTap,
    super.key,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: ColoresPrepion.fondo,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ColoresPrepion.borde),
        ),
        child: Row(
          children: <Widget>[
            Icon(icono, size: 20, color: ColoresPrepion.ambar),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    etiqueta,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColoresPrepion.textoSecundario,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ColoresPrepion.textoPrincipal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
