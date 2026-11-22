import 'package:flutter/foundation.dart';

/// Parámetros de Bayesian Knowledge Tracing (BKT).
@immutable
class ParametrosBkt {
  const ParametrosBkt({
    this.inicial = 0.3,
    this.aprendizaje = 0.1,
    this.adivinar = 0.2,
    this.error = 0.1,
  });

  /// P(L0): probabilidad de dominar el tema antes de practicar.
  final double inicial;

  /// P(T): probabilidad de aprender el tema tras cada respuesta.
  final double aprendizaje;

  /// P(G): probabilidad de acertar sin dominar el tema (5 opciones).
  final double adivinar;

  /// P(S): probabilidad de fallar dominando el tema.
  final double error;
}

/// Nuevo dominio P(L) del tema tras observar una respuesta.
double actualizarDominio(
  double dominioPrevio, {
  required bool acerto,
  ParametrosBkt parametros = const ParametrosBkt(),
}) {
  final l = dominioPrevio;
  final g = parametros.adivinar;
  final s = parametros.error;

  final conoceYResponde = acerto ? l * (1 - s) : l * s;
  final noConoceYResponde = acerto ? (1 - l) * g : (1 - l) * (1 - g);
  final total = conoceYResponde + noConoceYResponde;
  final posterior = total <= 0 ? l : conoceYResponde / total;

  final siguiente = posterior + (1 - posterior) * parametros.aprendizaje;
  return siguiente.clamp(0.0, 1.0);
}
