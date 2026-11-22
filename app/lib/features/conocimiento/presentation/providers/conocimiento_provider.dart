import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/conocimiento/data/repositorio_conocimiento.dart';
import 'package:prepion/features/conocimiento/domain/parametros_conocimiento.dart';

/// Paquete de conocimiento vigente (caché > asset); null si no hay ninguno.
final parametrosConocimientoProvider = FutureProvider<ParametrosConocimiento?>((
  ref,
) async {
  final repositorio = await ref.watch(repositorioConocimientoProvider.future);
  return repositorio.cargar();
}, retry: (reintentos, error) => null);

/// Sincroniza con el servidor y, si llegó un paquete nuevo, refresca el provider.
Future<void> sincronizarConocimiento(ProviderContainer contenedor) async {
  final repositorio = await contenedor.read(
    repositorioConocimientoProvider.future,
  );
  final antes = await repositorio.cargar();
  final despues = await repositorio.sincronizar();
  if (despues?.version != antes?.version) {
    contenedor.invalidate(parametrosConocimientoProvider);
  }
}
