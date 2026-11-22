import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/practica/data/practica_libre_repositorio.dart';
import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/shared/database/app_database.dart';

enum FaseSesionLibre { cargando, vacia, respondiendo, explicando, terminada }

@immutable
class EstadoSesionLibre {
  const EstadoSesionLibre({
    this.fase = FaseSesionLibre.cargando,
    this.tema,
    this.preguntas = const [],
    this.indice = 0,
    this.letraElegida,
    this.respuesta,
    this.aciertos = 0,
    this.totalRespondidas = 0,
    this.error,
  });

  final FaseSesionLibre fase;
  final Tema? tema;
  final List<Pregunta> preguntas;
  final int indice;
  final String? letraElegida;
  final RespuestaDelPostulante? respuesta;
  final int aciertos;
  final int totalRespondidas;
  final Object? error;

  Pregunta? get preguntaActual =>
      preguntas.isNotEmpty && indice < preguntas.length
      ? preguntas[indice]
      : null;

  bool get esUltima => preguntas.isNotEmpty && indice == preguntas.length - 1;

  EstadoSesionLibre copyWith({
    FaseSesionLibre? fase,
    Tema? tema,
    List<Pregunta>? preguntas,
    int? indice,
    String? letraElegida,
    RespuestaDelPostulante? respuesta,
    int? aciertos,
    int? totalRespondidas,
    Object? error,
  }) {
    return EstadoSesionLibre(
      fase: fase ?? this.fase,
      tema: tema ?? this.tema,
      preguntas: preguntas ?? this.preguntas,
      indice: indice ?? this.indice,
      letraElegida: letraElegida,
      respuesta: respuesta,
      aciertos: aciertos ?? this.aciertos,
      totalRespondidas: totalRespondidas ?? this.totalRespondidas,
      error: error,
    );
  }
}

class SesionPracticaLibre extends Notifier<EstadoSesionLibre> {
  SesionPracticaLibre(this.temaId);

  final String temaId;
  DateTime? _momentoInicioPregunta;

  @override
  EstadoSesionLibre build() {
    _momentoInicioPregunta = ref.read(relojProvider)();
    return const EstadoSesionLibre();
  }

  PracticaLibreRepositorio get _repositorio =>
      ref.read(practicaLibreRepositorioProvider);
  DateTime Function() get _ahora => ref.read(relojProvider);
  String Function() get _nuevoId => ref.read(generadorDeIdProvider);

  Future<void> cargar() async {
    state = state.copyWith(fase: FaseSesionLibre.cargando);
    try {
      final tema = await _repositorio.obtenerTema(temaId);
      final preguntas = await _repositorio.obtenerPreguntasDeTema(temaId);
      if (preguntas.isEmpty) {
        state = state.copyWith(
          fase: FaseSesionLibre.vacia,
          tema: tema,
          preguntas: const [],
        );
        return;
      }
      _momentoInicioPregunta = _ahora();
      state = state.copyWith(
        fase: FaseSesionLibre.respondiendo,
        tema: tema,
        preguntas: preguntas,
        indice: 0,
        aciertos: 0,
        totalRespondidas: 0,
      );
    } catch (e) {
      state = state.copyWith(fase: FaseSesionLibre.vacia, error: e);
    }
  }

  Future<void> elegir(String letra) async {
    if (state.fase != FaseSesionLibre.respondiendo) return;
    final pregunta = state.preguntaActual;
    if (pregunta == null) return;

    final esCorrecta =
        letra.trim().toUpperCase() == pregunta.respuesta.trim().toUpperCase();
    final respuestaDelPostulante = esCorrecta
        ? RespuestaDelPostulante.correcta
        : RespuestaDelPostulante.incorrecta;
    final inicio = _momentoInicioPregunta ?? _ahora();
    final tiempoMs = _ahora().difference(inicio).inMilliseconds;

    state = state.copyWith(
      fase: FaseSesionLibre.explicando,
      letraElegida: letra,
      respuesta: respuestaDelPostulante,
      aciertos: state.aciertos + (esCorrecta ? 1 : 0),
      totalRespondidas: state.totalRespondidas + 1,
    );

    await _repositorio.registrarRespuestaLibre(
      idEvento: _nuevoId(),
      preguntaId: pregunta.id,
      opcionElegida: letra,
      esCorrecta: esCorrecta,
      tiempoMs: tiempoMs,
      respondidaEn: _ahora(),
    );
  }

  Future<void> noSe() async {
    if (state.fase != FaseSesionLibre.respondiendo) return;
    final pregunta = state.preguntaActual;
    if (pregunta == null) return;

    final inicio = _momentoInicioPregunta ?? _ahora();
    final tiempoMs = _ahora().difference(inicio).inMilliseconds;

    state = state.copyWith(
      fase: FaseSesionLibre.explicando,
      letraElegida: null,
      respuesta: RespuestaDelPostulante.noSe,
      totalRespondidas: state.totalRespondidas + 1,
    );

    await _repositorio.registrarRespuestaLibre(
      idEvento: _nuevoId(),
      preguntaId: pregunta.id,
      opcionElegida: null,
      esCorrecta: false,
      tiempoMs: tiempoMs,
      respondidaEn: _ahora(),
    );
  }

  void siguiente() {
    if (state.fase != FaseSesionLibre.explicando) return;
    final siguienteIndice = state.indice + 1;
    if (siguienteIndice >= state.preguntas.length) {
      state = state.copyWith(fase: FaseSesionLibre.terminada);
    } else {
      _momentoInicioPregunta = _ahora();
      state = state.copyWith(
        fase: FaseSesionLibre.respondiendo,
        indice: siguienteIndice,
        letraElegida: null,
        respuesta: null,
      );
    }
  }

  void reiniciar() {
    if (state.preguntas.isEmpty) {
      cargar();
      return;
    }
    _momentoInicioPregunta = _ahora();
    state = state.copyWith(
      fase: FaseSesionLibre.respondiendo,
      indice: 0,
      letraElegida: null,
      respuesta: null,
      aciertos: 0,
      totalRespondidas: 0,
    );
  }
}

final sesionPracticaLibreProvider =
    NotifierProvider.family<SesionPracticaLibre, EstadoSesionLibre, String>(
      SesionPracticaLibre.new,
    );
