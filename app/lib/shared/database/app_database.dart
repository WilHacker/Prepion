import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

/// Base de datos local de la app. Cada feature agrega aquí sus tablas.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'prepion'));

  @override
  int get schemaVersion => 1;
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final baseDeDatos = AppDatabase();
  ref.onDispose(baseDeDatos.close);
  return baseDeDatos;
});
