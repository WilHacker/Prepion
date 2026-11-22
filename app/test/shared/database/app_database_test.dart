import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/shared/database/app_database.dart';

void main() {
  test('abre la base local en la versión 2 del esquema', () async {
    // Preparar
    final baseDeDatos = AppDatabase(NativeDatabase.memory());
    addTearDown(baseDeDatos.close);

    // Actuar
    final resultado = await baseDeDatos
        .customSelect('SELECT 1 AS uno')
        .getSingle();

    // Verificar
    expect(baseDeDatos.schemaVersion, 2);
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
      containsAll(['examenes', 'temas', 'preguntas']),
    );
  });
}
