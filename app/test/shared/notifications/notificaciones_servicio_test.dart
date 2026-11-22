import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/shared/notifications/notificaciones_servicio.dart';
import 'package:prepion/shared/notifications/planificacion_recordatorio.dart';
import 'package:timezone/timezone.dart' as tz;

class _NotificacionProgramada {
  const _NotificacionProgramada({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.fecha,
    required this.payload,
    required this.repetirDiariamente,
  });

  final int id;
  final String titulo;
  final String cuerpo;
  final tz.TZDateTime fecha;
  final String payload;
  final bool repetirDiariamente;
}

class _ClienteNotificacionesFalso implements ClienteNotificaciones {
  _ClienteNotificacionesFalso({
    this.zonaHoraria = 'America/La_Paz',
    this.payloadArranque,
  });

  final String zonaHoraria;
  final String? payloadArranque;
  bool permisoConcedido = true;

  void Function(String? payload)? alTocar;
  final List<_NotificacionProgramada> programadas = <_NotificacionProgramada>[];
  final List<int> canceladas = <int>[];
  int solicitudesPermiso = 0;

  @override
  Future<void> inicializar({
    required void Function(String? payload) alTocarNotificacion,
  }) async {
    alTocar = alTocarNotificacion;
  }

  @override
  Future<String?> obtenerPayloadDeArranque() async => payloadArranque;

  @override
  Future<String> obtenerZonaHorariaLocal() async => zonaHoraria;

  @override
  Future<bool> solicitarPermiso() async {
    solicitudesPermiso++;
    return permisoConcedido;
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
    programadas.add(
      _NotificacionProgramada(
        id: id,
        titulo: titulo,
        cuerpo: cuerpo,
        fecha: fecha,
        payload: payload,
        repetirDiariamente: repetirDiariamente,
      ),
    );
  }

  @override
  Future<void> cancelar(int id) async {
    canceladas.add(id);
  }
}

void main() {
  test('inicializa zona horaria, devuelve ruta de arranque y redirige al tocar la notificación', () async {
    // Preparar
    final cliente = _ClienteNotificacionesFalso(
      zonaHoraria: 'America/La_Paz',
      payloadArranque: '/practica',
    );
    final servicio = NotificacionesServicio(cliente);
    final rutasAbiertas = <String>[];

    // Actuar
    final rutaInicial = await servicio.inicializar(
      alAbrirRuta: rutasAbiertas.add,
    );
    cliente.alTocar?.call('/practica');
    cliente.alTocar?.call('invalida');

    // Verificar
    expect(rutaInicial, '/practica');
    expect(rutasAbiertas, <String>['/practica']);
    expect(tz.local.name, 'America/La_Paz');
  });

  test(
    'usa UTC como respaldo cuando el identificador de zona horaria no existe',
    () async {
      // Preparar
      final cliente = _ClienteNotificacionesFalso(
        zonaHoraria: 'Zona/Inexistente',
      );
      final servicio = NotificacionesServicio(cliente);

      // Actuar
      await servicio.inicializar(alAbrirRuta: (_) {});

      // Verificar
      expect(tz.local, tz.UTC);
    },
  );

  test(
    'programa la notificación diaria y la cancela al desactivar recordatorios',
    () async {
      // Preparar
      final cliente = _ClienteNotificacionesFalso();
      final servicio = NotificacionesServicio(
        cliente,
        relojLocal: () => DateTime(2026, 11, 22, 10, 0),
      );

      // Actuar: activar y programar
      final permiso = await servicio.solicitarPermiso();
      final plan = await servicio.sincronizarRecordatorioDiario(
        activo: true,
        hora: 19,
        minuto: 15,
        metaDiaria: 10,
      );

      // Verificar programación
      expect(permiso, isTrue);
      expect(cliente.solicitudesPermiso, 1);
      expect(plan, isNotNull);
      expect(cliente.programadas, hasLength(1));
      expect(cliente.programadas.single.id, idRecordatorioDiario);
      expect(cliente.programadas.single.payload, rutaPracticaDiaria);
      expect(cliente.programadas.single.repetirDiariamente, isTrue);
      expect(cliente.programadas.single.fecha.hour, 19);
      expect(cliente.programadas.single.fecha.minute, 15);

      // Actuar: desactivar
      final planDesactivado = await servicio.sincronizarRecordatorioDiario(
        activo: false,
        hora: 19,
        minuto: 15,
        metaDiaria: 10,
      );

      // Verificar cancelación
      expect(planDesactivado, isNull);
      expect(cliente.canceladas.last, idRecordatorioDiario);
    },
  );

  test('pospone el recordatorio de hoy hacia mañana cuando el postulante ya practicó', () async {
    // Preparar
    final cliente = _ClienteNotificacionesFalso();
    final servicio = NotificacionesServicio(
      cliente,
      relojLocal: () => DateTime(2026, 11, 22, 10, 0),
    );
    await servicio.sincronizarRecordatorioDiario(
      activo: true,
      hora: 19,
      minuto: 0,
      metaDiaria: 10,
    );

    // Actuar
    final planPospuesto = await servicio.posponerRecordatorioDeHoy();

    // Verificar
    expect(planPospuesto, isNotNull);
    expect(planPospuesto!.fechaProgramada, DateTime(2026, 11, 23, 19, 0));
    expect(planPospuesto.esRecurrenteDiario, isFalse);
    expect(cliente.programadas, hasLength(2));
    expect(cliente.programadas.last.repetirDiariamente, isFalse);
  });

  test('cancela sin error al posponer si no existía configuración previa o está inactivo', () async {
    // Preparar
    final cliente = _ClienteNotificacionesFalso();
    final servicio = NotificacionesServicio(cliente);

    // Actuar 1: sin configuración previa
    final resultadoSinConfig = await servicio.posponerRecordatorioDeHoy();
    expect(resultadoSinConfig, isNull);
    expect(cliente.canceladas, <int>[idRecordatorioDiario]);

    // Actuar 2: con recordatorio desactivado
    await servicio.sincronizarRecordatorioDiario(
      activo: false,
      hora: 19,
      minuto: 0,
      metaDiaria: 10,
    );
    final canceladasAntes = cliente.canceladas.length;
    final resultadoInactivo = await servicio.posponerRecordatorioDeHoy();

    // Verificar
    expect(resultadoInactivo, isNull);
    expect(cliente.canceladas.length, canceladasAntes);
  });
}
