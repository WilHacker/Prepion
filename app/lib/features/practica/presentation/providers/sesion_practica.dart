import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/practica/data/practica_repositorio.dart';
import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/domain/planificador_repaso.dart';
import 'package:prepion/features/practica/domain/racha.dart';
import 'package:prepion/features/practica/domain/sesion_diaria.dart';
import 'package:prepion/shared/database/app_database.dart';
import 'package:uuid/uuid.dart';

/// Hora actual en UTC; se cambia en las pruebas.
final relojProvider = Provider<DateTime Function()>(
  (ref) =>
      () => DateTime.now().toUtc(),
);

/// Identificador único de cada respuesta (el servidor lo usa para no duplicar).
final generadorDeIdProvider = Provider<String Function()>(
  (ref) =>
      () => const Uuid().v4(),
);

final planificadorRepasoProvider = Provider<PlanificadorRepaso>(
  (ref) => PlanificadorRepaso(),
);

/// Meta diaria de preguntas.
// TODO(HU-02): leerla de la configuración que elige el postulante al empezar.
final metaDiariaProvider = Provider<int>((ref) => 10);

enum FaseSesion { cargando, vacia, respondiendo, explicando, terminada }

@immutable
class ResultadoPregunta {
  const ResultadoPregunta({
    required this.preguntaId,
    required this.respuesta,
    required this.tiempoMs,
  });

  final String preguntaId;
  final RespuestaDelPostulante respuesta;
  final int tiempoMs;
}

@immutable
class EstadoSesion {
  const EstadoSesion({
    this.fase = FaseSesion.cargando,
    this.preguntas = const [],
    this.indice = 0,
    this.letraElegida,
    this.respuesta,
    this.resultados = const [],
    this.racha = 0,
  });

  final FaseSesion fase;
  final List<Pregunta> preguntas;
  final int indice;

  /// Letra que tocó el postulante; null si aún no responde o tocó "No sé".
  final String? letraElegida;

  /// Cómo cuenta la respuesta actual (se afina con "Me costó" / "Fue fácil").
  final RespuestaDelPostulante? respuesta;
  final List<ResultadoPregunta> resultados;
  final int racha;

  Pregunta get preguntaActual => preguntas[indice];
  int get aciertos => resultados.where((r) => r.respuesta.esCorrecta).length;
  int get fallos => resultados.length - aciertos;
  int get tiempoTotalMs => resultados.fold(0, (suma, r) => suma + r.tiempoMs);

  EstadoSesion copyWith({
    FaseSesion? fase,
    List<Pregunta>? preguntas,
    int? indice,
    String? letraElegida,
    RespuestaDelPostulante? respuesta,
    List<ResultadoPregunta>? resultados,
    int? racha,
    bool limpiarRespuesta = false,
  }) => EstadoSesion(
    fase: fase ?? this.fase,
    preguntas: preguntas ?? this.preguntas,
    indice: indice ?? this.indice,
    letraElegida: limpiarRespuesta ? null : (letraElegida ?? this.letraElegida),
    respuesta: limpiarRespuesta ? null : (respuesta ?? this.respuesta),
    resultados: resultados ?? this.resultados,
    racha: racha ?? this.racha,
  );
}

/// Lleva el flujo de la práctica diaria: pregunta → explicación → siguiente.
class SesionPractica extends Notifier<EstadoSesion> {
  late DateTime _inicioDePregunta;
  late DateTime _respondidaEn;
  int _tiempoMs = 0;
  bool _guardando = false;

  @override
  EstadoSesion build() => const EstadoSesion();

  /// Arma la sesión del día: repasos vencidos y, si sobra lugar, preguntas nuevas.
  Future<void> iniciar() async {
    state = const EstadoSesion();
    final repositorio = ref.read(practicaRepositorioProvider);
    final ahora = ref.read(relojProvider)();

    final ids = armarSesion(
      tarjetas: await repositorio.tarjetas(),
      nuevas: await repositorio.idsDePreguntasNuevas(),
      ahora: ahora,
      meta: ref.read(metaDiariaProvider),
    );
    final preguntas = await repositorio.preguntasPorId(ids);

    if (preguntas.isEmpty) {
      state = const EstadoSesion(fase: FaseSesion.vacia);
      return;
    }
    _inicioDePregunta = ahora;
    state = EstadoSesion(fase: FaseSesion.respondiendo, preguntas: preguntas);
  }

  void elegir(String letra) {
    if (state.fase != FaseSesion.respondiendo) return;
    final acierta = letra == state.preguntaActual.respuesta;
    _responder(
      letra: letra,
      respuesta: acierta
          ? RespuestaDelPostulante.correcta
          : RespuestaDelPostulante.incorrecta,
    );
  }

  /// Evita adivinar a ciegas: cuenta como fallo, pero sin opción elegida.
  void noSe() {
    if (state.fase != FaseSesion.respondiendo) return;
    _responder(respuesta: RespuestaDelPostulante.noSe);
  }

  /// Afina un acierto: tocar de nuevo el mismo botón lo deshace.
  void marcarDificultad(RespuestaDelPostulante dificultad) {
    final actual = state.respuesta;
    if (state.fase != FaseSesion.explicando ||
        actual == null ||
        !actual.esCorrecta ||
        !dificultad.esCorrecta) {
      return;
    }
    state = state.copyWith(
      respuesta: dificultad == actual
          ? RespuestaDelPostulante.correcta
          : dificultad,
    );
  }

  /// Guarda la respuesta y pasa a la siguiente pregunta o al resumen.
  Future<void> siguiente() async {
    final actual = state;
    final respuesta = actual.respuesta;
    if (actual.fase != FaseSesion.explicando ||
        respuesta == null ||
        _guardando) {
      return;
    }
    _guardando = true;
    try {
      await _guardar(actual, respuesta);
      final resultados = [
        ...actual.resultados,
        ResultadoPregunta(
          preguntaId: actual.preguntaActual.id,
          respuesta: respuesta,
          tiempoMs: _tiempoMs,
        ),
      ];
      if (actual.indice + 1 >= actual.preguntas.length) {
        state = actual.copyWith(
          fase: FaseSesion.terminada,
          resultados: resultados,
          racha: await _racha(),
        );
      } else {
        _inicioDePregunta = ref.read(relojProvider)();
        state = actual.copyWith(
          fase: FaseSesion.respondiendo,
          indice: actual.indice + 1,
          resultados: resultados,
          limpiarRespuesta: true,
        );
      }
    } finally {
      _guardando = false;
    }
  }

  void _responder({required RespuestaDelPostulante respuesta, String? letra}) {
    _respondidaEn = ref.read(relojProvider)();
    _tiempoMs = _respondidaEn.difference(_inicioDePregunta).inMilliseconds;
    state = state.copyWith(
      fase: FaseSesion.explicando,
      letraElegida: letra,
      respuesta: respuesta,
    );
  }

  Future<void> _guardar(
    EstadoSesion actual,
    RespuestaDelPostulante respuesta,
  ) async {
    final repositorio = ref.read(practicaRepositorioProvider);
    final pregunta = actual.preguntaActual;
    final tarjeta = ref
        .read(planificadorRepasoProvider)
        .revisar(
          preguntaId: pregunta.id,
          actual: await repositorio.tarjetaDe(pregunta.id),
          calificacion: respuesta.calificacion,
          ahora: _respondidaEn,
        );
    await repositorio.registrarRespuesta(
      idEvento: ref.read(generadorDeIdProvider)(),
      preguntaId: pregunta.id,
      opcionElegida: actual.letraElegida,
      respuesta: respuesta,
      tiempoMs: _tiempoMs,
      respondidaEn: _respondidaEn,
      tarjeta: tarjeta,
    );
  }

  Future<int> _racha() async => calcularRacha(
    respuestasEn: await ref
        .read(practicaRepositorioProvider)
        .fechasDeRespuestas(),
    hoy: ref.read(relojProvider)(),
  );
}

final sesionPracticaProvider = NotifierProvider<SesionPractica, EstadoSesion>(
  SesionPractica.new,
);
