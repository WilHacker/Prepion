import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/features/cuentas/data/repositorio_cuentas.dart';
import 'package:prepion/features/cuentas/domain/cuenta.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, Object?> _cuentaJson({String rol = 'usuario'}) => <String, Object?>{
  'id': 'id-1',
  'correo': 'ana@correo.com',
  'rol': rol,
  'esAnonimo': false,
  'creadoEn': '2026-11-22T19:43:00Z',
  'respuestas': 3,
};

/// Cliente que responde con lo que devuelva [responder] y anota la última petición.
Dio _cliente(
  Object? Function(RequestOptions) responder,
  void Function(RequestOptions) alVer,
) {
  return Dio(BaseOptions(baseUrl: 'http://x/api'))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          alVer(options);
          try {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: responder(options),
              ),
            );
          } on DioException catch (e) {
            handler.reject(e);
          }
        },
      ),
    );
}

DioException _http(RequestOptions o, int codigo, Object? cuerpo) =>
    DioException(
      requestOptions: o,
      type: DioExceptionType.badResponse,
      response: Response(requestOptions: o, statusCode: codigo, data: cuerpo),
    );

void main() {
  late SharedPreferences prefs;
  late RequestOptions ultima;

  Future<RepositorioCuentas> crear(
    Object? Function(RequestOptions) responder, {
    Map<String, Object> inicial = const {},
  }) async {
    SharedPreferences.setMockInitialValues(inicial);
    prefs = await SharedPreferences.getInstance();
    return RepositorioCuentas(prefs, _cliente(responder, (o) => ultima = o));
  }

  test('inicia sesión, guarda token y cuenta y los recuerda', () async {
    final repo = await crear(
      (_) => <String, Object?>{'token': 'jwt-1', 'cuenta': _cuentaJson()},
    );

    final cuenta = await repo.iniciarSesion(
      '  ana@correo.com ',
      'clave-segura',
    );

    expect(ultima.path, '/auth/login');
    expect((ultima.data as Map)['correo'], 'ana@correo.com');
    expect(cuenta.esAdmin, isFalse);
    expect(prefs.getString(claveTokenCuenta), 'jwt-1');
    expect(repo.sesionGuardada()?.correo, 'ana@correo.com');
  });

  test('registrar usa la ruta de registro', () async {
    final repo = await crear(
      (_) => <String, Object?>{
        'token': 't',
        'cuenta': _cuentaJson(rol: 'admin'),
      },
    );

    final cuenta = await repo.registrar('ana@correo.com', 'clave-segura');

    expect(ultima.path, '/auth/registro');
    expect(cuenta.esAdmin, isTrue);
  });

  test('cerrar sesión borra todo', () async {
    final repo = await crear(
      (_) => <String, Object?>{'token': 't', 'cuenta': _cuentaJson()},
    );
    await repo.iniciarSesion('ana@correo.com', 'clave-segura');

    await repo.cerrarSesion();

    expect(repo.sesionGuardada(), isNull);
    expect(prefs.getString(claveTokenCuenta), isNull);
  });

  test('sesionGuardada ignora datos corruptos o sin token', () async {
    final sinToken = await crear(
      (_) => null,
      inicial: {claveDatosCuenta: jsonEncode(_cuentaJson())},
    );
    expect(sinToken.sesionGuardada(), isNull);

    final corrupto = await crear(
      (_) => null,
      inicial: {claveDatosCuenta: '{no es json', claveTokenCuenta: 't'},
    );
    expect(corrupto.sesionGuardada(), isNull);
  });

  test(
    'muestra el mensaje del servidor cuando las credenciales fallan',
    () async {
      final repo = await crear(
        (o) => throw _http(o, 401, <String, Object?>{
          'detail': 'Correo o contraseña incorrectos.',
        }),
      );

      expect(
        () => repo.iniciarSesion('a@b.com', 'clave-segura'),
        throwsA(
          isA<ErrorCuentas>().having(
            (e) => e.mensaje,
            'mensaje',
            'Correo o contraseña incorrectos.',
          ),
        ),
      );
    },
  );

  test('traduce validación 422 y falta de conexión', () async {
    final validacion = await crear(
      (o) => throw _http(o, 422, <String, Object?>{'detail': <Object?>[]}),
    );
    await expectLater(
      validacion.registrar('mal', 'x'),
      throwsA(
        isA<ErrorCuentas>().having(
          (e) => e.mensaje,
          'm',
          contains('Revisa los datos'),
        ),
      ),
    );

    final sinRed = await crear(
      (o) => throw DioException(
        requestOptions: o,
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(
      sinRed.iniciarSesion('a@b.com', 'clave-segura'),
      throwsA(
        isA<ErrorCuentas>().having(
          (e) => e.mensaje,
          'm',
          contains('No hay conexión'),
        ),
      ),
    );
  });

  test('lista usuarios con el token en Authorization', () async {
    final repo = await crear(
      (_) => <Object?>[_cuentaJson(), _cuentaJson(rol: 'admin')],
      inicial: {claveTokenCuenta: 'jwt-9'},
    );

    final usuarios = await repo.listarUsuarios();

    expect(ultima.headers['Authorization'], 'Bearer jwt-9');
    expect(usuarios, hasLength(2));
    expect(usuarios.last.esAdmin, isTrue);
    expect(usuarios.first.respuestas, 3);
  });

  test(
    'listar usuarios sin sesión falla antes de llamar al servidor',
    () async {
      final repo = await crear((_) => <Object?>[]);
      await expectLater(repo.listarUsuarios(), throwsA(isA<ErrorCuentas>()));
    },
  );

  test('una respuesta vacía se reporta como error', () async {
    final repo = await crear((_) => null);
    await expectLater(
      repo.iniciarSesion('a@b.com', 'clave-segura'),
      throwsA(isA<ErrorCuentas>()),
    );
  });

  group('panel de administración', () {
    test('lee el resumen del servidor', () async {
      final repo = await crear(
        (_) => <String, Object?>{
          'usuarios': 4,
          'respuestas': 10,
          'preguntasPublicadas': 24,
          'examenesDescargados': 33,
          'bancoVersion': 1,
          'paqueteVersion': 2,
          'paqueteOrigen': 'simulado',
        },
        inicial: {claveTokenCuenta: 'jwt'},
      );

      final r = await repo.resumen();

      expect(ultima.path, '/admin/resumen');
      expect(r.usuarios, 4);
      expect(r.paqueteOrigen, 'simulado');
      expect(r.bancoVersion, 1);
    });

    test('lista exámenes con su veredicto', () async {
      final repo = await crear(
        (_) => <Object?>[
          <String, Object?>{
            'archivo': '2026-1-1op.pdf',
            'paginas': 2,
            'preguntas': 20,
            'conCincoOpciones': 20,
            'veredicto': 'curable',
            'motivo': '20/20 preguntas con 5 opciones',
          },
        ],
        inicial: {claveTokenCuenta: 'jwt'},
      );

      final lista = await repo.examenes();

      expect(lista.single.veredicto, 'curable');
      expect(lista.single.conCincoOpciones, 20);
    });

    test('recolectar y recalibrar usan POST con el token', () async {
      final repo = await crear(
        (o) => o.path.contains('recolectar')
            ? <String, Object?>{
                'descargados': <Object?>['a.pdf', 'b.pdf'],
              }
            : <String, Object?>{'version': 7},
        inicial: {claveTokenCuenta: 'jwt-5'},
      );

      expect(await repo.recolectarExamenes(), 2);
      expect(ultima.method, 'POST');
      expect(ultima.headers['Authorization'], 'Bearer jwt-5');
      expect(await repo.recalibrar(), 7);
      expect(ultima.path, '/admin/conocimiento/recalibrar');
    });

    test('lista las preguntas de un examen para previsualizarlas', () async {
      final repo = await crear(
        (_) => <Object?>[
          <String, Object?>{
            'codigo': 'A1',
            'materia': 'Aritmética',
            'enunciado': 'Cuánto es 1+1',
            'opciones': <Object?>['1', '2'],
            'requiereImagen': false,
          },
          <String, Object?>{
            'codigo': 'G2',
            'materia': 'Geometría',
            'enunciado': '',
            'opciones': <Object?>['', ''],
            'requiereImagen': true,
          },
        ],
        inicial: {claveTokenCuenta: 'jwt'},
      );

      final lista = await repo.preguntasDeExamen('2026-1-1op.pdf');

      expect(ultima.path, '/admin/examenes/2026-1-1op.pdf/preguntas');
      expect(lista.first.tieneOpcionesTexto, isTrue);
      expect(lista.last.tieneOpcionesTexto, isFalse);
    });

    test('publica preguntas y descarga la versión nueva del banco', () async {
      final repo = await crear(
        (o) => o.method == 'POST'
            ? <String, Object?>{'version': 2, 'agregadas': 3, 'totalBanco': 27}
            : <String, Object?>{'version': 2, 'preguntas': <Object?>[]},
        inicial: {claveTokenCuenta: 'jwt'},
      );

      final res = await repo.publicarPreguntasDeExamen('x.pdf', [
        <String, Object?>{'codigo': 'A1'},
      ]);

      expect(res.version, 2);
      expect(res.agregadas, 3);
      expect(res.totalBanco, 27);
      expect((ultima.data as Map)['preguntas'], hasLength(1));
      final banco = await repo.descargarBanco(2);
      expect(ultima.path, '/preguntas/banco/descargar/2');
      expect(banco['version'], 2);
    });
  });
}
