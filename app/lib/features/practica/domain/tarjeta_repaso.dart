import 'package:flutter/foundation.dart';

/// Estado de repaso de una pregunta: cuándo conviene volver a verla.
///
/// Es el estado de FSRS guardado por `preguntaId`; el algoritmo solo calcula.
@immutable
class TarjetaRepaso {
  const TarjetaRepaso({
    required this.preguntaId,
    required this.estado,
    required this.vence,
    this.paso,
    this.estabilidad,
    this.dificultad,
    this.ultimaRevision,
  });

  final String preguntaId;

  /// 1 = aprendiendo, 2 = repaso, 3 = reaprendiendo (valores de FSRS).
  final int estado;
  final int? paso;

  /// Días que tarda la memoria en caer al 90 % (S de FSRS).
  final double? estabilidad;

  /// Qué tan difícil es la pregunta para esta persona (D de FSRS).
  final double? dificultad;

  /// Cuándo toca repasarla (UTC).
  final DateTime vence;
  final DateTime? ultimaRevision;

  @override
  bool operator ==(Object other) =>
      other is TarjetaRepaso &&
      other.preguntaId == preguntaId &&
      other.estado == estado &&
      other.paso == paso &&
      other.estabilidad == estabilidad &&
      other.dificultad == dificultad &&
      other.vence == vence &&
      other.ultimaRevision == ultimaRevision;

  @override
  int get hashCode => Object.hash(
    preguntaId,
    estado,
    paso,
    estabilidad,
    dificultad,
    vence,
    ultimaRevision,
  );
}
