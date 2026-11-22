import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/prepion_app.dart';
import 'package:prepion/app/router.dart';
import 'package:prepion/features/configuracion/data/repositorio_preferencias_local.dart';
import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:prepion/shared/notifications/notificaciones_servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class _ClienteNotificacionesPrueba implements ClienteNotificaciones {
  _ClienteNotificacionesPrueba({this.permisoConcedido = true});

  bool permisoConcedido;
  int llamadasProgramar = 0;
  int llamadasCancelar = 0;
  int? ultimaHora;
  int? ultimoMinuto;

  @override
  Future<void> inicializar({
    required void Function(String? payload) alTocarNotificacion,
  }) async {}

  @override
  Future<String?> obtenerPayloadDeArranque() async => null;

  @override
  Future<String> obtenerZonaHorariaLocal() async => 'America/La_Paz';

  @override
  Future<bool> solicitarPermiso() async => permisoConcedido;

  @override
  Future<void> programar({
    required int id,
    required String titulo,
    required String cuerpo,
    required tz.TZDateTime fecha,
    required String payload,
    required bool repetirDiariamente,
  }) async {
    llamadasProgramar++;
    ultimaHora = fecha.hour;
    ultimoMinuto = fecha.minute;
  }

  @override
  Future<void> cancelar(int id) async {
    llamadasCancelar++;
  }
}

void main() {
  testWidgets(
    'permite actualizar la meta diaria desde Ajustes conservando el UUID',
    (tester) async {
      // Preparar
      const idExistente = '99999999-aaaa-4bbb-8ccc-dddddddddddd';
      SharedPreferences.setMockInitialValues(<String, Object>{
        ClavesPreferencias.idUsuarioLocal: idExistente,
        ClavesPreferencias.fechaExamen: DateTime(2027, 1, 25).toIso8601String(),
        ClavesPreferencias.metaDiaria: 10,
        ClavesPreferencias.horaEstudio: 19,
        ClavesPreferencias.minutoEstudio: 0,
        ClavesPreferencias.onboardingCompletado: true,
        ClavesPreferencias.recordatorioActivo: true,
      });

      final clienteNotif = _ClienteNotificacionesPrueba();
      final testRouter = crearRouter(initialLocation: '/inicio');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parametrosPublicosProvider.overrideWith(
              (ref) async =>
                  ParametrosPublicos.porDefecto(hoy: DateTime(2026, 11, 22)),
            ),
            notificacionesServicioProvider.overrideWithValue(
              NotificacionesServicio(
                clienteNotif,
                relojLocal: () => DateTime(2026, 11, 22, 12, 0),
              ),
            ),
          ],
          child: PrepionApp(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Actuar: abrir ajustes, cambiar meta a 5 y guardar
      await tester.tap(find.byKey(const Key('boton_ir_ajustes')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chip_meta_5')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('boton_guardar_ajustes')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('boton_guardar_ajustes')));
      await tester.pumpAndSettle();

      // Verificar
      expect(find.text('Meta de hoy: 5 preguntas'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ClavesPreferencias.idUsuarioLocal), idExistente);
      expect(prefs.getInt(ClavesPreferencias.metaDiaria), 5);
      expect(clienteNotif.llamadasProgramar, 1);
      expect(clienteNotif.ultimaHora, 19);
    },
  );

  testWidgets(
    'permite desactivar el recordatorio diario desde Ajustes y cancela la notificación',
    (tester) async {
      // Preparar
      SharedPreferences.setMockInitialValues(<String, Object>{
        ClavesPreferencias.idUsuarioLocal: 'uuid-notif-1',
        ClavesPreferencias.fechaExamen: DateTime(2027, 1, 25).toIso8601String(),
        ClavesPreferencias.metaDiaria: 10,
        ClavesPreferencias.horaEstudio: 19,
        ClavesPreferencias.minutoEstudio: 0,
        ClavesPreferencias.onboardingCompletado: true,
        ClavesPreferencias.recordatorioActivo: true,
      });

      final clienteNotif = _ClienteNotificacionesPrueba();
      final testRouter = crearRouter(initialLocation: '/inicio');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parametrosPublicosProvider.overrideWith(
              (ref) async =>
                  ParametrosPublicos.porDefecto(hoy: DateTime(2026, 11, 22)),
            ),
            notificacionesServicioProvider.overrideWithValue(
              NotificacionesServicio(
                clienteNotif,
                relojLocal: () => DateTime(2026, 11, 22, 12, 0),
              ),
            ),
          ],
          child: PrepionApp(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Actuar: abrir ajustes, apagar recordatorio y guardar
      await tester.tap(find.byKey(const Key('boton_ir_ajustes')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('switch_recordatorio_diario')),
      );
      await tester.tap(find.byKey(const Key('switch_recordatorio_diario')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('boton_guardar_ajustes')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const Key('boton_guardar_ajustes')));
      await tester.pumpAndSettle();

      // Verificar
      expect(find.textContaining('Recordatorio: desactivado'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(ClavesPreferencias.recordatorioActivo), isFalse);
      expect(clienteNotif.llamadasProgramar, 0);
      expect(clienteNotif.llamadasCancelar, 1);
    },
  );

  testWidgets(
    'informa al usuario cuando el sistema deniega el permiso de notificaciones',
    (tester) async {
      // Preparar
      SharedPreferences.setMockInitialValues(<String, Object>{
        ClavesPreferencias.idUsuarioLocal: 'uuid-notif-2',
        ClavesPreferencias.fechaExamen: DateTime(2027, 1, 25).toIso8601String(),
        ClavesPreferencias.metaDiaria: 10,
        ClavesPreferencias.horaEstudio: 19,
        ClavesPreferencias.minutoEstudio: 0,
        ClavesPreferencias.onboardingCompletado: true,
        ClavesPreferencias.recordatorioActivo: false,
      });

      final clienteNotif = _ClienteNotificacionesPrueba(
        permisoConcedido: false,
      );
      final testRouter = crearRouter(initialLocation: '/ajustes');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parametrosPublicosProvider.overrideWith(
              (ref) async =>
                  ParametrosPublicos.porDefecto(hoy: DateTime(2026, 11, 22)),
            ),
            notificacionesServicioProvider.overrideWithValue(
              NotificacionesServicio(
                clienteNotif,
                relojLocal: () => DateTime(2026, 11, 22, 12, 0),
              ),
            ),
          ],
          child: PrepionApp(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Actuar: intentar encender el recordatorio con permiso denegado
      await tester.ensureVisible(
        find.byKey(const Key('switch_recordatorio_diario')),
      );
      await tester.tap(find.byKey(const Key('switch_recordatorio_diario')));
      await tester.pumpAndSettle();

      // Verificar
      expect(
        find.text('Permiso de notificaciones denegado en el sistema.'),
        findsOneWidget,
      );
      final switchWidget = tester.widget<Switch>(
        find.byKey(const Key('switch_recordatorio_diario')),
      );
      expect(switchWidget.value, isFalse);
    },
  );
}
