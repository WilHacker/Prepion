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

  test('entrega un cliente Dio cuando se lee el provider', () {
    final contenedor = ProviderContainer();
    addTearDown(contenedor.dispose);

    expect(contenedor.read(clienteApiProvider), isA<Dio>());
  });
}
