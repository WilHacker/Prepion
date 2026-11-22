import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/shared/database/app_database.dart';

class SincronizacionRepositorio {
  SincronizacionRepositorio(this._baseDeDatos);

  final AppDatabase _baseDeDatos;

  /// Obtiene eventos pendientes o que fallaron con menos de [maxIntentos].
  Future<List<ColaSincronizacionFila>> obtenerPendientes({
    int limite = 100,
    int maxIntentos = 5,
  }) {
    final consulta = _baseDeDatos.select(_baseDeDatos.colaSincronizacion)
      ..where(
        (t) =>
            t.estado.isIn(['pendiente', 'fallido']) &
            t.intentos.isSmallerThanValue(maxIntentos),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.creadoEn)])
      ..limit(limite);

    return consulta.get();
  }

  /// Marca los eventos como enviados satisfactoriamente.
  Future<int> marcarEnviados(List<String> idsEventos) async {
    if (idsEventos.isEmpty) return 0;
    final ahora = DateTime.now();

    return (_baseDeDatos.update(
      _baseDeDatos.colaSincronizacion,
    )..where((t) => t.idEvento.isIn(idsEventos))).write(
      ColaSincronizacionCompanion(
        estado: const Value('enviado'),
        actualizadoEn: Value(ahora),
      ),
    );
  }

  /// Incrementa el contador de intentos y marca como fallido tras error de red.
  Future<int> marcarFallidos(List<String> idsEventos) async {
    if (idsEventos.isEmpty) return 0;
    final ahora = DateTime.now();

    return _baseDeDatos.customUpdate(
      'UPDATE cola_sincronizacion '
      'SET intentos = intentos + 1, estado = ?, actualizado_en = ? '
      'WHERE id_evento IN (${idsEventos.map((_) => '?').join(', ')})',
      variables: [
        Variable.withString('fallido'),
        Variable.withDateTime(ahora),
        for (final id in idsEventos) Variable.withString(id),
      ],
      updates: {_baseDeDatos.colaSincronizacion},
    );
  }

  /// Cantidad actual de eventos pendientes en la cola.
  Stream<int> observarConteoPendientes() {
    final conteo = _baseDeDatos.colaSincronizacion.idEvento.count();
    final consulta = _baseDeDatos.selectOnly(_baseDeDatos.colaSincronizacion)
      ..addColumns([conteo])
      ..where(
        _baseDeDatos.colaSincronizacion.estado.isIn(['pendiente', 'fallido']),
      );

    return consulta.map((fila) => fila.read(conteo) ?? 0).watchSingle();
  }
}

final sincronizacionRepositorioProvider = Provider<SincronizacionRepositorio>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return SincronizacionRepositorio(db);
});
