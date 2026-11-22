import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/features/practica/data/practica_libre_repositorio.dart';
import 'package:prepion/shared/database/app_database.dart';

void main() {
  late AppDatabase db;
  late PracticaLibreRepositorio repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = PracticaLibreRepositorio(db);

    await db
        .into(db.examenes)
        .insert(
          const ExamenesCompanion(
            id: Value('e1'),
            gestion: Value('2-2026'),
            tipo: Value('1op'),
            archivo: Value('2026-2-1op.pdf'),
          ),
        );

    await db.batch((batch) {
      batch.insertAll(db.temas, [
        const TemasCompanion(
          id: Value('t_alg'),
          materia: Value('Aritmética-Álgebra'),
          nombre: Value('Ecuaciones'),
        ),
        const TemasCompanion(
          id: Value('t_geom'),
          materia: Value('Geometría-Trigonometría'),
          nombre: Value('Ángulos'),
        ),
        const TemasCompanion(
          id: Value('t_fis'),
          materia: Value('Física'),
          nombre: Value('Cinemática'),
        ),
      ]);
    });

    await db.batch((batch) {
      batch.insertAll(db.preguntas, [
        const PreguntasCompanion(
          id: Value('p1'),
          examenId: Value('e1'),
          codigo: Value('M1'),
          temaId: Value('t_alg'),
          enunciado: Value('2+2'),
          opciones: Value(['4', '5']),
          respuesta: Value('A'),
          explicacion: Value('2+2=4'),
          fuente: Value('Fuente 1'),
        ),
        const PreguntasCompanion(
          id: Value('p2'),
          examenId: Value('e1'),
          codigo: Value('M2'),
          temaId: Value('t_geom'),
          enunciado: Value('Angulo recto'),
          opciones: Value(['90', '45']),
          respuesta: Value('A'),
          explicacion: Value('90 grados'),
          fuente: Value('Fuente 2'),
        ),
        const PreguntasCompanion(
          id: Value('p3'),
          examenId: Value('e1'),
          codigo: Value('F1'),
          temaId: Value('t_fis'),
          enunciado: Value('Velocidad'),
          opciones: Value(['v=d/t', 'v=d*t']),
          respuesta: Value('A'),
          explicacion: Value('v=d/t'),
          fuente: Value('Fuente 3'),
        ),
      ]);
    });
  });

  tearDown(() => db.close());

  test(
    'agrupa materias en las 4 oficiales y combina algebra y geometria',
    () async {
      final materias = await repo.obtenerMaterias();

      expect(materias.map((m) => m.nombre), [
        'Matemáticas',
        'Física',
        'Química',
        'Biología',
      ]);

      final mat = materias.firstWhere((m) => m.nombre == 'Matemáticas');
      expect(mat.cantidadPreguntas, 2);
      expect(mat.cantidadTemas, 2);
      expect(mat.porcentajeDominio, isNull);

      final fis = materias.firstWhere((m) => m.nombre == 'Física');
      expect(fis.cantidadPreguntas, 1);
      expect(fis.cantidadTemas, 1);

      final quim = materias.firstWhere((m) => m.nombre == 'Química');
      expect(quim.cantidadPreguntas, 0);
      expect(quim.cantidadTemas, 0);
    },
  );

  test(
    'obtiene temas de matematicas combinando algebra y geometria con orden',
    () async {
      final temas = await repo.obtenerTemasDeMateria('Matemáticas');

      expect(temas.length, 2);
      expect(temas.map((t) => t.nombre), ['Ecuaciones', 'Ángulos']);
      expect(temas[0].cantidadPreguntas, 1);
      expect(temas[0].porcentajeDominio, isNull);
    },
  );

  test(
    'registra respuesta libre sin alterar tarjetas_fsrs y calcula dominio',
    () async {
      await repo.registrarRespuestaLibre(
        idEvento: 'ev1',
        preguntaId: 'p1',
        opcionElegida: 'A',
        esCorrecta: true,
        tiempoMs: 1200,
        respondidaEn: DateTime.now().toUtc(),
      );

      final tarjetas = await db.select(db.tarjetasFsrs).get();
      expect(tarjetas, isEmpty);

      final respuestas = await db.select(db.respuestasLocales).get();
      expect(respuestas, hasLength(1));
      expect(respuestas.first.modo, 'libre');
      expect(respuestas.first.esCorrecta, isTrue);

      final temas = await repo.obtenerTemasDeMateria('Matemáticas');
      final temaAlg = temas.firstWhere((t) => t.id == 't_alg');
      expect(temaAlg.porcentajeDominio, 1.0);

      final materias = await repo.obtenerMaterias();
      final mat = materias.firstWhere((m) => m.nombre == 'Matemáticas');
      expect(mat.porcentajeDominio, 1.0);
    },
  );

  test('obtiene preguntas filtradas de un tema ordenadas por codigo', () async {
    final preguntas = await repo.obtenerPreguntasDeTema('t_alg');
    expect(preguntas, hasLength(1));
    expect(preguntas.first.codigo, 'M1');
  });
}
