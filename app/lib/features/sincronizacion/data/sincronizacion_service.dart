import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/practica/data/banco_local_service.dart';
import 'package:prepion/features/sincronizacion/data/sincronizacion_repositorio.dart';
import 'package:prepion/shared/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const claveVersionBancoLocal = 'version_banco_preguntas';
const clavePaqueteConocimiento = 'paquete_conocimiento_cache';

class SincronizacionService {
  SincronizacionService({
    required this.clienteApi,
    required this.repositorio,
    required this.bancoLocalService,
    required this.almacenamiento,
  });

  final Dio clienteApi;
  final SincronizacionRepositorio repositorio;
  final BancoLocalService bancoLocalService;
  final SharedPreferences almacenamiento;

  /// Sincroniza respuestas locales pendientes hacia el servidor en lotes de máx 100.
  Future<int> sincronizarRespuestas() async {
    final pendientes = await repositorio.obtenerPendientes(limite: 100);
    if (pendientes.isEmpty) return 0;

    final ids = pendientes.map((p) => p.idEvento).toList();

    try {
      final payload = {
        'respuestas': [
          for (final p in pendientes)
            {
              'idEvento': p.idEvento,
              'preguntaId': p.preguntaId,
              'opcionElegida': p.opcionElegida,
              'esCorrecta': p.esCorrecta,
              'tiempoMs': p.tiempoMs,
              'respondidaEn': p.respondidaEn.toUtc().toIso8601String(),
            },
        ],
      };

      final respuesta = await clienteApi.post<Map<String, dynamic>>(
        '/sincronizacion/lote',
        data: payload,
      );

      if (respuesta.statusCode == 200) {
        await repositorio.marcarEnviados(ids);
        return pendientes.length;
      } else {
        await repositorio.marcarFallidos(ids);
        return 0;
      }
    } catch (_) {
      // Sin internet o timeout: se registran intentos fallidos silenciosamente
      await repositorio.marcarFallidos(ids);
      return 0;
    }
  }

  /// Verifica si el servidor tiene un banco de preguntas más reciente y lo descarga.
  Future<bool> sincronizarBancoSiHayNuevaVersion() async {
    try {
      final respuesta = await clienteApi.get<Map<String, dynamic>>(
        '/preguntas/banco/actual',
      );
      if (respuesta.statusCode != 200 || respuesta.data == null) return false;

      final versionServidor =
          (respuesta.data!['version'] as num?)?.toInt() ?? 1;
      final versionLocal = almacenamiento.getInt(claveVersionBancoLocal) ?? 1;

      if (versionServidor <= versionLocal) return false;

      final descarga = await clienteApi.get<Map<String, dynamic>>(
        '/preguntas/banco/descargar/$versionServidor',
      );
      if (descarga.statusCode != 200 || descarga.data == null) return false;

      final exito = await bancoLocalService.importarBanco(descarga.data!);
      if (exito) {
        await almacenamiento.setInt(claveVersionBancoLocal, versionServidor);
        return true;
      }
    } catch (_) {
      // Silenciar cualquier error de red
    }
    return false;
  }

  /// Obtiene los parámetros de dificultad/FSRS más recientes del servidor.
  Future<bool> sincronizarPaqueteConocimiento() async {
    try {
      final respuesta = await clienteApi.get<Map<String, dynamic>>(
        '/paquetes-conocimiento/actual',
      );
      if (respuesta.statusCode == 200 && respuesta.data != null) {
        await almacenamiento.setString(
          clavePaqueteConocimiento,
          jsonEncode(respuesta.data!),
        );
        return true;
      }
    } catch (_) {
      // Silenciar errores de conectividad
    }
    return false;
  }

  /// Ejecuta el ciclo completo de sincronización bidireccional en segundo plano.
  Future<void> sincronizarTodoSilenciosamente() async {
    await sincronizarRespuestas();
    await sincronizarBancoSiHayNuevaVersion();
    await sincronizarPaqueteConocimiento();
  }
}

final sincronizacionServiceProvider = FutureProvider<SincronizacionService>((
  ref,
) async {
  final dio = ref.watch(clienteSincronizacionProvider);
  final repo = ref.watch(sincronizacionRepositorioProvider);
  final bancoService = ref.watch(bancoLocalServiceProvider);
  final prefs = await SharedPreferences.getInstance();
  return SincronizacionService(
    clienteApi: dio,
    repositorio: repo,
    bancoLocalService: bancoService,
    almacenamiento: prefs,
  );
});
