/// Toma un elemento de cada grupo por turno: [[a1, a2], [q1]] → [a1, q1, a2].
///
/// Se usa para que una sesión mezcle materias en lugar de agotar una por una.
List<T> intercalar<T>(List<List<T>> grupos) {
  final resultado = <T>[];
  final largoMaximo = grupos.fold(
    0,
    (mayor, g) => g.length > mayor ? g.length : mayor,
  );
  for (var posicion = 0; posicion < largoMaximo; posicion++) {
    for (final grupo in grupos) {
      if (posicion < grupo.length) resultado.add(grupo[posicion]);
    }
  }
  return List.unmodifiable(resultado);
}
