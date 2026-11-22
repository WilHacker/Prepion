import 'package:drift/drift.dart';

import 'package:prepion/shared/database/banco_tablas.dart';

/// Cola local de eventos de respuesta pendientes de sincronizar con el servidor (HU-08).
@DataClassName('ColaSincronizacionFila')
class ColaSincronizacion extends Table {
  // Coincide con idEvento de RespuestasLocales (UUID generado en el cliente)
  TextColumn get idEvento => text()();
  TextColumn get preguntaId => text().references(Preguntas, #id)();
  TextColumn get opcionElegida => text().nullable()();
  BoolColumn get esCorrecta => boolean()();
  IntColumn get tiempoMs => integer()();
  DateTimeColumn get respondidaEn => dateTime()();

  // Estados: 'pendiente', 'enviado', 'fallido'
  TextColumn get estado => text().withDefault(const Constant('pendiente'))();
  IntColumn get intentos => integer().withDefault(const Constant(0))();
  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {idEvento};
}
