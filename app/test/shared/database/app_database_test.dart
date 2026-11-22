import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/shared/database/app_database.dart';

void main() {
  test('abre la base local en la versión 4 del esquema', () async {
    // Preparar
    final baseDeDatos = AppDatabase(NativeDatabase.memory());
    addTearDown(baseDeDatos.close);

    // Actuar
    final resultado = await baseDeDatos
        .customSelect('SELECT 1 AS uno')
        .getSingle();

    // Verificar
    expect(baseDeDatos.schemaVersion, 4);
    expect(resultado.read<int>('uno'), 1);
  });

  test('crea las tablas del banco cuando migra desde la versión 1', () async {
    // Preparar: una base como la que ya tienen instalada, sin tablas y en v1.
    final baseDeDatos = AppDatabase(
      NativeDatabase.memory(
        setup: (conexion) => conexion.execute('PRAGMA user_version = 1'),
      ),
    );
    addTearDown(baseDeDatos.close);

    // Actuar
    final tablas = await baseDeDatos
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          'ORDER BY name',
        )
        .get();

    // Verificar
    expect(
      tablas.map((fila) => fila.read<String>('name')),
      containsAll([
        'examenes',
        'temas',
        'preguntas',
        'tarjetas_fsrs',
        'respuestas_locales',
        'cola_sincronizacion',
      ]),
    );
  });

  test('agrega las tablas de práctica sin tocar las del banco al migrar desde la versión 2', () async {
    final baseDeDatos = AppDatabase(
      NativeDatabase.memory(
        setup: (conexion) {
          conexion
            ..execute(
              'CREATE TABLE examenes (id TEXT NOT NULL PRIMARY KEY, '
              'gestion TEXT NOT NULL, tipo TEXT NOT NULL, '
              'archivo TEXT NOT NULL)',
            )
            ..execute(
              "INSERT INTO examenes VALUES ('e1', '2-2026', '1op', 'x')",
            )
            ..execute('PRAGMA user_version = 2');
        },
      ),
    );
    addTearDown(baseDeDatos.close);

    final tablas = await baseDeDatos
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final examenes = await baseDeDatos.select(baseDeDatos.examenes).get();

    expect(
      tablas.map((fila) => fila.read<String>('name')),
      containsAll([
        'tarjetas_fsrs',
        'respuestas_locales',
        'cola_sincronizacion',
      ]),
    );
    expect(examenes, hasLength(1));
  });

  test('agrega cola_sincronizacion al migrar desde la versión 3', () async {
    final baseDeDatos = AppDatabase(
      NativeDatabase.memory(
        setup: (conexion) {
          conexion
            ..execute(
              'CREATE TABLE examenes (id TEXT NOT NULL PRIMARY KEY, '
              'gestion TEXT NOT NULL, tipo TEXT NOT NULL, '
              'archivo TEXT NOT NULL)',
            )
            ..execute(
              'CREATE TABLE respuestas_locales (id_evento TEXT NOT NULL PRIMARY KEY, '
              'pregunta_id TEXT NOT NULL, opcion_elegida TEXT, es_correcta INTEGER NOT NULL, '
              'calificacion INTEGER NOT NULL, tiempo_ms INTEGER NOT NULL, '
              'respondida_en INTEGER NOT NULL)',
            )
            ..execute('PRAGMA user_version = 3');
        },
      ),
    );
    addTearDown(baseDeDatos.close);

    final tablas = await baseDeDatos
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();

    expect(
      tablas.map((fila) => fila.read<String>('name')),
      contains('cola_sincronizacion'),
    );
  });
}
