import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/reportes/data/reportes_repositorio.dart';
import 'package:prepion/shared/database/app_database.dart';

void main() {
  late AppDatabase db;
  late ReportesRepositorio repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ReportesRepositorio(db);
  });

  tearDown(() => db.close());

  test('guarda y recupera reportes pendientes ordenados por fecha', () async {
    // Arrange
    final fecha1 = DateTime.utc(2026, 11, 22, 10, 0);
    final fecha2 = DateTime.utc(2026, 11, 22, 11, 0);

    // Act
    await repo.guardarReporte(
      id: 'rep-1',
      preguntaId: 'preg-1',
      motivo: 'respuesta_incorrecta',
      comentario: 'La opción B no coincide',
      creadoEn: fecha1,
    );
    await repo.guardarReporte(
      id: 'rep-2',
      preguntaId: 'preg-2',
      motivo: 'imagen_borrosa',
      creadoEn: fecha2,
    );

    final pendientes = await repo.obtenerPendientes();

    // Assert
    expect(pendientes, hasLength(2));
    expect(pendientes[0].id, 'rep-1');
    expect(pendientes[0].motivo, 'respuesta_incorrecta');
    expect(pendientes[0].comentario, 'La opción B no coincide');
    expect(pendientes[0].estado, 'pendiente');
    expect(pendientes[1].id, 'rep-2');
  });

  test('marca reportes como enviados y actualiza su estado', () async {
    // Arrange
    await repo.guardarReporte(
      id: 'rep-1',
      preguntaId: 'preg-1',
      motivo: 'error_tipografico',
    );

    // Act
    await repo.marcarEnviados(['rep-1']);
    final pendientes = await repo.obtenerPendientes();

    // Assert
    expect(pendientes, isEmpty);
    final todos = await db.select(db.colaReportes).get();
    expect(todos.first.estado, 'enviado');
  });

  test('marca reportes como fallidos tras error en la red', () async {
    // Arrange
    await repo.guardarReporte(
      id: 'rep-1',
      preguntaId: 'preg-1',
      motivo: 'otro',
    );

    // Act
    await repo.marcarFallidos(['rep-1']);
    final pendientes = await repo.obtenerPendientes();

    // Assert
    expect(pendientes, isEmpty);
    final todos = await db.select(db.colaReportes).get();
    expect(todos.first.estado, 'fallido');
  });
}
