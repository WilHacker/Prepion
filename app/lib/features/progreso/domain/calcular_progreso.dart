import 'package:flutter/foundation.dart';
import 'package:prepion/features/progreso/domain/bkt.dart';
import 'package:prepion/features/progreso/domain/resumen_progreso.dart';

/// Respuestas mínimas para dar un nivel de preparación.
const minimoRespuestasParaNivel = 10;

const _maxTemasAReforzar = 3;

/// Las 5 materias del examen, en orden.
const _materiasDelExamen = [
  'Aritmética-Álgebra',
  'Geometría-Trigonometría',
  'Física',
  'Química',
  'Biología',
];

@immutable
class RespuestaParaProgreso {
  const RespuestaParaProgreso({
    required this.temaId,
    required this.esCorrecta,
    required this.respondidaEn,
  });

  final String temaId;
  final bool esCorrecta;
  final DateTime respondidaEn;
}

@immutable
class TemaParaProgreso {
  const TemaParaProgreso({
    required this.id,
    required this.materia,
    required this.nombre,
  });

  final String id;
  final String materia;
  final String nombre;
}

double _promedio(Iterable<double> valores) =>
    valores.reduce((a, b) => a + b) / valores.length;

DateTime _soloDia(DateTime fecha) {
  final local = fecha.toLocal();
  return DateTime(local.year, local.month, local.day);
}

int _diasHasta(DateTime ahora, DateTime fechaExamen) {
  final hoy = _soloDia(ahora);
  final examen = _soloDia(fechaExamen);
  // Se compara en UTC para que un cambio de hora no altere el conteo.
  final dias = DateTime.utc(
    examen.year,
    examen.month,
    examen.day,
  ).difference(DateTime.utc(hoy.year, hoy.month, hoy.day)).inDays;
  return dias < 0 ? 0 : dias;
}

List<DominioTema> _dominiosDeTemas(
  List<RespuestaParaProgreso> respuestas,
  List<TemaParaProgreso> temas,
  ParametrosBkt parametros,
  Map<String, ParametrosBkt> parametrosPorTema,
) {
  final porTema = {for (final tema in temas) tema.id: tema};
  final conocidas = respuestas.where((r) => porTema.containsKey(r.temaId));
  final ordenadas = [...conocidas]
    ..sort((a, b) => a.respondidaEn.compareTo(b.respondidaEn));

  final dominios = <String, double>{};
  final conteos = <String, int>{};
  for (final r in ordenadas) {
    final delTema = parametrosPorTema[r.temaId] ?? parametros;
    dominios[r.temaId] = actualizarDominio(
      dominios[r.temaId] ?? delTema.inicial,
      acerto: r.esCorrecta,
      parametros: delTema,
    );
    conteos[r.temaId] = (conteos[r.temaId] ?? 0) + 1;
  }

  return [
    for (final entrada in dominios.entries)
      DominioTema(
        temaId: entrada.key,
        materia: porTema[entrada.key]!.materia,
        nombre: porTema[entrada.key]!.nombre,
        dominio: entrada.value,
        respuestas: conteos[entrada.key]!,
      ),
  ];
}

int _masDebilPrimero(DominioTema a, DominioTema b) {
  final porDominio = a.dominio.compareTo(b.dominio);
  if (porDominio != 0) return porDominio;
  final porRespuestas = b.respuestas.compareTo(a.respuestas);
  if (porRespuestas != 0) return porRespuestas;
  return a.nombre.compareTo(b.nombre);
}

NivelPreparacion _nivelDe(int totalRespuestas, double? dominioGlobal) {
  if (totalRespuestas < minimoRespuestasParaNivel || dominioGlobal == null) {
    return NivelPreparacion.sinDatos;
  }
  return switch (semaforoDe(dominioGlobal)) {
    Semaforo.rojo => NivelPreparacion.bajo,
    Semaforo.amarillo => NivelPreparacion.medio,
    Semaforo.verde => NivelPreparacion.alto,
  };
}

/// Calcula el panel de progreso a partir de las respuestas guardadas.
ResumenProgreso calcularProgreso({
  required List<RespuestaParaProgreso> respuestas,
  required List<TemaParaProgreso> temas,
  required int racha,
  required DateTime ahora,
  DateTime? fechaExamen,
  ParametrosBkt parametros = const ParametrosBkt(),
  Map<String, ParametrosBkt> parametrosPorTema = const {},
}) {
  final dominios = _dominiosDeTemas(
    respuestas,
    temas,
    parametros,
    parametrosPorTema,
  );

  final materias = [
    for (final materia in _materiasDelExamen)
      _materiaDe(materia, dominios.where((d) => d.materia == materia)),
  ];
  // Las materias sin practicar cuentan con el dominio inicial: así el nivel no
  // sube a "alto" por dominar una sola materia.
  final hayDatos = materias.any((m) => m.dominio != null);
  final dominioGlobal = hayDatos
      ? _promedio([for (final m in materias) m.dominio ?? parametros.inicial])
      : null;
  final total = dominios.fold<int>(0, (suma, d) => suma + d.respuestas);

  return ResumenProgreso(
    materias: materias,
    temasAReforzar: ([
      ...dominios,
    ]..sort(_masDebilPrimero)).take(_maxTemasAReforzar).toList(),
    nivel: _nivelDe(total, dominioGlobal),
    racha: racha,
    totalRespuestas: total,
    dominioGlobal: dominioGlobal,
    diasParaElExamen: fechaExamen == null
        ? null
        : _diasHasta(ahora, fechaExamen),
  );
}

DominioMateria _materiaDe(String materia, Iterable<DominioTema> temas) =>
    DominioMateria(
      materia: materia,
      dominio: temas.isEmpty ? null : _promedio(temas.map((t) => t.dominio)),
      respuestas: temas.fold<int>(0, (suma, t) => suma + t.respuestas),
    );
