import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/cuentas/data/repositorio_cuentas.dart';
import 'package:prepion/features/cuentas/presentation/pages/acceso_page.dart';
import 'package:prepion/features/cuentas/presentation/pages/admin_page.dart';
import 'package:prepion/features/cuentas/presentation/providers/cuentas_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, Object?> _cuenta(String rol, String correo) => <String, Object?>{
  'id': 'id-$correo',
  'correo': correo,
  'rol': rol,
  'esAnonimo': false,
  'creadoEn': '2026-11-22T19:43:00Z',
  'respuestas': 2,
};

void main() {
  late SharedPreferences prefs;

  /// Servidor falso: login según el correo, y lista de usuarios para el admin.
  Future<ProviderScope> montar(
    Widget Function() pagina, {
    Map<String, Object> inicial = const {},
  }) async {
    SharedPreferences.setMockInitialValues(inicial);
    prefs = await SharedPreferences.getInstance();
    final dio = Dio(BaseOptions(baseUrl: 'http://x/api'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == '/admin/usuarios') {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: <Object?>[
                    _cuenta('admin', 'admin@prepion.bo'),
                    _cuenta('usuario', 'ana@correo.com'),
                  ],
                ),
              );
              return;
            }
            final datos = options.data as Map;
            if (datos['contrasena'] != 'clave-correcta') {
              handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response(
                    requestOptions: options,
                    statusCode: 401,
                    data: <String, Object?>{
                      'detail': 'Correo o contraseña incorrectos.',
                    },
                  ),
                ),
              );
              return;
            }
            final rol = datos['correo'] == 'admin@prepion.bo'
                ? 'admin'
                : 'usuario';
            handler.resolve(
              Response(
                requestOptions: options,
                data: <String, Object?>{
                  'token': 't',
                  'cuenta': _cuenta(rol, datos['correo'] as String),
                },
              ),
            );
          },
        ),
      );
    final router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('INICIO')),
        ),
        GoRoute(path: '/iniciar-sesion', builder: (_, _) => const AccesoPage()),
        GoRoute(
          path: '/registro',
          builder: (_, _) => const AccesoPage(esRegistro: true),
        ),
        GoRoute(path: '/admin', builder: (_, _) => const AdminPage()),
      ],
      initialLocation: '/iniciar-sesion',
    );
    _router = router;
    return ProviderScope(
      overrides: [
        repositorioCuentasProvider.overrideWith(
          (ref) async => RepositorioCuentas(prefs, dio),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  Future<void> escribir(WidgetTester t, String correo, String clave) async {
    await t.enterText(find.byKey(const Key('campo_correo')), correo);
    await t.enterText(find.byKey(const Key('campo_contrasena')), clave);
    await t.tap(find.byKey(const Key('boton_enviar_acceso')));
    await t.pumpAndSettle();
  }

  testWidgets('un postulante inicia sesión y vuelve al inicio', (t) async {
    await t.pumpWidget(await montar(() => const AccesoPage()));
    await t.pumpAndSettle();

    await escribir(t, 'ana@correo.com', 'clave-correcta');

    expect(find.text('INICIO'), findsOneWidget);
  });

  testWidgets(
    'el administrador entra directo al panel y ve a todos los usuarios',
    (t) async {
      await t.pumpWidget(await montar(() => const AccesoPage()));
      await t.pumpAndSettle();

      await escribir(t, 'admin@prepion.bo', 'clave-correcta');

      expect(find.text('Usuarios registrados: 2'), findsOneWidget);
      expect(find.text('ana@correo.com'), findsOneWidget);
      expect(find.textContaining('Administrador ·'), findsOneWidget);
    },
  );

  testWidgets('credenciales malas muestran el error y no navegan', (t) async {
    await t.pumpWidget(await montar(() => const AccesoPage()));
    await t.pumpAndSettle();

    await escribir(t, 'ana@correo.com', 'clave-mala-123');

    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(find.text('INICIO'), findsNothing);
  });

  testWidgets('valida correo y largo de contraseña antes de enviar', (t) async {
    await t.pumpWidget(await montar(() => const AccesoPage()));
    await t.pumpAndSettle();

    await escribir(t, 'sin-arroba', 'corta');

    expect(find.text('Escribe un correo válido'), findsOneWidget);
    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
  });

  testWidgets('se puede pasar de iniciar sesión a registrarse', (t) async {
    await t.pumpWidget(await montar(() => const AccesoPage()));
    await t.pumpAndSettle();

    await t.tap(find.byKey(const Key('boton_cambiar_modo')));
    await t.pumpAndSettle();

    expect(find.text('Crear cuenta'), findsOneWidget);
    expect(find.text('Registrarme'), findsOneWidget);
  });

  testWidgets('un postulante no ve el panel de administración', (t) async {
    await t.pumpWidget(await montar(() => const AdminPage()));
    await t.pumpAndSettle();
    _router.go('/admin');
    await t.pumpAndSettle();

    expect(find.byKey(const Key('texto_acceso_restringido')), findsOneWidget);
    expect(find.byKey(const Key('total_usuarios')), findsNothing);
  });

  testWidgets('con sesión guardada ofrece cerrar sesión', (t) async {
    final cuenta = _cuenta('usuario', 'ana@correo.com');
    await t.pumpWidget(
      await montar(
        () => const AccesoPage(),
        inicial: {
          claveTokenCuenta: 't',
          claveDatosCuenta:
              '{"id":"i","correo":"ana@correo.com","rol":"usuario","creadoEn":"${cuenta['creadoEn']}","respuestas":0}',
        },
      ),
    );
    await t.pumpAndSettle();

    expect(find.text('Sesión iniciada como ana@correo.com'), findsOneWidget);
    await t.tap(find.byKey(const Key('boton_cerrar_sesion')));
    await t.pumpAndSettle();

    expect(find.byKey(const Key('campo_correo')), findsOneWidget);
  });

  testWidgets(
    'el administrador con sesión guardada puede cerrar sesión desde el panel',
    (t) async {
      await t.pumpWidget(
        await montar(
          () => const AccesoPage(),
          inicial: {
            claveTokenCuenta: 't',
            claveDatosCuenta: '{"id":"i","correo":"admin@prepion.bo","rol":"admin","creadoEn":"2026-11-22T19:43:00Z","respuestas":0}',
          },
        ),
      );
      await t.pumpAndSettle();
      _router.go('/admin');
      await t.pumpAndSettle();

      await t.tap(find.byKey(const Key('boton_salir_admin')));
      await t.pumpAndSettle();

      expect(find.text('INICIO'), findsOneWidget);
    },
  );
}

late GoRouter _router;
