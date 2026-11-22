const materiasOficiales = ['Matemáticas', 'Física', 'Química', 'Biología'];

const materiasMatematicas = {
  'Matemáticas',
  'Aritmética-Álgebra',
  'Geometría-Trigonometría',
};

String normalizarMateria(String materia) {
  if (materiasMatematicas.contains(materia)) {
    return 'Matemáticas';
  }
  return materia;
}

List<String> materiasDbPara(String materiaOficial) {
  if (materiaOficial == 'Matemáticas') {
    return const [
      'Matemáticas',
      'Aritmética-Álgebra',
      'Geometría-Trigonometría',
    ];
  }
  return [materiaOficial];
}

class ResumenTema {
  const ResumenTema({
    required this.id,
    required this.materia,
    required this.nombre,
    required this.cantidadPreguntas,
    this.porcentajeDominio,
  });

  final String id;
  final String materia;
  final String nombre;
  final int cantidadPreguntas;
  final double? porcentajeDominio;
}

class ResumenMateria {
  const ResumenMateria({
    required this.nombre,
    required this.cantidadPreguntas,
    required this.cantidadTemas,
    this.porcentajeDominio,
  });

  final String nombre;
  final int cantidadPreguntas;
  final int cantidadTemas;
  final double? porcentajeDominio;
}
