import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/shared/network/api_client.dart';

void main() {
  test('usa el prefijo /api y tiempos límite cuando se crea el cliente', () {
    // Actuar
    final cliente = crearClienteApi(baseUrl: 'http://192.168.0.10:8800');

    // Verificar
    expect(cliente.options.baseUrl, 'http://192.168.0.10:8800/api');
    expect(cliente.options.connectTimeout, const Duration(seconds: 10));
    expect(cliente.options.receiveTimeout, const Duration(seconds: 30));
  });

  test(
    'agrega la cabecera X-Usuario-Id cuando se provee un identificador local',
    () async {
      // Preparar
      const idLocal = '11111111-2222-4333-8444-555555555555';
      final cliente = crearClienteApi(
        baseUrl: 'http://192.168.0.10:8800',
        obtenerUsuarioId: () => idLocal,
      );
      Object? cabeceraCapturada;
      cliente.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            cabeceraCapturada = options.headers[cabeceraUsuarioId];
            handler.resolve(
              Response<Object?>(requestOptions: options, statusCode: 200),
            );
          },
        ),
      );

      // Actuar
      await cliente.get<Object?>('/configuracion/parametros-publicos');

      // Verificar
      expect(cabeceraCapturada, idLocal);
    },
  );

  test('entrega un cliente Dio cuando se lee el provider', () {
    final contenedor = ProviderContainer();
    addTearDown(contenedor.dispose);

    expect(contenedor.read(clienteApiProvider), isA<Dio>());
  });
}
