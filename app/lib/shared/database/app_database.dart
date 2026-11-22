import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/shared/database/banco_tablas.dart';
import 'package:prepion/shared/database/opciones_converter.dart';
import 'package:prepion/shared/database/practica_tablas.dart';

part 'app_database.g.dart';

/// Base de datos local de la app. Cada feature agrega aquí sus tablas.
@DriftDatabase(
  tables: [Examenes, Temas, Preguntas, TarjetasFsrs, RespuestasLocales],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'prepion'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrador) => migrador.createAll(),
    onUpgrade: (migrador, desde, hasta) async {
      // La versión 1 no tenía tablas: el banco se agrega en la 2.
      if (desde < 2) {
        await migrador.createTable(examenes);
        await migrador.createTable(temas);
        await migrador.createTable(preguntas);
      }
      // La práctica diaria (repaso espaciado y respuestas) llega en la 3.
      if (desde < 3) {
        await migrador.createTable(tarjetasFsrs);
        await migrador.createTable(respuestasLocales);
      }
    },
    beforeOpen: (detalles) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final baseDeDatos = AppDatabase();
  ref.onDispose(baseDeDatos.close);
  return baseDeDatos;
});
