import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/progreso/domain/calcular_progreso.dart';
import 'package:prepion/shared/database/app_database.dart';

/// Lee de la base local lo que necesita el panel de progreso.
class ProgresoRepositorio {
  const ProgresoRepositorio(this._baseDeDatos);

  final AppDatabase _baseDeDatos;

  /// Respuestas con el tema de su pregunta; omite preguntas sin tema.
  Future<List<RespuestaParaProgreso>> respuestas() async {
    final consulta = _baseDeDatos.select(_baseDeDatos.respuestasLocales).join([
      innerJoin(
        _baseDeDatos.preguntas,
        _baseDeDatos.preguntas.id.equalsExp(
          _baseDeDatos.respuestasLocales.preguntaId,
        ),
      ),
    ]);
    final filas = await consulta.get();

    return [
      for (final fila in filas)
        if (fila.read(_baseDeDatos.preguntas.temaId) case final temaId?)
          RespuestaParaProgreso(
            temaId: temaId,
            esCorrecta: fila.read(_baseDeDatos.respuestasLocales.esCorrecta)!,
            // drift devuelve las fechas en hora local.
            respondidaEn: fila
                .read(_baseDeDatos.respuestasLocales.respondidaEn)!
                .toUtc(),
          ),
    ];
  }

  Future<List<TemaParaProgreso>> temas() async {
    final filas = await _baseDeDatos.select(_baseDeDatos.temas).get();
    return [
      for (final fila in filas)
        TemaParaProgreso(
          id: fila.id,
          materia: fila.materia,
          nombre: fila.nombre,
        ),
    ];
  }
}

final progresoRepositorioProvider = Provider<ProgresoRepositorio>(
  (ref) => ProgresoRepositorio(ref.watch(appDatabaseProvider)),
);
