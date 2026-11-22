import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/features/progreso/domain/resumen_hoy.dart';
import 'package:prepion/shared/database/app_database.dart';

/// Respuestas guardadas en el celular, en vivo: cambia al responder.
final registrosDeRespuestasProvider = StreamProvider<List<RegistroRespuesta>>((
  ref,
) {
  final baseDeDatos = ref.watch(appDatabaseProvider);
  return baseDeDatos
      .select(baseDeDatos.respuestasLocales)
      .watch()
      .map(
        (filas) => [
          for (final fila in filas)
            (respondidaEn: fila.respondidaEn, esCorrecta: fila.esCorrecta),
        ],
      );
}, retry: (reintentos, error) => null);

/// Racha, respondidas hoy y precisión para las tarjetas del inicio.
final resumenHoyProvider = Provider<AsyncValue<ResumenHoy>>((ref) {
  final ahora = ref.watch(relojProvider)();
  return ref
      .watch(registrosDeRespuestasProvider)
      .whenData(
        (respuestas) =>
            calcularResumenHoy(respuestas: respuestas, ahora: ahora),
      );
});
