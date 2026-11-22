import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/progreso/domain/resumen_progreso.dart';
import 'package:prepion/features/progreso/presentation/widgets/medidor_nivel.dart';

const _advertencia =
    'Estimación basada en tu práctica; no garantiza la admisión.';

Future<void> _montar(WidgetTester tester, NivelPreparacion nivel) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: MedidorNivel(nivel: nivel)),
      ),
    );

void main() {
  testWidgets('muestra el nivel y los tres segmentos cuando hay datos', (
    tester,
  ) async {
    // Preparar y actuar
    await _montar(tester, NivelPreparacion.medio);

    // Verificar
    expect(find.text('Nivel estimado: Medio'), findsOneWidget);
    expect(find.text('Bajo'), findsOneWidget);
    expect(find.text('Medio'), findsOneWidget);
    expect(find.text('Alto'), findsOneWidget);
    expect(find.text(_advertencia), findsOneWidget);
  });

  testWidgets('pide más respuestas y no muestra la barra sin datos', (
    tester,
  ) async {
    // Preparar y actuar
    await _montar(tester, NivelPreparacion.sinDatos);

    // Verificar
    expect(
      find.text('Responde al menos 10 preguntas para estimar tu nivel.'),
      findsOneWidget,
    );
    expect(find.text('Bajo'), findsNothing);
    expect(find.text(_advertencia), findsOneWidget);
  });
}
