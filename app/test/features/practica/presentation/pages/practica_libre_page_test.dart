import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/data/practica_libre_repositorio.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';
import 'package:prepion/features/practica/presentation/pages/practica_libre_page.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/shared/database/app_database.dart';

class _FakeRepositorioLibre implements PracticaLibreRepositorio {
  _FakeRepositorioLibre(this.preguntas);

  final List<Pregunta> preguntas;

  @override
  Future<Tema?> obtenerTema(String temaId) async =>
      Tema(id: temaId, materia: 'Química', nombre: 'Soluciones');

  @override
  Future<List<Pregunta>> obtenerPreguntasDeTema(String temaId) async =>
      preguntas;

  @override
  Future<void> registrarRespuestaLibre({
    required String idEvento,
    required String preguntaId,
    required String? opcionElegida,
    required bool esCorrecta,
    required int tiempoMs,
    required DateTime respondidaEn,
  }) async {}

  @override
  Stream<List<ResumenMateria>> watchMaterias() => Stream.value([]);

  @override
  Stream<List<ResumenTema>> watchTemasDeMateria(String materiaOficial) =>
      Stream.value([]);

  @override
  Future<List<ResumenMateria>> obtenerMaterias() async => [];

  @override
  Future<List<ResumenTema>> obtenerTemasDeMateria(
    String materiaOficial,
  ) async => [];
}

Widget _pagina(String temaId, List<Pregunta> preguntas) => ProviderScope(
  overrides: [
    practicaLibreRepositorioProvider.overrideWithValue(
      _FakeRepositorioLibre(preguntas),
    ),
    relojProvider.overrideWithValue(() => DateTime.utc(2026, 11, 22, 12)),
    generadorDeIdProvider.overrideWithValue(() => 'uuid-1'),
  ],
  child: MaterialApp(home: PracticaLibrePage(temaId: temaId)),
);

void main() {
  const pregunta1 = Pregunta(
    id: 'p1',
    examenId: 'e1',
    codigo: 'Q10',
    temaId: 't_sol',
    enunciado: '¿Qué es una solución saturada?',
    opciones: ['Contiene la máxima cantidad de soluto', 'Tiene poco soluto'],
    respuesta: 'A',
    explicacion:
        'Una solución saturada no admite más soluto a esa temperatura.',
    fuente: 'Examen FCyT · Q10',
  );

  testWidgets('muestra mensaje vacio cuando no hay preguntas en el tema', (
    tester,
  ) async {
    await tester.pumpWidget(_pagina('t_vacio', []));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Sin preguntas todavía'), findsOneWidget);
    expect(find.text('Volver a temas'), findsOneWidget);
  });

  testWidgets(
    'flujo completo de practica libre respondiendo y viendo explicacion sin botones FSRS',
    (tester) async {
      await tester.pumpWidget(_pagina('t_sol', [pregunta1]));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Soluciones'), findsOneWidget);
      expect(find.text('¿Qué es una solución saturada?'), findsOneWidget);

      await tester.tap(find.text('A) Contiene la máxima cantidad de soluto'));
      // Al responder, la página se desplaza hasta la explicación (animado).
      await tester.pumpAndSettle();

      expect(find.text('¡Correcto!'), findsOneWidget);
      expect(
        find.textContaining('no admite más soluto a esa temperatura'),
        findsOneWidget,
      );
      expect(find.text('Me costó'), findsNothing);
      expect(find.text('Fue fácil'), findsNothing);

      await tester.tap(find.text('Ver resumen'));
      await tester.pump();

      expect(find.text('¡Práctica completada!'), findsOneWidget);
      expect(find.text('1 de 1 correctas (100%)'), findsOneWidget);
      expect(find.text('Volver a practicar'), findsOneWidget);
      expect(find.text('Elegir otro tema'), findsOneWidget);
    },
  );
}
