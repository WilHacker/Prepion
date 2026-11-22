import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/shared/database/banco_tablas.dart';
import 'package:prepion/shared/database/opciones_converter.dart';

part 'app_database.g.dart';

/// Base de datos local de la app. Cada feature agrega aquí sus tablas.
@DriftDatabase(tables: [Examenes, Temas, Preguntas])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'prepion'));

  @override
  int get schemaVersion => 2;

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
