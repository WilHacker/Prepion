import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/data/practica_repositorio.dart';
import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/domain/tarjeta_repaso.dart';
import 'package:prepion/shared/database/app_database.dart';

final _ahora = DateTime.utc(2026, 11, 23, 9, 30);

TarjetaRepaso _tarjeta(String preguntaId, {int estado = 2}) => TarjetaRepaso(
  preguntaId: preguntaId,
  estado: estado,
  vence: DateTime.utc(2026, 11, 26, 9, 30),
  estabilidad: 3.5,
  dificultad: 6.1,
  ultimaRevision: _ahora,
);

void main() {
  late AppDatabase baseDeDatos;
  late PracticaRepositorio repositorio;

  Future<void> insertarPregunta(String id, String codigo, String temaId) =>
      baseDeDatos
          .into(baseDeDatos.preguntas)
          .insert(
            PreguntasCompanion.insert(
              id: id,
              examenId: 'examen-1',
              codigo: codigo,
              temaId: Value(temaId),
              enunciado: 'Enunciado $codigo',
              opciones: const ['a', 'b', 'c'],
              respuesta: 'B',
              explicacion: 'Explicación $codigo',
              fuente: 'Fuente $codigo',
            ),
          );

  setUp(() async {
    baseDeDatos = AppDatabase(NativeDatabase.memory());
    repositorio = PracticaRepositorio(baseDeDatos);
    await baseDeDatos
        .into(baseDeDatos.examenes)
        .insert(
          ExamenesCompanion.insert(
            id: 'examen-1',
            gestion: '2-2026',
            tipo: '2op',
            archivo: 'x.pdf',
          ),
        );
    for (final tema in [
      ('t-mat', 'Aritmética-Álgebra'),
      ('t-qui', 'Química'),
    ]) {
      await baseDeDatos
          .into(baseDeDatos.temas)
          .insert(
            TemasCompanion.insert(
              id: tema.$1,
              materia: tema.$2,
              nombre: 'Tema ${tema.$1}',
            ),
          );
    }
    await insertarPregunta('p-a1', 'S1-A1', 't-mat');
    await insertarPregunta('p-a2', 'S1-A2', 't-mat');
    await insertarPregunta('p-q16', 'S1-Q16', 't-qui');
    await insertarPregunta('p-q17', 'S1-Q17', 't-qui');
  });

  tearDown(() async {
    await baseDeDatos.close();
  });

  Future<void> responder({
    required String idEvento,
    required String preguntaId,
    RespuestaDelPostulante respuesta = RespuestaDelPostulante.correcta,
    String? opcion = 'B',
    TarjetaRepaso? tarjeta,
    DateTime? cuando,
  }) => repositorio.registrarRespuesta(
    idEvento: idEvento,
    preguntaId: preguntaId,
    opcionElegida: opcion,
    respuesta: respuesta,
    tiempoMs: 4200,
    respondidaEn: cuando ?? _ahora,
    tarjeta: tarjeta ?? _tarjeta(preguntaId),
  );

  group('idsDePreguntasNuevas', () {
    test('intercala las materias para no agotarlas una por una', () async {
      // Actuar
      final ids = await repositorio.idsDePreguntasNuevas();

      // Verificar
      expect(ids, ['p-a1', 'p-q16', 'p-a2', 'p-q17']);
    });

    test('excluye las preguntas que ya se practicaron', () async {
      // Preparar
      await responder(idEvento: 'e1', preguntaId: 'p-a1');

      // Actuar
      final ids = await repositorio.idsDePreguntasNuevas();

      // Verificar
      expect(ids, ['p-a2', 'p-q16', 'p-q17']);
    });
  });

  group('registrarRespuesta', () {
    test(
      'guarda la respuesta y deja la tarjeta de repaso de la pregunta',
      () async {
        // Actuar
        await responder(idEvento: 'e1', preguntaId: 'p-a1');

        // Verificar
        final respuestas = await baseDeDatos
            .select(baseDeDatos.respuestasLocales)
            .get();
        final tarjetas = await repositorio.tarjetas();
        expect(respuestas.single.idEvento, 'e1');
        expect(respuestas.single.opcionElegida, 'B');
        expect(respuestas.single.esCorrecta, isTrue);
        expect(respuestas.single.calificacion, 3);
        expect(respuestas.single.tiempoMs, 4200);
        expect(tarjetas.single, _tarjeta('p-a1'));
      },
    );

    test(
      'guarda sin opción elegida cuando el postulante toca "No sé"',
      () async {
        // Actuar
        await responder(
          idEvento: 'e1',
          preguntaId: 'p-a1',
          respuesta: RespuestaDelPostulante.noSe,
          opcion: null,
        );

        // Verificar
        final respuesta = await baseDeDatos
            .select(baseDeDatos.respuestasLocales)
            .getSingle();
        expect(respuesta.opcionElegida, isNull);
        expect(respuesta.esCorrecta, isFalse);
        expect(respuesta.calificacion, 1);
      },
    );

    test('actualiza la tarjeta en lugar de duplicarla al repasar', () async {
      // Preparar
      await responder(idEvento: 'e1', preguntaId: 'p-a1');
      final repasada = TarjetaRepaso(
        preguntaId: 'p-a1',
        estado: 2,
        vence: DateTime.utc(2026, 12, 5),
        estabilidad: 9,
        dificultad: 5,
        ultimaRevision: DateTime.utc(2026, 11, 26),
      );

      // Actuar
      await responder(idEvento: 'e2', preguntaId: 'p-a1', tarjeta: repasada);

      // Verificar
      expect(await repositorio.tarjetas(), [repasada]);
      expect(
        await baseDeDatos.select(baseDeDatos.respuestasLocales).get(),
        hasLength(2),
      );
    });

    test('no guarda nada a medias cuando la pregunta no existe', () async {
      // Actuar
      await expectLater(
        responder(idEvento: 'e1', preguntaId: 'no-existe'),
        throwsA(anything),
      );

      // Verificar
      expect(
        await baseDeDatos.select(baseDeDatos.respuestasLocales).get(),
        isEmpty,
      );
      expect(await repositorio.tarjetas(), isEmpty);
    });
  });

  group('lecturas', () {
    test('devuelve la tarjeta de una pregunta, o null si es nueva', () async {
      // Preparar
      await responder(idEvento: 'e1', preguntaId: 'p-a1');

      // Verificar
      expect(await repositorio.tarjetaDe('p-a1'), _tarjeta('p-a1'));
      expect(await repositorio.tarjetaDe('p-a2'), isNull);
    });

    test('devuelve las preguntas pedidas en el mismo orden', () async {
      // Actuar
      final preguntas = await repositorio.preguntasPorId(['p-q17', 'p-a1']);

      // Verificar
      expect(preguntas.map((p) => p.id), ['p-q17', 'p-a1']);
    });

    test('devuelve las fechas de todas las respuestas guardadas', () async {
      // Preparar
      await responder(idEvento: 'e1', preguntaId: 'p-a1');
      await responder(
        idEvento: 'e2',
        preguntaId: 'p-a2',
        cuando: DateTime.utc(2026, 11, 22, 20),
      );

      // Actuar
      final fechas = await repositorio.fechasDeRespuestas();

      // Verificar
      expect(fechas, hasLength(2));
      expect(fechas, contains(DateTime.utc(2026, 11, 22, 20)));
    });
  });
}
