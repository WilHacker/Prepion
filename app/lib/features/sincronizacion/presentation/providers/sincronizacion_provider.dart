import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/features/sincronizacion/data/sincronizacion_repositorio.dart';
import 'package:prepion/features/sincronizacion/data/sincronizacion_service.dart';

/// Provider que entrega la cantidad de respuestas pendientes de sincronizar.
final conteoPendientesProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(sincronizacionRepositorioProvider);
  return repo.observarConteoPendientes();
});

/// Gestor de sincronización automática que reacciona a cambios de conectividad.
class GestorSincronizacionAuto {
  GestorSincronizacionAuto({
    required this.obtenerServicio,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity() {
    _iniciarEscucha();
  }

  final Future<SincronizacionService> Function() obtenerServicio;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscripcion;

  void _iniciarEscucha() {
    _subscripcion = _connectivity.onConnectivityChanged.listen((resultados) {
      final hayConexion = resultados.any((r) => r != ConnectivityResult.none);
      if (hayConexion) {
        unawaited(_sincronizar());
      }
    });
  }

  Future<void> _sincronizar() async {
    final servicio = await obtenerServicio();
    await servicio.sincronizarTodoSilenciosamente();
  }

  void dispose() {
    _subscripcion?.cancel();
  }
}

final gestorSincronizacionAutoProvider = Provider<GestorSincronizacionAuto>((
  ref,
) {
  final gestor = GestorSincronizacionAuto(
    obtenerServicio: () => ref.read(sincronizacionServiceProvider.future),
  );
  ref.onDispose(gestor.dispose);
  return gestor;
});
