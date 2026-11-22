import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/shared/database/banco_tablas.dart';
import 'package:prepion/shared/database/opciones_converter.dart';
import 'package:prepion/shared/database/practica_tablas.dart';
import 'package:prepion/shared/database/reportes_tablas.dart';
import 'package:prepion/shared/database/sincronizacion_tablas.dart';

part 'app_database.g.dart';

/// Base de datos local de la app. Cada feature agrega aquí sus tablas.
@DriftDatabase(
  tables: [
    Examenes,
    Temas,
    Preguntas,
    TarjetasFsrs,
    RespuestasLocales,
    ColaSincronizacion,
    ColaReportes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'prepion'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrador) => migrador.createAll(),
    onUpgrade: (migrador, desde, hasta) async {
      if (desde < 2) {
        await migrador.createTable(examenes);
        await migrador.createTable(temas);
        await migrador.createTable(preguntas);
      }
      if (desde < 3) {
        await migrador.createTable(tarjetasFsrs);
        await migrador.createTable(respuestasLocales);
      } else if (desde < 4) {
        await migrador.addColumn(respuestasLocales, respuestasLocales.modo);
      }
      // La cola de sincronización offline-first llega en la 4 (HU-08).
      if (desde < 4) {
        await migrador.createTable(colaSincronizacion);
      }
      // La cola de reportes de preguntas llega en la 5 (HU-09).
      if (desde < 5) {
        await migrador.createTable(colaReportes);
      }
    },
    beforeOpen: (detalles) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Asegura que 'modo' exista si la base quedó en v4 antes de la migración.
      try {
        await customStatement(
          "ALTER TABLE respuestas_locales ADD COLUMN modo TEXT NOT NULL DEFAULT 'diaria'",
        );
      } catch (_) {}
      try {
        await customStatement(
          "UPDATE respuestas_locales SET modo = 'diaria' WHERE modo IS NULL",
        );
      } catch (_) {}
      // Asegura que 'cola_reportes' exista (HU-09).
      try {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS cola_reportes ('
          'id TEXT NOT NULL PRIMARY KEY, '
          'pregunta_id TEXT NOT NULL, '
          'motivo TEXT NOT NULL, '
          'comentario TEXT, '
          "estado TEXT NOT NULL DEFAULT 'pendiente', "
          'creado_en INTEGER NOT NULL)',
        );
      } catch (_) {}
    },
  );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final baseDeDatos = AppDatabase();
  ref.onDispose(baseDeDatos.close);
  return baseDeDatos;
});
