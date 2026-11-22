import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';
import 'package:prepion/features/practica/presentation/pages/temas_por_materia_page.dart';
import 'package:prepion/features/practica/presentation/providers/temas_de_materia_provider.dart';

Widget _pagina(String materia, List<ResumenTema> temas) => ProviderScope(
  overrides: [
    temasDeMateriaProvider(materia).overrideWith((ref) => Stream.value(temas)),
  ],
  child: MaterialApp(home: TemasPorMateriaPage(materia: materia)),
);

void main() {
  testWidgets('muestra temas, dominio y deshabilita cuando tiene 0 preguntas', (
    tester,
  ) async {
    const temas = [
      ResumenTema(
        id: 't1',
        materia: 'Química',
        nombre: 'Estequiometría',
        cantidadPreguntas: 5,
        porcentajeDominio: 0.75,
      ),
      ResumenTema(
        id: 't2',
        materia: 'Química',
        nombre: 'Gases',
        cantidadPreguntas: 0,
        porcentajeDominio: null,
      ),
    ];

    await tester.pumpWidget(_pagina('Química', temas));
    await tester.pump();

    expect(find.text('Química'), findsOneWidget);
    expect(find.text('Estequiometría'), findsOneWidget);
    expect(find.text('5 preguntas'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);

    expect(find.text('Gases'), findsOneWidget);
    expect(find.text('Sin preguntas todavía'), findsOneWidget);
    expect(find.text('Sin practicar'), findsNothing);

    final itemGases = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Gases'),
    );
    expect(itemGases.enabled, isFalse);

    final itemEsteq = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Estequiometría'),
    );
    expect(itemEsteq.enabled, isTrue);
  });
}
