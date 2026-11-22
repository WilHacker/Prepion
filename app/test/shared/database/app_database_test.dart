import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/shared/database/app_database.dart';

void main() {
  test('abre la base local en la versión 5 del esquema', () async {
    final baseDeDatos = AppDatabase(NativeDatabase.memory());
    addTearDown(baseDeDatos.close);

    final resultado = await baseDeDatos
        .customSelect('SELECT 1 AS uno')
        .getSingle();

    expect(baseDeDatos.schemaVersion, 5);
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
        'cola_reportes',
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
        'cola_reportes',
      ]),
    );
    expect(examenes, hasLength(1));
  });

  test(
    'agrega cola_sincronizacion y columna modo al migrar desde la versión 3',
    () async {
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
              ..execute(
                "INSERT INTO respuestas_locales VALUES ('r1', 'p1', 'A', 1, 3, 500, 1000)",
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
        containsAll(['cola_sincronizacion', 'cola_reportes']),
      );

      final fila = await baseDeDatos
          .customSelect(
            'SELECT modo FROM respuestas_locales WHERE id_evento = ?',
            variables: [Variable.withString('r1')],
          )
          .getSingle();

      expect(fila.read<String>('modo'), 'diaria');
    },
  );

  test('agrega cola_reportes al migrar desde la versión 4', () async {
    final baseDeDatos = AppDatabase(
      NativeDatabase.memory(
        setup: (conexion) {
          conexion
            ..execute(
              'CREATE TABLE examenes (id TEXT NOT NULL PRIMARY KEY, '
              'gestion TEXT NOT NULL, tipo TEXT NOT NULL, '
              'archivo TEXT NOT NULL)',
            )
            ..execute('PRAGMA user_version = 4');
        },
      ),
    );
    addTearDown(baseDeDatos.close);

    final tablas = await baseDeDatos
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();

    expect(
      tablas.map((fila) => fila.read<String>('name')),
      contains('cola_reportes'),
    );
  });
}
