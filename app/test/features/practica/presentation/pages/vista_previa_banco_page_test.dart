import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/practica/presentation/pages/vista_previa_banco_page.dart';
import 'package:prepion/features/practica/presentation/providers/preguntas_banco_provider.dart';
import 'package:prepion/shared/database/app_database.dart';

const _textoDeLaOpcionB = 'Homeostasis';

Pregunta _pregunta({String? rutaImagen}) => Pregunta(
  id: 'id-1',
  examenId: 'examen-1',
  codigo: 'S2-B19',
  temaId: null,
  enunciado: 'La característica que mantiene el equilibrio interno es:',
  opciones: const ['Metabolismo', _textoDeLaOpcionB, 'Herencia'],
  respuesta: 'B',
  explicacion: 'La homeostasis mantiene estable el medio interno.',
  rutaImagen: rutaImagen,
  fuente: 'Examen de ingreso FCyT · 2.ª opción · 2-2026 · B19 (serie 2)',
);

Widget _pagina(List<Pregunta> preguntas) => ProviderScope(
  overrides: [
    preguntasDelBancoProvider.overrideWith((ref) => Stream.value(preguntas)),
  ],
  child: const MaterialApp(home: VistaPreviaBancoPage()),
);

void main() {
  testWidgets('muestra enunciado, fuente y opciones de una pregunta de texto', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(_pagina([_pregunta()]));
    await tester.pump();

    // Verificar
    expect(
      find.textContaining('La característica que mantiene'),
      findsOneWidget,
    );
    expect(find.textContaining('B19 (serie 2)'), findsOneWidget);
    expect(find.text('B) $_textoDeLaOpcionB'), findsOneWidget);
  });

  testWidgets('oculta la respuesta hasta que se toca "Ver respuesta"', (
    tester,
  ) async {
    // Preparar
    await tester.pumpWidget(_pagina([_pregunta()]));
    await tester.pump();
    expect(find.textContaining('Respuesta correcta'), findsNothing);

    // Actuar
    await tester.tap(find.text('Ver respuesta'));
    await tester.pump();

    // Verificar
    expect(find.text('Respuesta correcta: B'), findsOneWidget);
    expect(
      find.text('La homeostasis mantiene estable el medio interno.'),
      findsOneWidget,
    );
    expect(find.text('Ocultar respuesta'), findsOneWidget);
  });

  testWidgets('muestra solo las letras cuando la pregunta es una imagen', (
    tester,
  ) async {
    // Actuar: el texto de las opciones va dentro de la imagen.
    await tester.pumpWidget(
      _pagina([_pregunta(rutaImagen: 'assets/imagenes/2026-2-2op_S1-A1.png')]),
    );
    await tester.pump();

    // Verificar
    expect(find.text('B) $_textoDeLaOpcionB'), findsNothing);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('avisa cuando todavía no hay preguntas en el banco local', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(_pagina(const []));
    await tester.pump();

    // Verificar
    expect(
      find.text('Todavía no hay preguntas en el banco local.'),
      findsOneWidget,
    );
  });

  testWidgets('muestra un error legible cuando falla la lectura', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preguntasDelBancoProvider.overrideWith(
            (ref) => Stream<List<Pregunta>>.error(Exception('falló')),
          ),
        ],
        child: const MaterialApp(home: VistaPreviaBancoPage()),
      ),
    );
    await tester.pump();

    // Verificar
    expect(find.text('No se pudo leer el banco de preguntas.'), findsOneWidget);
  });
}
