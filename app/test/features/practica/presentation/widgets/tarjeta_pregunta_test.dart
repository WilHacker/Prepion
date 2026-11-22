import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/presentation/widgets/tarjeta_pregunta.dart';
import 'package:prepion/shared/database/app_database.dart';

Pregunta _pregunta({String? rutaImagen}) => Pregunta(
  id: 'p1',
  examenId: 'e1',
  codigo: 'S2-B19',
  temaId: null,
  enunciado: '¿Qué mantiene el equilibrio interno?',
  opciones: const ['Metabolismo', 'Homeostasis', 'Herencia'],
  respuesta: 'B',
  explicacion: 'La homeostasis.',
  rutaImagen: rutaImagen,
  fuente: 'Fuente de prueba',
);

Widget _envolver(Widget hijo) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: hijo)),
);

OutlinedButton _boton(WidgetTester tester, String texto) =>
    tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, texto));

void main() {
  testWidgets('avisa la letra elegida cuando se toca una opción', (
    tester,
  ) async {
    // Preparar
    String? elegida;
    await tester.pumpWidget(
      _envolver(
        TarjetaPregunta(
          pregunta: _pregunta(),
          onElegir: (letra) => elegida = letra,
          onNoSe: () {},
        ),
      ),
    );

    // Actuar
    await tester.tap(find.text('B) Homeostasis'));

    // Verificar
    expect(elegida, 'B');
  });

  testWidgets('avisa cuando se toca "No sé"', (tester) async {
    // Preparar
    var noSe = false;
    await tester.pumpWidget(
      _envolver(
        TarjetaPregunta(
          pregunta: _pregunta(),
          onElegir: (_) {},
          onNoSe: () => noSe = true,
        ),
      ),
    );

    // Actuar
    await tester.tap(find.text('No sé'));

    // Verificar
    expect(noSe, isTrue);
  });

  testWidgets('bloquea los botones cuando ya se muestra la clave', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      _envolver(
        TarjetaPregunta(
          pregunta: _pregunta(),
          onElegir: (_) {},
          onNoSe: () {},
          letraElegida: 'C',
          muestraClave: true,
        ),
      ),
    );

    // Verificar
    expect(_boton(tester, 'A) Metabolismo').onPressed, isNull);
    expect(_boton(tester, 'B) Homeostasis').onPressed, isNull);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'No sé'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('pinta la correcta en verde y la elegida equivocada en rojo', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      _envolver(
        TarjetaPregunta(
          pregunta: _pregunta(),
          onElegir: (_) {},
          onNoSe: () {},
          letraElegida: 'C',
          muestraClave: true,
        ),
      ),
    );

    // Verificar
    Color? fondo(String texto) => _boton(
      tester,
      texto,
    ).style?.backgroundColor?.resolve({WidgetState.disabled});
    expect(fondo('B) Homeostasis'), Colors.green.shade100);
    expect(fondo('C) Herencia'), isNotNull);
    expect(fondo('C) Herencia'), isNot(Colors.green.shade100));
    expect(fondo('A) Metabolismo'), isNull);
  });

  testWidgets('muestra solo las letras cuando la pregunta es una imagen', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      _envolver(
        TarjetaPregunta(
          pregunta: _pregunta(
            rutaImagen: 'assets/imagenes/2026-2-2op_S1-A1.png',
          ),
          onElegir: (_) {},
          onNoSe: () {},
        ),
      ),
    );

    // Verificar
    expect(find.text('B) Homeostasis'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'B'), findsOneWidget);
  });
}
