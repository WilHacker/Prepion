import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/data/banco_local_service.dart';
import 'package:prepion/shared/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el asset de la semilla existe y tiene un formato válido', () async {
    // Preparar
    final baseDeDatos = AppDatabase(NativeDatabase.memory());
    addTearDown(baseDeDatos.close);
    final servicio = BancoLocalService(baseDeDatos, cargarSemillaDeAssets);

    // Actuar y verificar: no lanza, aunque la semilla aún esté vacía.
    await expectLater(servicio.importarSemillaSiHaceFalta(), completes);
  });
}
