/// Calificación que entiende el algoritmo de repaso espaciado (FSRS).
enum Calificacion { again, hard, good, easy }

/// Lo que hizo el postulante con una pregunta, tal como se ve en pantalla.
enum RespuestaDelPostulante {
  incorrecta(Calificacion.again),
  noSe(Calificacion.again),
  correctaMeCosto(Calificacion.hard),
  correcta(Calificacion.good),
  correctaFacil(Calificacion.easy);

  const RespuestaDelPostulante(this.calificacion);

  /// Incorrecta o "No sé" = Again; acertar sin tocar nada = Good.
  final Calificacion calificacion;

  bool get esCorrecta =>
      this == correctaMeCosto || this == correcta || this == correctaFacil;
}
