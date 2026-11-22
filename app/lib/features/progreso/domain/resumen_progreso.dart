import 'package:flutter/foundation.dart';

/// Nivel de preparación estimado. [sinDatos] cuando aún hay muy pocas respuestas.
enum NivelPreparacion { sinDatos, bajo, medio, alto }

/// Color de atención de un tema o materia.
enum Semaforo { rojo, amarillo, verde }

/// Por debajo de este dominio un tema está en rojo.
const umbralRojo = 0.4;

/// Desde este dominio un tema está en verde (entre ambos, amarillo).
const umbralVerde = 0.7;

Semaforo semaforoDe(double dominio) {
  if (dominio < umbralRojo) return Semaforo.rojo;
  if (dominio < umbralVerde) return Semaforo.amarillo;
  return Semaforo.verde;
}

/// Qué tan dominado tiene el postulante un tema (probabilidad BKT, de 0 a 1).
@immutable
class DominioTema {
  const DominioTema({
    required this.temaId,
    required this.materia,
    required this.nombre,
    required this.dominio,
    required this.respuestas,
  });

  final String temaId;
  final String materia;
  final String nombre;

  /// P(L) de BKT: de 0 (nada) a 1 (dominado).
  final double dominio;

  /// Cuántas respuestas respaldan este dominio.
  final int respuestas;
}

/// Dominio de una de las 5 materias del examen.
@immutable
class DominioMateria {
  const DominioMateria({
    required this.materia,
    required this.respuestas,
    this.dominio,
  });

  final String materia;

  /// Promedio del dominio de sus temas practicados; null si aún no practicó.
  final double? dominio;
  final int respuestas;
}

/// Todo lo que muestra el panel de progreso.
@immutable
class ResumenProgreso {
  const ResumenProgreso({
    required this.materias,
    required this.temasAReforzar,
    required this.nivel,
    required this.racha,
    required this.totalRespuestas,
    this.dominioGlobal,
    this.diasParaElExamen,
  });

  /// Una entrada por materia, en el orden del examen (con o sin datos).
  final List<DominioMateria> materias;

  /// Hasta 3 temas con menor dominio (solo los ya practicados), del más débil al más fuerte.
  final List<DominioTema> temasAReforzar;
  final NivelPreparacion nivel;

  /// Días seguidos practicando.
  final int racha;
  final int totalRespuestas;

  /// Promedio del dominio de las 5 materias; las que aún no practicó cuentan con el
  /// dominio inicial (0,3) para no inflar el nivel. Null si no hay ninguna respuesta.
  final double? dominioGlobal;

  /// Días que faltan para el examen; null si el postulante no configuró la fecha.
  final int? diasParaElExamen;
}
