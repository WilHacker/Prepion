import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/cuentas/data/repositorio_cuentas.dart';
import 'package:prepion/features/cuentas/domain/cuenta.dart';
import 'package:prepion/shared/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

final repositorioCuentasProvider = FutureProvider<RepositorioCuentas>((
  ref,
) async {
  final prefs = await SharedPreferences.getInstance();
  return RepositorioCuentas(prefs, ref.watch(clienteApiProvider));
});

/// Cuenta con la sesión iniciada (`null` = usa la app sin cuenta).
class SesionNotifier extends AsyncNotifier<Cuenta?> {
  @override
  Future<Cuenta?> build() async =>
      (await ref.watch(repositorioCuentasProvider.future)).sesionGuardada();

  Future<Cuenta> iniciarSesion(String correo, String contrasena) async {
    final repo = await ref.read(repositorioCuentasProvider.future);
    final cuenta = await repo.iniciarSesion(correo, contrasena);
    state = AsyncData(cuenta);
    return cuenta;
  }

  Future<Cuenta> registrar(String correo, String contrasena) async {
    final repo = await ref.read(repositorioCuentasProvider.future);
    final cuenta = await repo.registrar(correo, contrasena);
    state = AsyncData(cuenta);
    return cuenta;
  }

  Future<void> cerrarSesion() async {
    final repo = await ref.read(repositorioCuentasProvider.future);
    await repo.cerrarSesion();
    state = const AsyncData(null);
  }
}

final sesionProvider = AsyncNotifierProvider<SesionNotifier, Cuenta?>(
  SesionNotifier.new,
);

/// Todos los usuarios registrados (solo responde si la sesión es de administrador).
final usuariosAdminProvider = FutureProvider.autoDispose<List<Cuenta>>((
  ref,
) async {
  final repo = await ref.watch(repositorioCuentasProvider.future);
  return repo.listarUsuarios();
});
