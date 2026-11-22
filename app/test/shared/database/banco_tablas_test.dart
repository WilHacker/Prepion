import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/shared/database/app_database.dart';

void main() {
  late AppDatabase baseDeDatos;

  setUp(() {
    baseDeDatos = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await baseDeDatos.close();
  });

  Future<void> insertarExamenYTema() async {
    await baseDeDatos
        .into(baseDeDatos.examenes)
        .insert(
          ExamenesCompanion.insert(
            id: 'examen-1',
            gestion: '2-2026',
            tipo: '1op',
            archivo: '2026-2-1op.pdf',
          ),
        );
    await baseDeDatos
        .into(baseDeDatos.temas)
        .insert(
          TemasCompanion.insert(
            id: 'tema-1',
            materia: 'Química',
            nombre: 'Estequiometría',
          ),
        );
  }

  test('guarda y lee una pregunta con sus opciones en orden', () async {
    // Preparar
    await insertarExamenYTema();
    await baseDeDatos
        .into(baseDeDatos.preguntas)
        .insert(
          PreguntasCompanion.insert(
            id: 'pregunta-1',
            examenId: 'examen-1',
            codigo: 'B18',
            temaId: const Value('tema-1'),
            enunciado: '¿Cuántos moles hay en 18 g de agua?',
            opciones: const ['1', '2', '3', '4', '5'],
            respuesta: 'A',
            explicacion: 'El agua pesa 18 g/mol.',
            fuente: 'Examen de ingreso FCyT · 1.ª opción · 2-2026 · B18',
          ),
        );

    // Actuar
    final pregunta = await baseDeDatos
        .select(baseDeDatos.preguntas)
        .getSingle();

    // Verificar
    expect(pregunta.opciones, ['1', '2', '3', '4', '5']);
    expect(pregunta.rutaImagen, isNull);
    expect(pregunta.temaId, 'tema-1');
  });

  test('rechaza dos preguntas con el mismo código en un examen', () async {
    // Preparar
    await insertarExamenYTema();
    Future<void> insertar(String id) => baseDeDatos
        .into(baseDeDatos.preguntas)
        .insert(
          PreguntasCompanion.insert(
            id: id,
            examenId: 'examen-1',
            codigo: 'B18',
            enunciado: 'Enunciado',
            opciones: const ['a', 'b'],
            respuesta: 'A',
            explicacion: 'Explicación',
            fuente: 'Fuente',
          ),
        );
    await insertar('pregunta-1');

    // Actuar y verificar
    expect(insertar('pregunta-2'), throwsA(isA<SqliteException>()));
  });

  test('rechaza una pregunta de un examen que no existe', () async {
    // Actuar y verificar
    expect(
      baseDeDatos
          .into(baseDeDatos.preguntas)
          .insert(
            PreguntasCompanion.insert(
              id: 'pregunta-1',
              examenId: 'no-existe',
              codigo: 'A1',
              enunciado: 'Enunciado',
              opciones: const ['a', 'b'],
              respuesta: 'A',
              explicacion: 'Explicación',
              fuente: 'Fuente',
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });
}
