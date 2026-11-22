import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/features/practica/data/orden_preguntas.dart';
import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/domain/intercalar.dart';
import 'package:prepion/features/practica/domain/tarjeta_repaso.dart';
import 'package:prepion/shared/database/app_database.dart';

/// Lee y guarda en la base local lo que necesita la práctica diaria.
class PracticaRepositorio {
  const PracticaRepositorio(this._baseDeDatos);

  final AppDatabase _baseDeDatos;

  Future<List<TarjetaRepaso>> tarjetas() async {
    final filas = await _baseDeDatos.select(_baseDeDatos.tarjetasFsrs).get();
    return filas.map(_aTarjeta).toList();
  }

  Future<TarjetaRepaso?> tarjetaDe(String preguntaId) async {
    final consulta = _baseDeDatos.select(_baseDeDatos.tarjetasFsrs)
      ..where((t) => t.preguntaId.equals(preguntaId));
    final fila = await consulta.getSingleOrNull();
    return fila == null ? null : _aTarjeta(fila);
  }

  /// Preguntas que nunca se practicaron, mezclando materias por turnos.
  ///
  /// Con [dificultad], dentro de cada materia van de más fácil a más difícil;
  /// las de dificultad desconocida quedan al final en el orden del banco.
  Future<List<String>> idsDePreguntasNuevas({
    Map<String, double> dificultad = const {},
  }) async {
    final preguntas = ordenarPorCodigo(
      await _baseDeDatos.select(_baseDeDatos.preguntas).get(),
    );
    final practicadas = (await tarjetas()).map((t) => t.preguntaId).toSet();
    final materiaPorTema = {
      for (final tema in await _baseDeDatos.select(_baseDeDatos.temas).get())
        tema.id: tema.materia,
    };

    final porMateria = <String, List<String>>{};
    for (final pregunta in preguntas) {
      if (practicadas.contains(pregunta.id)) continue;
      final materia = materiaPorTema[pregunta.temaId] ?? '';
      (porMateria[materia] ??= []).add(pregunta.id);
    }
    return intercalar([
      for (final ids in porMateria.values) _masFacilesPrimero(ids, dificultad),
    ]);
  }

  // Orden estable: sort de Dart no lo es, por eso se desempata por posición.
  List<String> _masFacilesPrimero(
    List<String> ids,
    Map<String, double> dificultad,
  ) {
    final posicion = {for (var i = 0; i < ids.length; i++) ids[i]: i};
    return [...ids]..sort((a, b) {
      final da = dificultad[a];
      final db = dificultad[b];
      if (da == null || db == null) {
        if (da == db) return posicion[a]!.compareTo(posicion[b]!);
        return da == null ? 1 : -1;
      }
      final porDificultad = da.compareTo(db);
      return porDificultad != 0
          ? porDificultad
          : posicion[a]!.compareTo(posicion[b]!);
    });
  }

  /// Devuelve las preguntas pedidas, en el mismo orden de [ids].
  Future<List<Pregunta>> preguntasPorId(List<String> ids) async {
    final consulta = _baseDeDatos.select(_baseDeDatos.preguntas)
      ..where((p) => p.id.isIn(ids));
    final porId = {for (final p in await consulta.get()) p.id: p};
    return [for (final id in ids) ?porId[id]];
  }

  /// Guarda la respuesta y la tarjeta de repaso juntas: o quedan las dos o ninguna.
  Future<void> registrarRespuesta({
    required String idEvento,
    required String preguntaId,
    required String? opcionElegida,
    required RespuestaDelPostulante respuesta,
    required int tiempoMs,
    required DateTime respondidaEn,
    required TarjetaRepaso tarjeta,
  }) {
    return _baseDeDatos.transaction(() async {
      await _baseDeDatos
          .into(_baseDeDatos.respuestasLocales)
          .insert(
            RespuestasLocalesCompanion.insert(
              idEvento: idEvento,
              preguntaId: preguntaId,
              opcionElegida: Value(opcionElegida),
              esCorrecta: respuesta.esCorrecta,
              calificacion: respuesta.calificacion.index + 1,
              tiempoMs: tiempoMs,
              respondidaEn: respondidaEn,
            ),
          );
      await _baseDeDatos
          .into(_baseDeDatos.tarjetasFsrs)
          .insertOnConflictUpdate(
            TarjetasFsrsCompanion.insert(
              preguntaId: tarjeta.preguntaId,
              estado: tarjeta.estado,
              paso: Value(tarjeta.paso),
              estabilidad: Value(tarjeta.estabilidad),
              dificultad: Value(tarjeta.dificultad),
              vence: tarjeta.vence,
              ultimaRevision: Value(tarjeta.ultimaRevision),
            ),
          );
      await _baseDeDatos
          .into(_baseDeDatos.colaSincronizacion)
          .insert(
            ColaSincronizacionCompanion.insert(
              idEvento: idEvento,
              preguntaId: preguntaId,
              opcionElegida: Value(opcionElegida),
              esCorrecta: respuesta.esCorrecta,
              tiempoMs: tiempoMs,
              respondidaEn: respondidaEn,
              creadoEn: respondidaEn,
              actualizadoEn: respondidaEn,
            ),
          );
    });
  }

  Future<List<DateTime>> fechasDeRespuestas() async {
    final consulta = _baseDeDatos.selectOnly(_baseDeDatos.respuestasLocales)
      ..addColumns([_baseDeDatos.respuestasLocales.respondidaEn]);
    final filas = await consulta.get();
    return [
      for (final fila in filas)
        fila.read(_baseDeDatos.respuestasLocales.respondidaEn)!.toUtc(),
    ];
  }

  // drift devuelve las fechas en hora local; FSRS trabaja siempre en UTC.
  TarjetaRepaso _aTarjeta(TarjetaFsrs fila) => TarjetaRepaso(
    preguntaId: fila.preguntaId,
    estado: fila.estado,
    paso: fila.paso,
    estabilidad: fila.estabilidad,
    dificultad: fila.dificultad,
    vence: fila.vence.toUtc(),
    ultimaRevision: fila.ultimaRevision?.toUtc(),
  );
}

final practicaRepositorioProvider = Provider<PracticaRepositorio>(
  (ref) => PracticaRepositorio(ref.watch(appDatabaseProvider)),
);
