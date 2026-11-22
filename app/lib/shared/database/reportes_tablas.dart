import 'package:drift/drift.dart';

/// Cola local de reportes de preguntas pendientes de sincronizar con el servidor (HU-09).
@DataClassName('ColaReporteFila')
class ColaReportes extends Table {
  TextColumn get id => text()();
  TextColumn get preguntaId => text()();
  TextColumn get motivo => text()();
  TextColumn get comentario => text().nullable()();
  // Estados: 'pendiente', 'enviado', 'fallido'
  TextColumn get estado => text().withDefault(const Constant('pendiente'))();
  DateTimeColumn get creadoEn => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
