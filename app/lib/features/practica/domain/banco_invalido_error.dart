/// El banco de preguntas (semilla o descarga) no tiene el formato esperado.
class BancoInvalidoError implements Exception {
  const BancoInvalidoError(this.mensaje);

  final String mensaje;

  @override
  String toString() => 'BancoInvalidoError: $mensaje';
}
