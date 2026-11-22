import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/progreso/domain/resumen_progreso.dart';
import 'package:prepion/features/progreso/presentation/widgets/colores_semaforo.dart';

/// Barras de dominio (0 a 100 %) por materia, coloreadas con el semáforo.
class GraficoDominio extends StatelessWidget {
  const GraficoDominio({required this.materias, super.key});

  final List<DominioMateria> materias;

  /// Nombre corto para el eje; si no hay mapeo se usa el nombre completo.
  static String etiqueta(String materia) => switch (materia) {
    'Aritmética-Álgebra' => 'Álgebra',
    'Geometría-Trigonometría' => 'Geometría',
    _ => materia,
  };

  static String _porcentaje(double dominio) => '${(dominio * 100).round()} %';

  @override
  Widget build(BuildContext context) {
    final descripcion = materias
        .map(
          (m) =>
              '${etiqueta(m.materia)} '
              '${m.dominio == null ? 'sin datos' : _porcentaje(m.dominio!)}',
        )
        .join(', ');
    final sinDatos = materias.where((m) => m.dominio == null).toList();
    return Semantics(
      label: 'Dominio por materia: $descripcion',
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: 100,
                barTouchData: const BarTouchData(enabled: false),
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 25,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text('${value.round()} %'),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          etiqueta(materias[value.toInt()].materia),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (final (i, materia) in materias.indexed)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (materia.dominio ?? 0) * 100,
                          width: 22,
                          color: materia.dominio == null
                              ? null
                              : colorDeSemaforo(semaforoDe(materia.dominio!)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          for (final materia in sinDatos)
            Text(
              '${etiqueta(materia.materia)}: Sin datos',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
