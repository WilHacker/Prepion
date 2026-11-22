import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/sincronizacion/data/sincronizacion_repositorio.dart';
import 'package:prepion/shared/database/app_database.dart';

void main() {
  late AppDatabase db;
  late SincronizacionRepositorio repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = SincronizacionRepositorio(db);

    // Insertar examen y pregunta para cumplir integridad referencial
    await db
        .into(db.examenes)
        .insert(
          ExamenesCompanion.insert(
            id: 'ex1',
            gestion: '2-2026',
            tipo: '1op',
            archivo: 'x',
          ),
        );
    await db
        .into(db.preguntas)
        .insert(
          PreguntasCompanion.insert(
            id: 'p1',
            examenId: 'ex1',
            codigo: 'MAT-01',
            enunciado: '¿2+2?',
            opciones: ['3', '4'],
            respuesta: 'B',
            explicacion: '4',
            fuente: 'oficial',
          ),
        );
  });

  tearDown(() => db.close());

  test('encola y obtiene eventos pendientes ordenados por fecha', () async {
    final ahora = DateTime.now();

    await db
        .into(db.colaSincronizacion)
        .insert(
          ColaSincronizacionCompanion.insert(
            idEvento: 'ev1',
            preguntaId: 'p1',
            esCorrecta: true,
            tiempoMs: 1200,
            respondidaEn: ahora,
            creadoEn: ahora,
            actualizadoEn: ahora,
          ),
        );

    final pendientes = await repo.obtenerPendientes();

    expect(pendientes, hasLength(1));
    expect(pendientes.first.idEvento, 'ev1');
    expect(pendientes.first.estado, 'pendiente');
  });

  test('marca eventos como enviados', () async {
    final ahora = DateTime.now();

    await db
        .into(db.colaSincronizacion)
        .insert(
          ColaSincronizacionCompanion.insert(
            idEvento: 'ev1',
            preguntaId: 'p1',
            esCorrecta: true,
            tiempoMs: 1200,
            respondidaEn: ahora,
            creadoEn: ahora,
            actualizadoEn: ahora,
          ),
        );

    final actualizados = await repo.marcarEnviados(['ev1']);
    expect(actualizados, 1);

    final pendientes = await repo.obtenerPendientes();
    expect(pendientes, isEmpty);
  });

  test('incrementa intentos y marca como fallido tras error de red', () async {
    final ahora = DateTime.now();

    await db
        .into(db.colaSincronizacion)
        .insert(
          ColaSincronizacionCompanion.insert(
            idEvento: 'ev1',
            preguntaId: 'p1',
            esCorrecta: true,
            tiempoMs: 1200,
            respondidaEn: ahora,
            creadoEn: ahora,
            actualizadoEn: ahora,
          ),
        );

    await repo.marcarFallidos(['ev1']);

    final fila = await (db.select(
      db.colaSincronizacion,
    )..where((t) => t.idEvento.equals('ev1'))).getSingle();

    expect(fila.estado, 'fallido');
    expect(fila.intentos, 1);
  });
}
