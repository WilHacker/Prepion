import 'package:drift/drift.dart';

import 'package:prepion/shared/database/opciones_converter.dart';

/// Exámenes oficiales de origen (por ejemplo 2-2026, 1.ª opción).
@DataClassName('Examen')
class Examenes extends Table {
  TextColumn get id => text()();
  TextColumn get gestion => text()();
  TextColumn get tipo => text()();
  TextColumn get archivo => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Temas de cada materia (Química → Estequiometría).
@DataClassName('Tema')
class Temas extends Table {
  TextColumn get id => text()();
  TextColumn get materia => text()();
  TextColumn get nombre => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {materia, nombre},
  ];
}

/// Preguntas publicadas del banco, listas para practicar sin conexión.
@DataClassName('Pregunta')
class Preguntas extends Table {
  TextColumn get id => text()();
  TextColumn get examenId => text().references(Examenes, #id)();
  // Código dentro del examen: A5, G7, B18…
  TextColumn get codigo => text()();
  TextColumn get temaId => text().nullable().references(Temas, #id)();
  TextColumn get enunciado => text()();
  TextColumn get opciones => text().map(const OpcionesConverter())();
  TextColumn get respuesta => text()();
  TextColumn get explicacion => text()();
  // Ruta del asset con la fórmula o figura recortada, si aplica.
  TextColumn get rutaImagen => text().nullable()();
  // Cita visible, por ejemplo "Examen de ingreso FCyT · 1.ª opción · 2-2026 · B18".
  TextColumn get fuente => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {examenId, codigo},
  ];
}
