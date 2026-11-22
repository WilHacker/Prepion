import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/presentation/pages/resumen_sesion_page.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';

EstadoSesion _estado({int racha = 3}) => EstadoSesion(
  fase: FaseSesion.terminada,
  racha: racha,
  resultados: const [
    ResultadoPregunta(
      preguntaId: 'a',
      respuesta: RespuestaDelPostulante.correcta,
      tiempoMs: 30000,
    ),
    ResultadoPregunta(
      preguntaId: 'b',
      respuesta: RespuestaDelPostulante.correctaFacil,
      tiempoMs: 20000,
    ),
    ResultadoPregunta(
      preguntaId: 'c',
      respuesta: RespuestaDelPostulante.incorrecta,
      tiempoMs: 35000,
    ),
  ],
);

void main() {
  testWidgets('muestra aciertos, preguntas por repasar, tiempo y racha', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      MaterialApp(home: ResumenSesionPage(estado: _estado())),
    );

    // Verificar
    expect(find.text('2 de 3'), findsOneWidget);
    expect(find.text('Para repasar'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('01:25'), findsOneWidget);
    expect(find.text('3 días'), findsOneWidget);
  });

  testWidgets('escribe "1 día" en singular cuando la racha es de un día', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      MaterialApp(home: ResumenSesionPage(estado: _estado(racha: 1))),
    );

    // Verificar
    expect(find.text('1 día'), findsOneWidget);
  });

  testWidgets('cierra la pantalla cuando se toca "Terminar"', (tester) async {
    // Preparar
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ResumenSesionPage(estado: _estado()),
              ),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    // Actuar
    await tester.tap(find.text('Terminar'));
    await tester.pumpAndSettle();

    // Verificar
    expect(find.text('Sesión terminada'), findsNothing);
  });

  test('formatea la duración como minutos y segundos', () {
    expect(formatearDuracion(0), '00:00');
    expect(formatearDuracion(83000), '01:23');
    expect(formatearDuracion(3725000), '62:05');
  });
}
