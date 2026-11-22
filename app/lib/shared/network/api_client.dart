import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/shared/config/app_config.dart';

Dio crearClienteApi({String baseUrl = AppConfig.apiUrl}) {
  return Dio(
    BaseOptions(
      baseUrl: '$baseUrl/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );
}

final clienteApiProvider = Provider<Dio>((ref) {
  final cliente = crearClienteApi();
  ref.onDispose(cliente.close);
  return cliente;
});
