import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/presentation/widgets/hoja_explicacion.dart';

Widget _hoja({
  required RespuestaDelPostulante respuesta,
  VoidCallback? onSiguiente,
  ValueChanged<RespuestaDelPostulante>? onDificultad,
  bool esUltima = false,
}) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: HojaExplicacion(
        respuesta: respuesta,
        respuestaCorrecta: 'B',
        explicacion: 'La homeostasis mantiene el medio interno.',
        esUltima: esUltima,
        onSiguiente: onSiguiente ?? () {},
        onDificultad: onDificultad ?? (_) {},
      ),
    ),
  ),
);

void main() {
  testWidgets('felicita, muestra la clave y la explicación cuando acierta', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(_hoja(respuesta: RespuestaDelPostulante.correcta));

    // Verificar
    expect(find.text('¡Correcto!'), findsOneWidget);
    expect(find.text('Respuesta correcta: B'), findsOneWidget);
    expect(
      find.text('La homeostasis mantiene el medio interno.'),
      findsOneWidget,
    );
    expect(find.text('Me costó'), findsOneWidget);
    expect(find.text('Fue fácil'), findsOneWidget);
  });

  testWidgets('dice que es incorrecto y no ofrece afinar cuando falla', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      _hoja(respuesta: RespuestaDelPostulante.incorrecta),
    );

    // Verificar
    expect(find.text('Incorrecto'), findsOneWidget);
    expect(find.text('Respuesta correcta: B'), findsOneWidget);
    expect(find.text('Me costó'), findsNothing);
    expect(find.text('Fue fácil'), findsNothing);
  });

  testWidgets('anima con un mensaje amable cuando toca "No sé"', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(_hoja(respuesta: RespuestaDelPostulante.noSe));

    // Verificar
    expect(find.text('No pasa nada, así se aprende'), findsOneWidget);
    expect(find.text('Me costó'), findsNothing);
  });

  testWidgets('avisa la dificultad elegida con "Me costó" y "Fue fácil"', (
    tester,
  ) async {
    // Preparar
    final elegidas = <RespuestaDelPostulante>[];
    await tester.pumpWidget(
      _hoja(
        respuesta: RespuestaDelPostulante.correcta,
        onDificultad: elegidas.add,
      ),
    );

    // Actuar
    await tester.tap(find.text('Me costó'));
    await tester.tap(find.text('Fue fácil'));

    // Verificar
    expect(elegidas, [
      RespuestaDelPostulante.correctaMeCosto,
      RespuestaDelPostulante.correctaFacil,
    ]);
  });

  testWidgets('marca como seleccionada la dificultad actual', (tester) async {
    // Actuar
    await tester.pumpWidget(
      _hoja(respuesta: RespuestaDelPostulante.correctaFacil),
    );

    // Verificar
    final fuefacil = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Fue fácil'),
    );
    final mecosto = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Me costó'),
    );
    expect(fuefacil.selected, isTrue);
    expect(mecosto.selected, isFalse);
  });

  testWidgets('el botón dice "Ver resumen" en la última pregunta', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      _hoja(respuesta: RespuestaDelPostulante.correcta, esUltima: true),
    );

    // Verificar
    expect(find.text('Ver resumen'), findsOneWidget);
    expect(find.text('Siguiente'), findsNothing);
  });

  testWidgets('avisa cuando se toca "Siguiente"', (tester) async {
    // Preparar
    var siguiente = false;
    await tester.pumpWidget(
      _hoja(
        respuesta: RespuestaDelPostulante.correcta,
        onSiguiente: () => siguiente = true,
      ),
    );

    // Actuar
    await tester.tap(find.text('Siguiente'));

    // Verificar
    expect(siguiente, isTrue);
  });

  testWidgets('muestra el botón de reportar error y avisa al tocarlo', (
    tester,
  ) async {
    var reportado = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HojaExplicacion(
              respuesta: RespuestaDelPostulante.incorrecta,
              respuestaCorrecta: 'C',
              explicacion: 'Explicación de prueba.',
              onSiguiente: () {},
              onDificultad: (_) {},
              onReportarError: () => reportado = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Reportar error'), findsOneWidget);
    await tester.tap(find.text('Reportar error'));
    expect(reportado, isTrue);
  });
}
