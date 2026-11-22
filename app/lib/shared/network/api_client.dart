import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/shared/config/app_config.dart';

const String cabeceraUsuarioId = 'X-Usuario-Id';

Dio crearClienteApi({
  String baseUrl = AppConfig.apiUrl,
  String? Function()? obtenerUsuarioId,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '$baseUrl/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );

  if (obtenerUsuarioId != null) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final usuarioId = obtenerUsuarioId();
          if (usuarioId != null && usuarioId.isNotEmpty) {
            options.headers[cabeceraUsuarioId] = usuarioId;
          }
          handler.next(options);
        },
      ),
    );
  }

  return dio;
}

/// Cliente especializado para sincronización silenciosa con timeouts cortos (5s, HU-08).
Dio crearClienteSincronizacion({
  String baseUrl = AppConfig.apiUrl,
  String? Function()? obtenerUsuarioId,
  Duration timeout = const Duration(seconds: 5),
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '$baseUrl/api',
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      contentType: 'application/json',
    ),
  );

  if (obtenerUsuarioId != null) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final usuarioId = obtenerUsuarioId();
          if (usuarioId != null && usuarioId.isNotEmpty) {
            options.headers[cabeceraUsuarioId] = usuarioId;
          }
          handler.next(options);
        },
      ),
    );
  }

  return dio;
}

final clienteApiProvider = Provider<Dio>((ref) {
  final cliente = crearClienteApi();
  ref.onDispose(cliente.close);
  return cliente;
});

final clienteSincronizacionProvider = Provider<Dio>((ref) {
  final cliente = crearClienteSincronizacion();
  ref.onDispose(cliente.close);
  return cliente;
});
