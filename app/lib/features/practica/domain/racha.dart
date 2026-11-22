/// Días seguidos practicando, contando hasta [hoy] (calendario del usuario).
///
/// Si hoy todavía no se practicó pero ayer sí, la racha sigue viva.
int calcularRacha({
  required Iterable<DateTime> respuestasEn,
  required DateTime hoy,
}) {
  DateTime soloDia(DateTime fecha) {
    final local = fecha.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  final dias = respuestasEn.map(soloDia).toSet();
  var dia = soloDia(hoy);
  if (!dias.contains(dia)) dia = DateTime(dia.year, dia.month, dia.day - 1);

  var racha = 0;
  while (dias.contains(dia)) {
    racha++;
    dia = DateTime(dia.year, dia.month, dia.day - 1);
  }
  return racha;
}
