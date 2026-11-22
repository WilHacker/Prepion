import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/shared/database/app_database.dart';

final _codigoDeSerie = RegExp(r'^S(\d+)-([A-Z])(\d+)$');

/// Ordena S1-A1, S1-G6, S1-G10, S2-A1…: por serie y número, no por texto
/// (si no, G10 quedaría antes que G6). Lo que no encaja va al final.
List<Pregunta> ordenarPorCodigo(List<Pregunta> preguntas) {
  (int, int)? clave(Pregunta p) {
    final coincidencia = _codigoDeSerie.firstMatch(p.codigo);
    if (coincidencia == null) return null;
    return (int.parse(coincidencia[1]!), int.parse(coincidencia[3]!));
  }

  final ordenadas = [...preguntas]
    ..sort((a, b) {
      final claveA = clave(a);
      final claveB = clave(b);
      if (claveA == null || claveB == null) {
        return claveA == null && claveB == null
            ? a.codigo.compareTo(b.codigo)
            : (claveA == null ? 1 : -1);
      }
      final porSerie = claveA.$1.compareTo(claveB.$1);
      return porSerie != 0 ? porSerie : claveA.$2.compareTo(claveB.$2);
    });
  return List.unmodifiable(ordenadas);
}

/// Preguntas del banco local, en vivo: se actualiza si cambia la base.
final preguntasDelBancoProvider = StreamProvider<List<Pregunta>>(
  (ref) {
    final baseDeDatos = ref.watch(appDatabaseProvider);
    return baseDeDatos
        .select(baseDeDatos.preguntas)
        .watch()
        .map(ordenarPorCodigo);
  },
  // Un fallo al leer la base local no es pasajero: se muestra el error, no se reintenta.
  retry: (reintentos, error) => null,
);
