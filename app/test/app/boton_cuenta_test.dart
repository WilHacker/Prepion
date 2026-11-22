import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/boton_cuenta.dart';
import 'package:prepion/features/cuentas/data/repositorio_cuentas.dart';
import 'package:prepion/features/cuentas/presentation/providers/cuentas_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _guardada(String rol, String correo) =>
    '{"id":"i","correo":"$correo","rol":"$rol","creadoEn":"2026-11-22T19:43:00Z","respuestas":0}';

void main() {
  Future<void> montar(
    WidgetTester t, {
    Map<String, Object> inicial = const {},
  }) async {
    SharedPreferences.setMockInitialValues(inicial);
    final prefs = await SharedPreferences.getInstance();
    final router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) =>
              Scaffold(appBar: AppBar(actions: const [BotonCuenta()])),
        ),
        GoRoute(
          path: '/iniciar-sesion',
          builder: (_, _) => const Text('PANTALLA LOGIN'),
        ),
        GoRoute(
          path: '/registro',
          builder: (_, _) => const Text('PANTALLA REGISTRO'),
        ),
        GoRoute(
          path: '/admin',
          builder: (_, _) => const Text('PANTALLA ADMIN'),
        ),
      ],
    );
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          repositorioCuentasProvider.overrideWith(
            (ref) async => RepositorioCuentas(prefs, Dio()),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> abrir(WidgetTester t) async {
    await t.tap(find.byKey(const Key('boton_cuenta')));
    await t.pumpAndSettle();
  }

  testWidgets(
    'sin sesión se muestra como invitado y ofrece entrar o registrarse',
    (t) async {
      await montar(t);
      await abrir(t);

      expect(find.text('Invitado'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsNothing);
    },
  );

  testWidgets('invitado llega al login y al registro desde el menú', (t) async {
    await montar(t);
    await abrir(t);
    await t.tap(find.text('Iniciar sesión'));
    await t.pumpAndSettle();
    expect(find.text('PANTALLA LOGIN'), findsOneWidget);

    await montar(t);
    await abrir(t);
    await t.tap(find.text('Crear cuenta'));
    await t.pumpAndSettle();
    expect(find.text('PANTALLA REGISTRO'), findsOneWidget);
  });

  testWidgets('con sesión muestra el correo y permite cerrar sesión', (
    t,
  ) async {
    await montar(
      t,
      inicial: {
        claveTokenCuenta: 't',
        claveDatosCuenta: _guardada('usuario', 'ana@correo.com'),
      },
    );
    await abrir(t);

    expect(find.text('ana@correo.com'), findsOneWidget);
    expect(find.text('Panel de administración'), findsNothing);

    await t.tap(find.text('Cerrar sesión'));
    await t.pumpAndSettle();
    await abrir(t);
    expect(find.text('Invitado'), findsOneWidget);
  });

  testWidgets('el administrador ve el acceso al panel', (t) async {
    await montar(
      t,
      inicial: {
        claveTokenCuenta: 't',
        claveDatosCuenta: _guardada('admin', 'admin@prepion.bo'),
      },
    );
    await abrir(t);

    await t.tap(find.text('Panel de administración'));
    await t.pumpAndSettle();

    expect(find.text('PANTALLA ADMIN'), findsOneWidget);
  });
}
