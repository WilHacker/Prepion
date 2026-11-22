import 'package:flutter/foundation.dart';

/// Máximo de elementos por lista aceptado del paquete (dato no confiable).
const maxElementosPaquete = 5000;

/// Rango válido de la dificultad IRT de una pregunta.
const dificultadMinima = -6.0;
const dificultadMaxima = 6.0;

/// El paquete de conocimiento no cumple el formato esperado.
class ParametrosConocimientoInvalidosError implements Exception {
  const ParametrosConocimientoInvalidosError(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'ParametrosConocimientoInvalidosError: $mensaje';
}

/// Parámetros BKT de un tema, las cuatro probabilidades están en (0, 1).
@immutable
class ParametrosBktTema {
  const ParametrosBktTema({
    required this.pInicial,
    required this.pAprendizaje,
    required this.pAdivinar,
    required this.pError,
  });

  final double pInicial;
  final double pAprendizaje;
  final double pAdivinar;
  final double pError;
}

/// Paquete de conocimiento: dificultad por pregunta y BKT por tema.
@immutable
class ParametrosConocimiento {
  const ParametrosConocimiento({
    required this.version,
    required this.dificultadPorPregunta,
    required this.bktPorTema,
    this.origen,
    this.usuarios,
    this.generadoEn,
  });

  /// Valida estrictamente un JSON que viene de la red o del disco.
  factory ParametrosConocimiento.fromJson(Object? json) {
    final raiz = _mapa(json, 'el paquete');
    final version = raiz['version'];
    if (version is! int || version < 0) {
      throw const ParametrosConocimientoInvalidosError(
        'La versión debe ser un entero mayor o igual que cero.',
      );
    }
    return ParametrosConocimiento(
      version: version,
      origen: _textoOpcional(raiz['origen'], 'origen'),
      usuarios: _usuarios(raiz['usuarios']),
      generadoEn: _fecha(raiz['generadoEn']),
      dificultadPorPregunta: _dificultades(raiz['preguntas']),
      bktPorTema: _bkt(raiz['bkt']),
    );
  }

  final int version;

  /// "simulado" o "real"; null si el servidor no lo informó.
  final String? origen;
  final int? usuarios;
  final DateTime? generadoEn;
  final Map<String, double> dificultadPorPregunta;
  final Map<String, ParametrosBktTema> bktPorTema;
}

ParametrosConocimientoInvalidosError _error(String mensaje) =>
    ParametrosConocimientoInvalidosError(mensaje);

Map<String, Object?> _mapa(Object? valor, String que) {
  if (valor is Map<String, Object?>) return valor;
  if (valor is Map) return valor.cast<String, Object?>();
  throw _error('Estructura inesperada: $que debe ser un objeto.');
}

List<Object?> _lista(Object? valor, String que) {
  if (valor is! List) {
    throw _error('Estructura inesperada: $que debe ser una lista.');
  }
  if (valor.length > maxElementosPaquete) {
    throw _error('La lista $que supera $maxElementosPaquete elementos.');
  }
  return valor.cast<Object?>();
}

String? _textoOpcional(Object? valor, String que) {
  if (valor == null) return null;
  if (valor is! String) throw _error('El campo $que debe ser texto.');
  return valor;
}

int? _usuarios(Object? valor) {
  if (valor == null) return null;
  if (valor is! int || valor < 0) {
    throw _error('El campo usuarios debe ser un entero no negativo.');
  }
  return valor;
}

DateTime? _fecha(Object? valor) {
  if (valor == null) return null;
  final fecha = valor is String ? DateTime.tryParse(valor) : null;
  if (fecha == null) throw _error('El campo generadoEn no es una fecha.');
  return fecha;
}

String _id(Object? valor, String que) {
  if (valor is! String || valor.trim().isEmpty) {
    throw _error('Falta el identificador $que.');
  }
  return valor;
}

double _numeroFinito(Object? valor, String que) {
  if (valor is! num || !valor.isFinite) {
    throw _error('El valor $que debe ser un número finito.');
  }
  return valor.toDouble();
}

double _probabilidad(Object? valor, String que) {
  final p = _numeroFinito(valor, que);
  if (p <= 0 || p >= 1) {
    throw _error('La probabilidad $que debe estar en (0, 1).');
  }
  return p;
}

Map<String, double> _dificultades(Object? valor) {
  final resultado = <String, double>{};
  for (final elemento in _lista(valor, 'preguntas')) {
    final fila = _mapa(elemento, 'cada pregunta');
    final id = _id(fila['preguntaId'], 'de la pregunta');
    final dificultad = _numeroFinito(fila['dificultad'], 'dificultad');
    if (dificultad < dificultadMinima || dificultad > dificultadMaxima) {
      throw _error('La dificultad de $id está fuera de [-6, 6].');
    }
    resultado[id] = dificultad;
  }
  return Map.unmodifiable(resultado);
}

Map<String, ParametrosBktTema> _bkt(Object? valor) {
  final resultado = <String, ParametrosBktTema>{};
  for (final elemento in _lista(valor, 'bkt')) {
    final fila = _mapa(elemento, 'cada tema');
    resultado[_id(fila['temaId'], 'del tema')] = ParametrosBktTema(
      pInicial: _probabilidad(fila['pInicial'], 'pInicial'),
      pAprendizaje: _probabilidad(fila['pAprendizaje'], 'pAprendizaje'),
      pAdivinar: _probabilidad(fila['pAdivinar'], 'pAdivinar'),
      pError: _probabilidad(fila['pError'], 'pError'),
    );
  }
  return Map.unmodifiable(resultado);
}
