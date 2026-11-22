import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/features/practica/data/orden_preguntas.dart';
import 'package:prepion/shared/database/app_database.dart';

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
