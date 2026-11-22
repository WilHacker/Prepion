import 'package:prepion/features/practica/domain/tarjeta_repaso.dart';

/// Arma la sesión del día: primero los repasos vencidos (del más atrasado al
/// menos) y, si queda lugar hasta la [meta], preguntas nuevas.
///
/// [nuevas] llega ya en el orden en que deben presentarse. Devuelve ids de
/// pregunta, sin repetir ni pasarse de la meta.
List<String> armarSesion({
  required List<TarjetaRepaso> tarjetas,
  required List<String> nuevas,
  required DateTime ahora,
  required int meta,
}) {
  if (meta <= 0) return const [];

  final vencidas =
      tarjetas.where((tarjeta) => !tarjeta.vence.isAfter(ahora)).toList()
        ..sort((a, b) => a.vence.compareTo(b.vence));

  return List.unmodifiable(
    [...vencidas.map((tarjeta) => tarjeta.preguntaId), ...nuevas].take(meta),
  );
}
