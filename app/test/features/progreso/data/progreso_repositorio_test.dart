import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/progreso/data/progreso_repositorio.dart';
import 'package:prepion/shared/database/app_database.dart';

void main() {
  late AppDatabase baseDeDatos;
  late ProgresoRepositorio repositorio;

  Future<void> insertarPregunta(String id, String? temaId) => baseDeDatos
      .into(baseDeDatos.preguntas)
      .insert(
        PreguntasCompanion.insert(
          id: id,
          examenId: 'examen-1',
          codigo: 'C-$id',
          temaId: Value(temaId),
          enunciado: 'Enunciado $id',
          opciones: const ['a', 'b'],
          respuesta: 'B',
          explicacion: 'Explicación',
          fuente: 'Fuente',
        ),
      );

  Future<void> insertarRespuesta(
    String idEvento,
    String preguntaId,
    DateTime cuando, {
    bool esCorrecta = true,
  }) => baseDeDatos
      .into(baseDeDatos.respuestasLocales)
      .insert(
        RespuestasLocalesCompanion.insert(
          idEvento: idEvento,
          preguntaId: preguntaId,
          esCorrecta: esCorrecta,
          calificacion: 3,
          tiempoMs: 1000,
          respondidaEn: cuando,
        ),
      );

  setUp(() async {
    baseDeDatos = AppDatabase(NativeDatabase.memory());
    repositorio = ProgresoRepositorio(baseDeDatos);
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
    await baseDeDatos
        .into(baseDeDatos.temas)
        .insert(
          TemasCompanion.insert(
            id: 't-fis',
            materia: 'Física',
            nombre: 'Cinemática',
          ),
        );
    await insertarPregunta('p1', 't-fis');
    await insertarPregunta('p-sin-tema', null);
  });

  tearDown(() async {
    await baseDeDatos.close();
  });

  test('devuelve los temas con su materia y nombre', () async {
    // Actuar
    final temas = await repositorio.temas();

    // Verificar
    expect(temas.single.id, 't-fis');
    expect(temas.single.materia, 'Física');
    expect(temas.single.nombre, 'Cinemática');
  });

  test('devuelve cada respuesta con el tema de su pregunta', () async {
    // Preparar
    final cuando = DateTime.utc(2026, 11, 20, 15);
    await insertarRespuesta('e1', 'p1', cuando, esCorrecta: false);

    // Actuar
    final respuestas = await repositorio.respuestas();

    // Verificar
    expect(respuestas.single.temaId, 't-fis');
    expect(respuestas.single.esCorrecta, isFalse);
    expect(respuestas.single.respondidaEn, cuando);
    expect(respuestas.single.respondidaEn.isUtc, isTrue);
  });

  test('omite las respuestas de preguntas sin tema', () async {
    // Preparar
    await insertarRespuesta('e1', 'p-sin-tema', DateTime.utc(2026, 11, 20));
    await insertarRespuesta('e2', 'p1', DateTime.utc(2026, 11, 21));

    // Actuar
    final respuestas = await repositorio.respuestas();

    // Verificar
    expect(respuestas, hasLength(1));
    expect(respuestas.single.temaId, 't-fis');
  });

  test('devuelve listas vacías cuando no hay nada guardado', () async {
    // Preparar
    await baseDeDatos.delete(baseDeDatos.preguntas).go();
    await baseDeDatos.delete(baseDeDatos.temas).go();

    // Verificar
    expect(await repositorio.respuestas(), isEmpty);
    expect(await repositorio.temas(), isEmpty);
  });
}
