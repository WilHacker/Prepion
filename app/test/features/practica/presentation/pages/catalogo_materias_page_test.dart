import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';
import 'package:prepion/features/practica/presentation/pages/catalogo_materias_page.dart';
import 'package:prepion/features/practica/presentation/providers/catalogo_provider.dart';

Widget _pagina(List<ResumenMateria> materias) => ProviderScope(
  overrides: [
    catalogoMateriasProvider.overrideWith((ref) => Stream.value(materias)),
  ],
  child: const MaterialApp(home: CatalogoMateriasPage()),
);

void main() {
  testWidgets('muestra las materias con contadores y dominio', (tester) async {
    const lista = [
      ResumenMateria(
        nombre: 'Matemáticas',
        cantidadPreguntas: 10,
        cantidadTemas: 5,
        porcentajeDominio: 0.8,
      ),
      ResumenMateria(
        nombre: 'Física',
        cantidadPreguntas: 8,
        cantidadTemas: 3,
        porcentajeDominio: null,
      ),
      ResumenMateria(
        nombre: 'Química',
        cantidadPreguntas: 0,
        cantidadTemas: 0,
        porcentajeDominio: null,
      ),
      ResumenMateria(
        nombre: 'Biología',
        cantidadPreguntas: 15,
        cantidadTemas: 4,
        porcentajeDominio: 0.5,
      ),
    ];

    await tester.pumpWidget(_pagina(lista));
    await tester.pump();

    expect(find.text('Materias'), findsOneWidget);
    expect(find.text('Matemáticas'), findsOneWidget);
    expect(find.text('10 preguntas en 5 temas'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);

    expect(find.text('Física'), findsOneWidget);
    expect(find.text('Sin practicar'), findsNWidgets(2));

    expect(find.text('Química'), findsOneWidget);
    expect(find.text('Sin preguntas todavía'), findsOneWidget);
  });
}
