import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/practica/data/orden_preguntas.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';
import 'package:prepion/shared/database/app_database.dart';

class PracticaLibreRepositorio {
  const PracticaLibreRepositorio(this._baseDeDatos);

  final AppDatabase _baseDeDatos;

  Stream<List<ResumenMateria>> watchMaterias() async* {
    yield await obtenerMaterias();
    await for (final _ in _baseDeDatos.tableUpdates()) {
      yield await obtenerMaterias();
    }
  }

  Future<List<ResumenMateria>> obtenerMaterias() async {
    final todosTemas = await _baseDeDatos.select(_baseDeDatos.temas).get();
    final todasPreguntas = await _baseDeDatos
        .select(_baseDeDatos.preguntas)
        .get();
    final todasRespuestas = await _baseDeDatos
        .select(_baseDeDatos.respuestasLocales)
        .get();

    final temaPorId = {for (final t in todosTemas) t.id: t};
    final preguntasPorMateria = <String, List<Pregunta>>{
      for (final m in materiasOficiales) m: [],
    };
    final temasPorMateria = <String, Set<String>>{
      for (final m in materiasOficiales) m: {},
    };

    for (final p in todasPreguntas) {
      final tema = temaPorId[p.temaId];
      final materia = normalizarMateria(tema?.materia ?? '');
      if (preguntasPorMateria.containsKey(materia)) {
        preguntasPorMateria[materia]!.add(p);
        if (p.temaId != null) {
          temasPorMateria[materia]!.add(p.temaId!);
        }
      }
    }

    for (final t in todosTemas) {
      final materia = normalizarMateria(t.materia);
      if (temasPorMateria.containsKey(materia)) {
        temasPorMateria[materia]!.add(t.id);
      }
    }

    final respuestasPorPregunta = <String, List<RespuestaLocal>>{};
    for (final r in todasRespuestas) {
      (respuestasPorPregunta[r.preguntaId] ??= []).add(r);
    }

    return [
      for (final materia in materiasOficiales)
        () {
          final preguntas = preguntasPorMateria[materia] ?? [];
          final temas = temasPorMateria[materia] ?? {};
          var totalRespuestas = 0;
          var aciertos = 0;
          for (final p in preguntas) {
            final resp = respuestasPorPregunta[p.id] ?? const [];
            totalRespuestas += resp.length;
            aciertos += resp.where((r) => r.esCorrecta).length;
          }
          final double? dominio = totalRespuestas == 0
              ? null
              : aciertos / totalRespuestas;
          return ResumenMateria(
            nombre: materia,
            cantidadPreguntas: preguntas.length,
            cantidadTemas: temas.length,
            porcentajeDominio: dominio,
          );
        }(),
    ];
  }

  Stream<List<ResumenTema>> watchTemasDeMateria(String materiaOficial) async* {
    yield await obtenerTemasDeMateria(materiaOficial);
    await for (final _ in _baseDeDatos.tableUpdates()) {
      yield await obtenerTemasDeMateria(materiaOficial);
    }
  }

  Future<List<ResumenTema>> obtenerTemasDeMateria(String materiaOficial) async {
    final materiasDb = materiasDbPara(materiaOficial);
    final consultaTemas = _baseDeDatos.select(_baseDeDatos.temas)
      ..where((t) => t.materia.isIn(materiasDb))
      ..orderBy([(t) => OrderingTerm(expression: t.nombre)]);
    final temas = await consultaTemas.get();

    final todasPreguntas = await _baseDeDatos
        .select(_baseDeDatos.preguntas)
        .get();
    final todasRespuestas = await _baseDeDatos
        .select(_baseDeDatos.respuestasLocales)
        .get();

    final preguntasPorTema = <String, List<Pregunta>>{};
    for (final p in todasPreguntas) {
      if (p.temaId != null) {
        (preguntasPorTema[p.temaId!] ??= []).add(p);
      }
    }

    final respuestasPorPregunta = <String, List<RespuestaLocal>>{};
    for (final r in todasRespuestas) {
      (respuestasPorPregunta[r.preguntaId] ??= []).add(r);
    }

    final resultado = <ResumenTema>[];
    for (final tema in temas) {
      final preguntas = preguntasPorTema[tema.id] ?? const [];
      var totalRespuestas = 0;
      var aciertos = 0;
      for (final p in preguntas) {
        final resp = respuestasPorPregunta[p.id] ?? const [];
        totalRespuestas += resp.length;
        aciertos += resp.where((r) => r.esCorrecta).length;
      }
      final double? dominio = totalRespuestas == 0
          ? null
          : aciertos / totalRespuestas;
      resultado.add(
        ResumenTema(
          id: tema.id,
          materia: tema.materia,
          nombre: tema.nombre,
          cantidadPreguntas: preguntas.length,
          porcentajeDominio: dominio,
        ),
      );
    }
    return resultado;
  }

  Future<List<Pregunta>> obtenerPreguntasDeTema(String temaId) async {
    final consulta = _baseDeDatos.select(_baseDeDatos.preguntas)
      ..where((p) => p.temaId.equals(temaId));
    return ordenarPorCodigo(await consulta.get());
  }

  Future<Tema?> obtenerTema(String temaId) async {
    final consulta = _baseDeDatos.select(_baseDeDatos.temas)
      ..where((t) => t.id.equals(temaId));
    return consulta.getSingleOrNull();
  }

  Future<void> registrarRespuestaLibre({
    required String idEvento,
    required String preguntaId,
    required String? opcionElegida,
    required bool esCorrecta,
    required int tiempoMs,
    required DateTime respondidaEn,
  }) async {
    await _baseDeDatos
        .into(_baseDeDatos.respuestasLocales)
        .insert(
          RespuestasLocalesCompanion.insert(
            idEvento: idEvento,
            preguntaId: preguntaId,
            opcionElegida: Value(opcionElegida),
            esCorrecta: esCorrecta,
            calificacion: esCorrecta ? 3 : 1,
            tiempoMs: tiempoMs,
            respondidaEn: respondidaEn,
            modo: const Value('libre'),
          ),
        );
  }
}

final practicaLibreRepositorioProvider = Provider<PracticaLibreRepositorio>((
  ref,
) {
  return PracticaLibreRepositorio(ref.watch(appDatabaseProvider));
});
