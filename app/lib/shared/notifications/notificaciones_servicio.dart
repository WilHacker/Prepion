import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:prepion/shared/notifications/planificacion_recordatorio.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Adaptador mínimo sobre el plugin de notificaciones para facilitar pruebas unitarias.
abstract interface class ClienteNotificaciones {
  Future<void> inicializar({
    required void Function(String? payload) alTocarNotificacion,
  });

  Future<String?> obtenerPayloadDeArranque();

  Future<String> obtenerZonaHorariaLocal();

  Future<bool> solicitarPermiso();

  Future<void> programar({
    required int id,
    required String titulo,
    required String cuerpo,
    required tz.TZDateTime fecha,
    required String payload,
    required bool repetirDiariamente,
  });

  Future<void> cancelar(int id);
}

/// Implementación real respaldada por `flutter_local_notifications` y `flutter_timezone`.
class ClienteNotificacionesLocal implements ClienteNotificaciones {
  ClienteNotificacionesLocal([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  bool get _pluginDisponible {
    try {
      _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return true;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> inicializar({
    required void Function(String? payload) alTocarNotificacion,
  }) async {
    const ajustes = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    try {
      await _plugin.initialize(
        settings: ajustes,
        onDidReceiveNotificationResponse: (respuesta) {
          alTocarNotificacion(respuesta.payload);
        },
      );
    } on Object {
      // En pruebas sin canal nativo o si el sistema no soporta notificaciones,
      // la app continúa funcionando sin bloquearse.
    }
  }

  @override
  Future<String?> obtenerPayloadDeArranque() async {
    try {
      final detalles = await _plugin.getNotificationAppLaunchDetails();
      if (detalles != null && detalles.didNotificationLaunchApp) {
        return detalles.notificationResponse?.payload;
      }
    } on Object {
      return null;
    }
    return null;
  }

  @override
  Future<String> obtenerZonaHorariaLocal() async {
    if (!_pluginDisponible) {
      return 'UTC';
    }
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      return info.identifier;
    } on Object {
      return 'UTC';
    }
  }

  @override
  Future<bool> solicitarPermiso() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final concedido = await android?.requestNotificationsPermission();
        return concedido ?? true;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final concedido = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return concedido ?? true;
      }
      return true;
    } on Object {
      return true;
    }
  }

  @override
  Future<void> programar({
    required int id,
    required String titulo,
    required String cuerpo,
    required tz.TZDateTime fecha,
    required String payload,
    required bool repetirDiariamente,
  }) async {
    const detalles = NotificationDetails(
      android: AndroidNotificationDetails(
        canalRecordatorioId,
        canalRecordatorioNombre,
        channelDescription: canalRecordatorioDescripcion,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: titulo,
        body: cuerpo,
        scheduledDate: fecha,
        notificationDetails: detalles,
        // Alarma inexacta: suficiente para recordatorio diario y evita exigir
        // SCHEDULE_EXACT_ALARM en Android 14+.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: repetirDiariamente
            ? DateTimeComponents.time
            : null,
      );
    } on Object {
      // No bloquea el uso offline de la app en pruebas o sin canal nativo.
    }
  }

  @override
  Future<void> cancelar(int id) async {
    try {
      await _plugin.cancel(id: id);
    } on Object {
      // No bloquea el uso offline de la app en pruebas o sin canal nativo.
    }
  }
}

/// Coordina permisos, zonas horarias, programación y cancelación del recordatorio diario.
class NotificacionesServicio {
  NotificacionesServicio(this._cliente, {DateTime Function()? relojLocal})
    : _relojLocal = relojLocal ?? DateTime.now;

  final ClienteNotificaciones _cliente;
  final DateTime Function() _relojLocal;
  bool _zonasInicializadas = false;
  ConfiguracionRecordatorio? _ultimaConfiguracion;

  /// Inicializa zonas horarias y el plugin; devuelve la ruta inicial si la app
  /// se abrió tocando una notificación.
  Future<String?> inicializar({
    required void Function(String ruta) alAbrirRuta,
  }) async {
    await _asegurarZonasHorarias();
    await _cliente.inicializar(
      alTocarNotificacion: (payload) {
        final ruta = resolverRutaDesdePayload(payload);
        if (ruta != null) {
          alAbrirRuta(ruta);
        }
      },
    );
    final payloadArranque = await _cliente.obtenerPayloadDeArranque();
    return resolverRutaDesdePayload(payloadArranque);
  }

  /// Solicita permiso de notificaciones al sistema operativo (Android 13+ / iOS).
  Future<bool> solicitarPermiso() => _cliente.solicitarPermiso();

  /// Programa o cancela el recordatorio diario según la configuración vigente.
  Future<PlanRecordatorio?> sincronizarRecordatorioDiario({
    required bool activo,
    required int hora,
    required int minuto,
    required int metaDiaria,
    bool yaPracticoHoy = false,
  }) async {
    _ultimaConfiguracion = ConfiguracionRecordatorio(
      activo: activo,
      hora: hora,
      minuto: minuto,
      metaDiaria: metaDiaria,
    );

    if (!activo) {
      await cancelarRecordatorioDiario();
      return null;
    }

    await _asegurarZonasHorarias();
    final plan = calcularPlanRecordatorio(
      hora: hora,
      minuto: minuto,
      metaDiaria: metaDiaria,
      ahoraLocal: _relojLocal(),
      yaPracticoHoy: yaPracticoHoy,
    );

    await _cliente.cancelar(idRecordatorioDiario);
    final fechaTz = tz.TZDateTime(
      tz.local,
      plan.fechaProgramada.year,
      plan.fechaProgramada.month,
      plan.fechaProgramada.day,
      plan.fechaProgramada.hour,
      plan.fechaProgramada.minute,
    );
    await _cliente.programar(
      id: idRecordatorioDiario,
      titulo: plan.titulo,
      cuerpo: plan.cuerpo,
      fecha: fechaTz,
      payload: plan.payload,
      repetirDiariamente: plan.esRecurrenteDiario,
    );
    return plan;
  }

  /// Omite el recordatorio restante del día actual cuando el postulante ya
  /// completó su práctica diaria, manteniendo el aviso para mañana.
  Future<PlanRecordatorio?> posponerRecordatorioDeHoy() async {
    final config = _ultimaConfiguracion;
    if (config == null) {
      await cancelarRecordatorioDiario();
      return null;
    }
    if (!config.activo) {
      return null;
    }
    return sincronizarRecordatorioDiario(
      activo: true,
      hora: config.hora,
      minuto: config.minuto,
      metaDiaria: config.metaDiaria,
      yaPracticoHoy: true,
    );
  }

  /// Cancela cualquier recordatorio diario programado.
  Future<void> cancelarRecordatorioDiario() {
    return _cliente.cancelar(idRecordatorioDiario);
  }

  Future<void> _asegurarZonasHorarias() async {
    if (_zonasInicializadas) {
      return;
    }
    tz_data.initializeTimeZones();
    final identificador = await _cliente.obtenerZonaHorariaLocal();
    try {
      tz.setLocalLocation(tz.getLocation(identificador));
    } on tz.LocationNotFoundException {
      tz.setLocalLocation(tz.UTC);
    }
    _zonasInicializadas = true;
  }
}

/// Servicio compartido de notificaciones locales para toda la app.
final notificacionesServicioProvider = Provider<NotificacionesServicio>(
  (ref) => NotificacionesServicio(ClienteNotificacionesLocal()),
);
