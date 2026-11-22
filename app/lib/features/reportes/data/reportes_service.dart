import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/reportes/data/reportes_repositorio.dart';
import 'package:prepion/shared/network/api_client.dart';
import 'package:uuid/uuid.dart';

class ReportesService {
  ReportesService({
    required this.clienteApi,
    required this.repositorio,
    String Function()? generadorUuid,
  }) : _generarUuid = generadorUuid ?? const Uuid().v4;

  final Dio clienteApi;
  final ReportesRepositorio repositorio;
  final String Function() _generarUuid;

  /// Registra un reporte: lo envía a la API si hay conexión, o lo encola localmente si está offline.
  Future<bool> enviarReporte({
    required String preguntaId,
    required String motivo,
    String? comentario,
  }) async {
    final id = _generarUuid();
    final fecha = DateTime.now();

    try {
      final respuesta = await clienteApi.post<Map<String, dynamic>>(
        '/reportes',
        data: {
          'preguntaId': preguntaId,
          'motivo': motivo,
          'comentario': comentario,
        },
      );

      final exitoso =
          respuesta.statusCode == 200 || respuesta.statusCode == 201;
      await repositorio.guardarReporte(
        id: id,
        preguntaId: preguntaId,
        motivo: motivo,
        comentario: comentario,
        estado: exitoso ? 'enviado' : 'fallido',
        creadoEn: fecha,
      );
      return true;
    } catch (_) {
      // Sin internet o error de red: se guarda silenciosamente en la cola local
      await repositorio.guardarReporte(
        id: id,
        preguntaId: preguntaId,
        motivo: motivo,
        comentario: comentario,
        estado: 'pendiente',
        creadoEn: fecha,
      );
      return true;
    }
  }

  /// Envía los reportes pendientes acumulados cuando se recupera la conexión.
  Future<int> sincronizarPendientes() async {
    final pendientes = await repositorio.obtenerPendientes();
    if (pendientes.isEmpty) return 0;

    int enviados = 0;
    for (final reporte in pendientes) {
      try {
        final respuesta = await clienteApi.post<Map<String, dynamic>>(
          '/reportes',
          data: {
            'preguntaId': reporte.preguntaId,
            'motivo': reporte.motivo,
            'comentario': reporte.comentario,
          },
        );
        if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
          await repositorio.marcarEnviados([reporte.id]);
          enviados++;
        } else {
          await repositorio.marcarFallidos([reporte.id]);
        }
      } catch (_) {
        await repositorio.marcarFallidos([reporte.id]);
      }
    }
    return enviados;
  }
}

final reportesServiceProvider = Provider<ReportesService>((ref) {
  final cliente = ref.watch(clienteSincronizacionProvider);
  final repo = ref.watch(reportesRepositorioProvider);
  return ReportesService(clienteApi: cliente, repositorio: repo);
});
