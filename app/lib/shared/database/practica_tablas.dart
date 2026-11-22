import 'package:drift/drift.dart';

import 'package:prepion/shared/database/banco_tablas.dart';

/// Cuándo toca repasar cada pregunta (estado de FSRS, una fila por pregunta).
@DataClassName('TarjetaFsrs')
class TarjetasFsrs extends Table {
  TextColumn get preguntaId => text().references(Preguntas, #id)();
  // 1 = aprendiendo, 2 = repaso, 3 = reaprendiendo.
  IntColumn get estado => integer()();
  IntColumn get paso => integer().nullable()();
  RealColumn get estabilidad => real().nullable()();
  RealColumn get dificultad => real().nullable()();
  DateTimeColumn get vence => dateTime()();
  DateTimeColumn get ultimaRevision => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {preguntaId};
}

/// Cada respuesta del postulante; luego se envían en lote al servidor (HU-08).
@DataClassName('RespuestaLocal')
class RespuestasLocales extends Table {
  // UUID generado en el celular: el servidor lo usa para no duplicar.
  TextColumn get idEvento => text()();
  TextColumn get preguntaId => text().references(Preguntas, #id)();
  // Letra elegida (A–E); null cuando tocó "No sé".
  TextColumn get opcionElegida => text().nullable()();
  BoolColumn get esCorrecta => boolean()();
  // 1 = again, 2 = hard, 3 = good, 4 = easy (valores de FSRS).
  IntColumn get calificacion => integer()();
  IntColumn get tiempoMs => integer()();
  DateTimeColumn get respondidaEn => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {idEvento};
}
