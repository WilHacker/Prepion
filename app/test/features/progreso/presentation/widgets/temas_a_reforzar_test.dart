import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/progreso/domain/resumen_progreso.dart';
import 'package:prepion/features/progreso/presentation/widgets/temas_a_reforzar.dart';

void main() {
  testWidgets('muestra nombre, materia y porcentaje de cada tema', (
    tester,
  ) async {
    // Preparar y actuar
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TemasAReforzar(
            temas: [
              DominioTema(
                temaId: 't1',
                materia: 'Física',
                nombre: 'Cinemática',
                dominio: 0.45,
                respuestas: 5,
              ),
            ],
          ),
        ),
      ),
    );

    // Verificar
    expect(find.text('Cinemática'), findsOneWidget);
    expect(find.text('Física'), findsOneWidget);
    expect(find.text('45 %'), findsOneWidget);
  });

  testWidgets('avisa que no hay temas cuando la lista está vacía', (
    tester,
  ) async {
    // Preparar y actuar
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TemasAReforzar(temas: [])),
      ),
    );

    // Verificar
    expect(find.text('Aún no hay temas para reforzar.'), findsOneWidget);
  });
}
