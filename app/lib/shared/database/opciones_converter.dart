import 'dart:convert';

import 'package:drift/drift.dart';

/// Guarda la lista de opciones (A–E) como texto JSON, conservando el orden.
class OpcionesConverter extends TypeConverter<List<String>, String> {
  const OpcionesConverter();

  @override
  List<String> fromSql(String fromDb) {
    final decodificado = jsonDecode(fromDb) as List<dynamic>;
    return List.unmodifiable(decodificado.cast<String>());
  }

  @override
  String toSql(List<String> value) => jsonEncode(value);
}
