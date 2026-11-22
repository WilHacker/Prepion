import 'package:dio/dio.dart';

import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';

/// Obtiene parámetros sugeridos desde FastAPI con respaldo silencioso offline.
class ParametrosPublicosRemote {
  const ParametrosPublicosRemote(this._cliente);

  final Dio _cliente;

  Future<ParametrosPublicos> obtener() async {
    try {
      final respuesta = await _cliente.get<Map<String, Object?>>(
        '/configuracion/parametros-publicos',
      );
      final datos = respuesta.data;
      if (datos != null) {
        return ParametrosPublicos.desdeJson(datos);
      }
    } on DioException {
      // Sin conexión o servidor apagado: la app sigue 100 % operativa offline.
    } on FormatException {
      // Respuesta inesperada: usar parámetros locales seguros.
    }
    return ParametrosPublicos.porDefecto();
  }
}
