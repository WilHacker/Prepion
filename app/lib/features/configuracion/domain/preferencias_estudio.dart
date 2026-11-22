const List<int> metasDiariasDisponibles = <int>[5, 10, 20];
const int metaDiariaPorDefecto = 10;
const int horaEstudioPorDefecto = 19;
const int minutoEstudioPorDefecto = 0;

const List<String> _mesesCortos = <String>[
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// Normaliza la meta diaria para garantizar un valor válido positivo.
int normalizarMetaDiaria(int valor) {
  if (valor < 1) {
    return metaDiariaPorDefecto;
  }
  if (valor > 50) {
    return 50;
  }
  return valor;
}

/// Formatea una hora en formato 24h (`HH:mm`).
String formatearHoraEstudio(int hora, int minuto) {
  final h = hora.clamp(0, 23).toString().padLeft(2, '0');
  final m = minuto.clamp(0, 59).toString().padLeft(2, '0');
  return '$h:$m';
}

/// Formatea una fecha en español corto (`25 ene 2027`).
String formatearFechaCorta(DateTime fecha) {
  final mes = _mesesCortos[fecha.month - 1];
  return '${fecha.day} $mes ${fecha.year}';
}

/// Preferencias locales del postulante configuradas en el onboarding o en ajustes.
class PreferenciasEstudio {
  const PreferenciasEstudio({
    required this.idUsuarioLocal,
    required this.fechaExamen,
    required this.metaDiaria,
    required this.horaEstudio,
    required this.minutoEstudio,
    required this.onboardingCompletado,
    this.recordatorioActivo = true,
  });

  final String idUsuarioLocal;
  final DateTime fechaExamen;
  final int metaDiaria;
  final int horaEstudio;
  final int minutoEstudio;
  final bool onboardingCompletado;
  final bool recordatorioActivo;

  String get horaEstudioFormateada =>
      formatearHoraEstudio(horaEstudio, minutoEstudio);

  String get fechaExamenFormateada => formatearFechaCorta(fechaExamen);

  /// Días calendario restantes hasta la fecha tentativa del examen (mínimo 0).
  int diasRestantes({DateTime? hoy}) {
    final referencia = hoy ?? DateTime.now();
    final inicioHoy = DateTime(
      referencia.year,
      referencia.month,
      referencia.day,
    );
    final objetivo = DateTime(
      fechaExamen.year,
      fechaExamen.month,
      fechaExamen.day,
    );
    final diferencia = objetivo.difference(inicioHoy).inDays;
    return diferencia < 0 ? 0 : diferencia;
  }

  PreferenciasEstudio copyWith({
    String? idUsuarioLocal,
    DateTime? fechaExamen,
    int? metaDiaria,
    int? horaEstudio,
    int? minutoEstudio,
    bool? onboardingCompletado,
    bool? recordatorioActivo,
  }) {
    return PreferenciasEstudio(
      idUsuarioLocal: idUsuarioLocal ?? this.idUsuarioLocal,
      fechaExamen: fechaExamen ?? this.fechaExamen,
      metaDiaria: metaDiaria ?? this.metaDiaria,
      horaEstudio: horaEstudio ?? this.horaEstudio,
      minutoEstudio: minutoEstudio ?? this.minutoEstudio,
      onboardingCompletado: onboardingCompletado ?? this.onboardingCompletado,
      recordatorioActivo: recordatorioActivo ?? this.recordatorioActivo,
    );
  }
}
