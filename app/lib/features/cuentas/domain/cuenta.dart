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

/// Cifras generales de la plataforma para el administrador.
class ResumenAdmin {
  const ResumenAdmin({
    required this.usuarios,
    required this.respuestas,
    required this.preguntasPublicadas,
    required this.examenesDescargados,
    this.bancoVersion,
    this.paqueteVersion,
    this.paqueteOrigen,
  });

  factory ResumenAdmin.desdeJson(Map<String, Object?> json) => ResumenAdmin(
    usuarios: json['usuarios']! as int,
    respuestas: json['respuestas']! as int,
    preguntasPublicadas: json['preguntasPublicadas']! as int,
    examenesDescargados: json['examenesDescargados']! as int,
    bancoVersion: json['bancoVersion'] as int?,
    paqueteVersion: json['paqueteVersion'] as int?,
    paqueteOrigen: json['paqueteOrigen'] as String?,
  );

  final int usuarios;
  final int respuestas;
  final int preguntasPublicadas;
  final int examenesDescargados;
  final int? bancoVersion;
  final int? paqueteVersion;
  final String? paqueteOrigen;
}

/// Examen descargado del portal y si el extractor puede leerlo bien.
class ExamenAnalizado {
  const ExamenAnalizado({
    required this.archivo,
    required this.paginas,
    required this.preguntas,
    required this.conCincoOpciones,
    required this.veredicto,
    required this.motivo,
  });

  factory ExamenAnalizado.desdeJson(Map<String, Object?> json) =>
      ExamenAnalizado(
        archivo: json['archivo']! as String,
        paginas: json['paginas']! as int,
        preguntas: json['preguntas']! as int,
        conCincoOpciones: json['conCincoOpciones']! as int,
        veredicto: json['veredicto']! as String,
        motivo: json['motivo']! as String,
      );

  final String archivo;
  final int paginas;
  final int preguntas;
  final int conCincoOpciones;

  /// `curable`, `revisar` o `no_curable`.
  final String veredicto;
  final String motivo;

  bool get esCurable => veredicto != 'no_curable';
}

/// Pregunta extraída de un PDF oficial para previsualizar y publicar al banco.
class PreguntaExtraidaAdmin {
  const PreguntaExtraidaAdmin({
    required this.codigo,
    required this.materia,
    required this.enunciado,
    required this.opciones,
    required this.requiereImagen,
  });

  factory PreguntaExtraidaAdmin.desdeJson(Map<String, Object?> json) =>
      PreguntaExtraidaAdmin(
        codigo: json['codigo']! as String,
        materia: json['materia']! as String,
        enunciado: json['enunciado']! as String,
        opciones: (json['opciones']! as List<dynamic>).cast<String>(),
        requiereImagen: json['requiereImagen']! as bool,
      );

  final String codigo;
  final String materia;
  final String enunciado;
  final List<String> opciones;
  final bool requiereImagen;

  bool get tieneOpcionesTexto =>
      opciones.where((o) => o.trim().isNotEmpty).length >= 2;
}

/// Respuesta del backend al publicar preguntas curadas al banco oficial.
class ResultadoPublicacionExamen {
  const ResultadoPublicacionExamen({
    required this.version,
    required this.agregadas,
    required this.totalBanco,
  });

  factory ResultadoPublicacionExamen.desdeJson(Map<String, Object?> json) =>
      ResultadoPublicacionExamen(
        version: json['version']! as int,
        agregadas: json['agregadas']! as int,
        totalBanco: json['totalBanco']! as int,
      );

  final int version;
  final int agregadas;
  final int totalBanco;
}
