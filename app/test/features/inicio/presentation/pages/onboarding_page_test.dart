import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/prepion_app.dart';
import 'package:prepion/app/router.dart';
import 'package:prepion/features/configuracion/data/repositorio_preferencias_local.dart';
import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const uuidFijo = 'a0b1c2d3-e4f5-4678-9abc-def012345678';

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'entra a estudiar en menos de 3 taps guardando UUID local en shared_preferences',
    (tester) async {
      // Preparar
      final testRouter = crearRouter(initialLocation: '/onboarding');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            generadorUuidProvider.overrideWithValue(() => uuidFijo),
            parametrosPublicosProvider.overrideWith(
              (ref) async =>
                  ParametrosPublicos.porDefecto(hoy: DateTime(2026, 11, 22)),
            ),
          ],
          child: PrepionApp(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar estado inicial: sin campos de datos personales obligatorios
      expect(find.text('ENFOQUE FCyT'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      // Actuar (Tap 1: elegir 20 preguntas, Tap 2: Empezar a practicar ahora)
      await tester.tap(find.byKey(const Key('chip_meta_20')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('boton_empezar_practicar')),
      );
      await tester.tap(find.byKey(const Key('boton_empezar_practicar')));
      await tester.pumpAndSettle();

      // Verificar navegación a InicioPage y persistencia local
      expect(find.text('Meta de hoy: 20 preguntas'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ClavesPreferencias.idUsuarioLocal), uuidFijo);
      expect(prefs.getInt(ClavesPreferencias.metaDiaria), 20);
      expect(prefs.getBool(ClavesPreferencias.onboardingCompletado), isTrue);
    },
  );

  testWidgets(
    'permite navegar por el carrusel explicativo tocando los indicadores',
    (tester) async {
      // Preparar
      final testRouter = crearRouter(initialLocation: '/onboarding');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parametrosPublicosProvider.overrideWith(
              (ref) async =>
                  ParametrosPublicos.porDefecto(hoy: DateTime(2026, 11, 22)),
            ),
          ],
          child: PrepionApp(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Actuar: avanzar con la flecha siguiente y luego tocar el indicador 3
      await tester.tap(find.byKey(const Key('boton_slide_siguiente')));
      await tester.pumpAndSettle();
      expect(find.text('PRÁCTICA INTELIGENTE'), findsOneWidget);

      await tester.tap(find.byKey(const Key('indicador_slide_2')));
      await tester.pumpAndSettle();

      // Verificar
      expect(find.text('100 % OFFLINE'), findsOneWidget);

      await tester.tap(find.byKey(const Key('boton_slide_anterior')));
      await tester.pumpAndSettle();
      expect(find.text('PRÁCTICA INTELIGENTE'), findsOneWidget);
    },
  );

  testWidgets(
    'navega a la opción secundaria de inicio de sesión y permite volver',
    (tester) async {
      // Preparar
      final testRouter = crearRouter(initialLocation: '/onboarding');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parametrosPublicosProvider.overrideWith(
              (ref) async =>
                  ParametrosPublicos.porDefecto(hoy: DateTime(2026, 11, 22)),
            ),
          ],
          child: PrepionApp(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Actuar
      await tester.ensureVisible(
        find.byKey(const Key('boton_ya_tengo_cuenta')),
      );
      await tester.tap(find.byKey(const Key('boton_ya_tengo_cuenta')));
      await tester.pumpAndSettle();

      // Verificar pantalla secundaria y regreso
      expect(find.text('Tu cuenta es opcional'), findsOneWidget);
      await tester.tap(find.text('Volver y empezar sin cuenta'));
      await tester.pumpAndSettle();
      expect(find.text('Empezar a practicar ahora'), findsOneWidget);
    },
  );

  testWidgets(
    'no desborda el carrusel en pantallas angostas o con texto ampliado',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final testRouter = crearRouter(initialLocation: '/onboarding');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parametrosPublicosProvider.overrideWith(
              (ref) async =>
                  ParametrosPublicos.porDefecto(hoy: DateTime(2026, 11, 22)),
            ),
          ],
          child: PrepionApp(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('boton_slide_siguiente')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('boton_slide_siguiente')));
      await tester.pumpAndSettle();
    },
  );
}
