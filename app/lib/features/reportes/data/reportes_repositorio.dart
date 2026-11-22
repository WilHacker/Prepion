import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/shared/database/app_database.dart';

class ReportesRepositorio {
  const ReportesRepositorio(this._baseDeDatos);

  final AppDatabase _baseDeDatos;

  /// Guarda un reporte localmente en la cola de sincronización.
  Future<void> guardarReporte({
    required String id,
    required String preguntaId,
    required String motivo,
    String? comentario,
    String estado = 'pendiente',
    DateTime? creadoEn,
  }) async {
    final fecha = creadoEn ?? DateTime.now();
    await _baseDeDatos
        .into(_baseDeDatos.colaReportes)
        .insertOnConflictUpdate(
          ColaReportesCompanion.insert(
            id: id,
            preguntaId: preguntaId,
            motivo: motivo,
            comentario: Value(comentario),
            estado: Value(estado),
            creadoEn: fecha,
          ),
        );
  }

  /// Retorna los reportes locales pendientes de envío al servidor.
  Future<List<ColaReporteFila>> obtenerPendientes({int limite = 50}) async {
    return (_baseDeDatos.select(_baseDeDatos.colaReportes)
          ..where((t) => t.estado.equals('pendiente'))
          ..orderBy([(t) => OrderingTerm.asc(t.creadoEn)])
          ..limit(limite))
        .get();
  }

  /// Marca reportes como enviados tras sincronización exitosa.
  Future<void> marcarEnviados(List<String> ids) async {
    if (ids.isEmpty) return;
    await (_baseDeDatos.update(_baseDeDatos.colaReportes)
          ..where((t) => t.id.isIn(ids)))
        .write(const ColaReportesCompanion(estado: Value('enviado')));
  }

  /// Marca reportes como fallidos tras error en la red.
  Future<void> marcarFallidos(List<String> ids) async {
    if (ids.isEmpty) return;
    await (_baseDeDatos.update(_baseDeDatos.colaReportes)
          ..where((t) => t.id.isIn(ids)))
        .write(const ColaReportesCompanion(estado: Value('fallido')));
  }
}

final reportesRepositorioProvider = Provider<ReportesRepositorio>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReportesRepositorio(db);
});
