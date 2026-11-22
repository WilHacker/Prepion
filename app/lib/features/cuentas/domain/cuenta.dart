const String rolAdmin = 'admin';

/// Cuenta de Prepion: postulante (`usuario`) o administrador (`admin`).
class Cuenta {
  const Cuenta({
    required this.id,
    required this.correo,
    required this.rol,
    required this.creadoEn,
    this.respuestas = 0,
  });

  factory Cuenta.desdeJson(Map<String, Object?> json) => Cuenta(
    id: json['id']! as String,
    correo: json['correo'] as String?,
    rol: json['rol']! as String,
    creadoEn: DateTime.parse(json['creadoEn']! as String),
    respuestas: (json['respuestas'] as int?) ?? 0,
  );

  final String id;
  final String? correo;
  final String rol;
  final DateTime creadoEn;
  final int respuestas;

  bool get esAdmin => rol == rolAdmin;

  Map<String, Object?> aJson() => <String, Object?>{
    'id': id,
    'correo': correo,
    'rol': rol,
    'creadoEn': creadoEn.toIso8601String(),
    'respuestas': respuestas,
  };
}

/// Error de cuentas con un mensaje listo para mostrar al usuario.
class ErrorCuentas implements Exception {
  const ErrorCuentas(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
