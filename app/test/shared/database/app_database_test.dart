import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/shared/database/app_database.dart';

void main() {
  test('abre la base local en la versión 1 del esquema', () async {
    // Preparar
    final baseDeDatos = AppDatabase(NativeDatabase.memory());
    addTearDown(baseDeDatos.close);

    // Actuar
    final resultado = await baseDeDatos
        .customSelect('SELECT 1 AS uno')
        .getSingle();

    // Verificar
    expect(baseDeDatos.schemaVersion, 1);
    expect(resultado.read<int>('uno'), 1);
  });
}
