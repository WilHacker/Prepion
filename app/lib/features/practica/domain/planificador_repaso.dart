import 'package:fsrs/fsrs.dart' as fsrs;

import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/domain/tarjeta_repaso.dart';

/// Envuelve FSRS para decidir cuándo repasar cada pregunta.
class PlanificadorRepaso {
  /// Sin pasos de minutos y sin "fuzz": lo fallado vuelve al día siguiente y el
  /// resultado es predecible (las pruebas y la demo dan siempre lo mismo).
  /// Una pregunta que ya se sabía y se falla vuelve en 1 día (paso de
  /// reaprendizaje); sin él FSRS la mandaría a unos 3 días.
  PlanificadorRepaso({fsrs.Scheduler? planificador})
    : _planificador =
          planificador ??
          fsrs.Scheduler(
            learningSteps: const [],
            relearningSteps: const [Duration(days: 1)],
            enableFuzzing: false,
          );

  final fsrs.Scheduler _planificador;

  static const _calificaciones = {
    Calificacion.again: fsrs.Rating.again,
    Calificacion.hard: fsrs.Rating.hard,
    Calificacion.good: fsrs.Rating.good,
    Calificacion.easy: fsrs.Rating.easy,
  };

  /// Calcula el nuevo estado de la pregunta tras una respuesta.
  /// [actual] es null si es la primera vez que se ve. [ahora] debe ser UTC.
  TarjetaRepaso revisar({
    required String preguntaId,
    required Calificacion calificacion,
    required DateTime ahora,
    TarjetaRepaso? actual,
  }) {
    // FSRS identifica sus tarjetas con un entero; aquí la identidad es preguntaId.
    final tarjeta = actual == null
        ? fsrs.Card(cardId: 0, due: ahora)
        : fsrs.Card(
            cardId: 0,
            state: fsrs.State.fromValue(actual.estado),
            step: actual.paso,
            stability: actual.estabilidad,
            difficulty: actual.dificultad,
            due: actual.vence,
            lastReview: actual.ultimaRevision,
          );

    final revisada = _planificador
        .reviewCard(
          tarjeta,
          _calificaciones[calificacion]!,
          reviewDateTime: ahora,
        )
        .card;

    return TarjetaRepaso(
      preguntaId: preguntaId,
      estado: revisada.state.value,
      paso: revisada.step,
      estabilidad: revisada.stability,
      dificultad: revisada.difficulty,
      vence: revisada.due,
      ultimaRevision: revisada.lastReview,
    );
  }
}
