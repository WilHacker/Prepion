import 'package:flutter/foundation.dart';

import 'package:prepion/features/practica/domain/racha.dart';

/// Lo mínimo de una respuesta que hace falta para el resumen del día.
typedef RegistroRespuesta = ({DateTime respondidaEn, bool esCorrecta});

/// Indicadores del inicio: racha, avance de hoy y precisión histórica.
@immutable
class ResumenHoy {
  const ResumenHoy({
    required this.racha,
    required this.respondidasHoy,
    required this.precision,
  });

  static const vacio = ResumenHoy(racha: 0, respondidasHoy: 0, precision: null);

  final int racha;
  final int respondidasHoy;

  /// Aciertos sobre el total de respuestas (0 a 1); null si aún no responde.
  final double? precision;

  @override
  bool operator ==(Object other) =>
      other is ResumenHoy &&
      other.racha == racha &&
      other.respondidasHoy == respondidasHoy &&
      other.precision == precision;

  @override
  int get hashCode => Object.hash(racha, respondidasHoy, precision);
}

/// Calcula el resumen con el calendario local del postulante.
ResumenHoy calcularResumenHoy({
  required List<RegistroRespuesta> respuestas,
  required DateTime ahora,
}) {
  if (respuestas.isEmpty) return ResumenHoy.vacio;
  final hoy = ahora.toLocal();
  bool esDeHoy(DateTime fecha) {
    final local = fecha.toLocal();
    return local.year == hoy.year &&
        local.month == hoy.month &&
        local.day == hoy.day;
  }

  final aciertos = respuestas.where((r) => r.esCorrecta).length;
  return ResumenHoy(
    racha: calcularRacha(
      respuestasEn: respuestas.map((r) => r.respondidaEn),
      hoy: ahora,
    ),
    respondidasHoy: respuestas.where((r) => esDeHoy(r.respondidaEn)).length,
    precision: aciertos / respuestas.length,
  );
}
