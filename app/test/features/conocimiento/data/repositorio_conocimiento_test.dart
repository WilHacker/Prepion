import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/features/conocimiento/data/repositorio_conocimiento.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, Object?> _paquete(int version) => {
  'version': version,
  'preguntas': [
    {'preguntaId': 'p1', 'dificultad': 0.5},
  ],
  'bkt': <Object?>[],
};

void main() {
  late Dio cliente;
  late SharedPreferences prefs;
  late Object? Function() respuestaRemota;

  Future<RepositorioConocimiento> crear({
    Map<String, Object> inicial = const {},
    String? asset,
  }) async {
    SharedPreferences.setMockInitialValues(inicial);
    prefs = await SharedPreferences.getInstance();
    return RepositorioConocimiento(
      prefs,
      cliente,
      cargarAsset: () async =>
          asset ?? (throw const FormatException('sin asset', 'x')),
    );
  }

  setUp(() {
    respuestaRemota = () => throw StateError('sin configurar');
    cliente = Dio(BaseOptions(baseUrl: 'http://x/api'))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            try {
              handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: respuestaRemota(),
                ),
              );
            } on DioException catch (e) {
              handler.reject(e);
            }
          },
        ),
      );
  });

  DioException falla(RequestOptions o, {int? estado}) => DioException(
    requestOptions: o,
    response: estado == null
        ? null
        : Response(requestOptions: o, statusCode: estado),
    type: estado == null
        ? DioExceptionType.connectionError
        : DioExceptionType.badResponse,
  );

  group('cargar', () {
    test('usa el asset cuando no hay caché', () async {
      // Preparar
      final repo = await crear(asset: jsonEncode(_paquete(1)));

      // Actuar
      final p = await repo.cargar();

      // Verificar
      expect(p!.version, 1);
    });

    test('prefiere la caché sobre el asset', () async {
      // Preparar
      final repo = await crear(
        inicial: {claveCacheConocimiento: jsonEncode(_paquete(5))},
        asset: jsonEncode(_paquete(1)),
      );

      // Actuar
      final p = await repo.cargar();

      // Verificar
      expect(p!.version, 5);
    });

    test('ignora una caché corrupta y cae al asset', () async {
      // Preparar
      final repo = await crear(
        inicial: {claveCacheConocimiento: '{roto'},
        asset: jsonEncode(_paquete(1)),
      );

      // Actuar
      final p = await repo.cargar();

      // Verificar
      expect(p!.version, 1);
    });

    test('ignora una caché con datos inválidos', () async {
      // Preparar
      final repo = await crear(
        inicial: {claveCacheConocimiento: jsonEncode(_paquete(-4))},
        asset: jsonEncode(_paquete(2)),
      );

      // Actuar y verificar
      expect((await repo.cargar())!.version, 2);
    });

    test('devuelve null sin caché ni asset utilizable', () async {
      // Preparar
      final repo = await crear(asset: '{roto');

      // Actuar y verificar
      expect(await repo.cargar(), isNull);
    });
  });

  group('sincronizar', () {
    test('guarda en caché un paquete remoto de versión mayor', () async {
      // Preparar
      final repo = await crear(asset: jsonEncode(_paquete(1)));
      respuestaRemota = () => _paquete(2);

      // Actuar
      final p = await repo.sincronizar();

      // Verificar
      expect(p!.version, 2);
      expect(prefs.getString(claveCacheConocimiento), isNotNull);
      expect((await repo.cargar())!.version, 2);
    });

    test('acepta el cuerpo como texto JSON', () async {
      // Preparar
      final repo = await crear(asset: jsonEncode(_paquete(1)));
      respuestaRemota = () => jsonEncode(_paquete(4));

      // Actuar y verificar
      expect((await repo.sincronizar())!.version, 4);
    });

    test('no guarda un paquete de versión igual o menor', () async {
      // Preparar
      final repo = await crear(asset: jsonEncode(_paquete(3)));
      respuestaRemota = () => _paquete(3);

      // Actuar
      final p = await repo.sincronizar();

      // Verificar
      expect(p!.version, 3);
      expect(prefs.getString(claveCacheConocimiento), isNull);
    });

    test('guarda el remoto cuando no había ningún paquete', () async {
      // Preparar
      final repo = await crear(asset: '{roto');
      respuestaRemota = () => _paquete(1);

      // Actuar y verificar
      expect((await repo.sincronizar())!.version, 1);
    });

    test('conserva el vigente con la red caída', () async {
      // Preparar
      final repo = await crear(asset: jsonEncode(_paquete(1)));
      respuestaRemota = () => throw falla(RequestOptions());

      // Actuar y verificar
      expect((await repo.sincronizar())!.version, 1);
    });

    test('conserva el vigente ante un 404', () async {
      // Preparar
      final repo = await crear(asset: jsonEncode(_paquete(1)));
      respuestaRemota = () => throw falla(RequestOptions(), estado: 404);

      // Actuar y verificar
      expect((await repo.sincronizar())!.version, 1);
    });

    test('descarta un JSON roto o inválido sin tocar la caché', () async {
      // Preparar
      final repo = await crear(asset: jsonEncode(_paquete(1)));

      // Actuar
      respuestaRemota = () => '{roto';
      final roto = await repo.sincronizar();
      respuestaRemota = () => _paquete(-9);
      final invalido = await repo.sincronizar();

      // Verificar
      expect(roto!.version, 1);
      expect(invalido!.version, 1);
      expect(prefs.getString(claveCacheConocimiento), isNull);
    });
  });
}
