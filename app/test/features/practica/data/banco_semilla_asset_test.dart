import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/data/banco_local_service.dart';
import 'package:prepion/shared/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase baseDeDatos;

  setUp(() {
    baseDeDatos = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await baseDeDatos.close();
  });

  test('el asset de la semilla existe y tiene un formato válido', () async {
    // Preparar
    final servicio = BancoLocalService(baseDeDatos, cargarSemillaDeAssets);

    // Actuar y verificar: no lanza, aunque la semilla estuviera vacía.
    await expectLater(servicio.importarSemillaSiHaceFalta(), completes);
  });

  test(
    'cada imagen que cita la semilla existe en los assets de la app',
    () async {
      // Preparar
      await BancoLocalService(
        baseDeDatos,
        cargarSemillaDeAssets,
      ).importarSemillaSiHaceFalta();
      final preguntas = await baseDeDatos.select(baseDeDatos.preguntas).get();

      // Actuar
      final rutas = preguntas.map((p) => p.rutaImagen).whereType<String>();

      // Verificar: una ruta rota solo se vería en el celular, con la tarjeta vacía.
      for (final ruta in rutas) {
        await expectLater(rootBundle.load(ruta), completes, reason: ruta);
      }
    },
  );
}
