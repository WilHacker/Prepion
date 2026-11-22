import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/progreso/domain/resumen_progreso.dart';
import 'package:prepion/features/progreso/presentation/widgets/grafico_dominio.dart';

const _materias = [
  DominioMateria(materia: 'Aritmética-Álgebra', dominio: 0.7, respuestas: 10),
  DominioMateria(materia: 'Geometría-Trigonometría', respuestas: 0),
  DominioMateria(materia: 'Física', dominio: 0.3, respuestas: 4),
  DominioMateria(materia: 'Química', dominio: 0.5, respuestas: 4),
  DominioMateria(materia: 'Biología', dominio: 0.9, respuestas: 4),
];

Future<void> _montar(WidgetTester tester) => tester.pumpWidget(
  const MaterialApp(
    home: Scaffold(body: GraficoDominio(materias: _materias)),
  ),
);

void main() {
  testWidgets('dibuja cinco barras con sus etiquetas cortas', (tester) async {
    // Preparar y actuar
    await _montar(tester);

    // Verificar
    final chart = tester.widget<BarChart>(find.byType(BarChart));
    expect(chart.data.barGroups, hasLength(5));
    for (final etiqueta in [
      'Álgebra',
      'Geometría',
      'Física',
      'Química',
      'Biología',
    ]) {
      expect(find.text(etiqueta), findsOneWidget);
    }
  });

  testWidgets('marca la materia sin datos con la leyenda Sin datos', (
    tester,
  ) async {
    // Preparar y actuar
    await _montar(tester);

    // Verificar
    expect(find.textContaining('Sin datos'), findsOneWidget);
  });

  testWidgets('describe el gráfico con semántica accesible', (tester) async {
    // Preparar
    final handle = tester.ensureSemantics();

    // Actuar
    await _montar(tester);

    // Verificar
    expect(
      find.bySemanticsLabel(RegExp('Álgebra 70 %, Geometría sin datos')),
      findsOneWidget,
    );
    handle.dispose();
  });
}
