/// Identificador estable del recordatorio diario local.
const int idRecordatorioDiario = 1001;

/// Ruta de destino al tocar el recordatorio diario.
const String rutaPracticaDiaria = '/practica';

/// Canal de notificación en Android para los recordatorios diarios.
const String canalRecordatorioId = 'prepion_recordatorio_diario';
const String canalRecordatorioNombre = 'Recordatorio diario';
const String canalRecordatorioDescripcion =
    'Aviso diario para completar tu práctica de preparación FCyT.';

/// Datos ya calculados para programar la próxima notificación local.
class PlanRecordatorio {
  const PlanRecordatorio({
    required this.fechaProgramada,
    required this.esRecurrenteDiario,
    required this.titulo,
    required this.cuerpo,
    required this.payload,
  });

  /// Fecha y hora en reloj local para el próximo disparo.
  final DateTime fechaProgramada;

  /// `true` si debe repetirse diariamente a la misma hora.
  /// `false` cuando se posterga la alerta de hoy hacia mañana para evitar que
  /// Android la dispare hoy al evaluar `DateTimeComponents.time`.
  final bool esRecurrenteDiario;

  final String titulo;
  final String cuerpo;
  final String payload;
}

/// Configuración necesaria para sincronizar el recordatorio diario.
class ConfiguracionRecordatorio {
  const ConfiguracionRecordatorio({
    required this.activo,
    required this.hora,
    required this.minuto,
    required this.metaDiaria,
  });

  final bool activo;
  final int hora;
  final int minuto;
  final int metaDiaria;
}

/// Calcula los minutos aproximados de una sesión según la meta diaria.
int minutosEstimadosParaMeta(int metaDiaria) {
  if (metaDiaria <= 5) {
    return 3;
  }
  if (metaDiaria <= 10) {
    return 5;
  }
  return 10;
}

/// Calcula cuándo y cómo programar el recordatorio diario del postulante.
///
/// Si [yaPracticoHoy] es `true` y la hora programada de hoy todavía no pasó,
/// posterga el disparo a mañana sin repetición automática (`esRecurrenteDiario = false`)
/// para que Android no ignore la fecha de mañana al aplicar `matchDateTimeComponents`.
PlanRecordatorio calcularPlanRecordatorio({
  required int hora,
  required int minuto,
  required int metaDiaria,
  required DateTime ahoraLocal,
  bool yaPracticoHoy = false,
}) {
  final horaNormalizada = hora.clamp(0, 23);
  final minutoNormalizado = minuto.clamp(0, 59);
  final metaNormalizada = metaDiaria < 1 ? 10 : metaDiaria;

  final objetivoHoy = DateTime(
    ahoraLocal.year,
    ahoraLocal.month,
    ahoraLocal.day,
    horaNormalizada,
    minutoNormalizado,
  );
  final hoySiguePendiente = objetivoHoy.isAfter(ahoraLocal);

  final DateTime fechaProgramada;
  final bool esRecurrenteDiario;

  if (yaPracticoHoy) {
    fechaProgramada = objetivoHoy.add(const Duration(days: 1));
    esRecurrenteDiario = !hoySiguePendiente;
  } else if (hoySiguePendiente) {
    fechaProgramada = objetivoHoy;
    esRecurrenteDiario = true;
  } else {
    fechaProgramada = objetivoHoy.add(const Duration(days: 1));
    esRecurrenteDiario = true;
  }

  final minutos = minutosEstimadosParaMeta(metaNormalizada);
  return PlanRecordatorio(
    fechaProgramada: fechaProgramada,
    esRecurrenteDiario: esRecurrenteDiario,
    titulo: 'Hora de practicar',
    cuerpo: 'Tus $metaNormalizada preguntas de hoy te esperan ($minutos min)',
    payload: rutaPracticaDiaria,
  );
}

/// Indica si existe al menos una respuesta registrada durante el día local actual.
bool practicoHoy(
  Iterable<DateTime> respuestasEn, {
  required DateTime ahoraLocal,
}) {
  for (final fecha in respuestasEn) {
    final local = fecha.toLocal();
    if (local.year == ahoraLocal.year &&
        local.month == ahoraLocal.month &&
        local.day == ahoraLocal.day) {
      return true;
    }
  }
  return false;
}

/// Resuelve una ruta interna válida desde el payload de la notificación.
String? resolverRutaDesdePayload(String? payload) {
  if (payload == null) {
    return null;
  }
  final limpia = payload.trim();
  if (limpia.isEmpty || !limpia.startsWith('/')) {
    return null;
  }
  return limpia;
}
