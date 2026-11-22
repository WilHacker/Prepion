import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/configuracion/data/parametros_publicos_remote.dart';
import 'package:prepion/features/configuracion/data/repositorio_preferencias_local.dart';
import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';
import 'package:prepion/features/configuracion/domain/repositorio_preferencias.dart';
import 'package:prepion/shared/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Generador de UUID v4 inyectable para pruebas deterministas.
final generadorUuidProvider = Provider<String Function()>((ref) {
  return const Uuid().v4;
});

/// Permite inyectar una implementación de repositorio en pruebas.
final repositorioPreferenciasProvider = FutureProvider<RepositorioPreferencias>(
  (ref) async {
    final prefs = await SharedPreferences.getInstance();
    return RepositorioPreferenciasLocal(prefs);
  },
);

/// Obtiene parámetros sugeridos del backend o usa los valores offline por defecto.
final parametrosPublicosProvider = FutureProvider<ParametrosPublicos>((
  ref,
) async {
  final cliente = ref.watch(clienteApiProvider);
  final servicio = ParametrosPublicosRemote(cliente);
  return servicio.obtener();
});

/// Administra la carga y actualización de las preferencias locales del postulante.
class PreferenciasEstudioNotifier extends AsyncNotifier<PreferenciasEstudio?> {
  @override
  Future<PreferenciasEstudio?> build() async {
    final repositorio = await ref.watch(repositorioPreferenciasProvider.future);
    return repositorio.cargar();
  }

  /// Guarda las metas del onboarding y genera `id_usuario_local` (UUID v4) anónimo.
  Future<PreferenciasEstudio> completarOnboarding({
    required DateTime fechaExamen,
    required int metaDiaria,
    required int horaEstudio,
    required int minutoEstudio,
  }) async {
    final repositorio = await ref.read(repositorioPreferenciasProvider.future);
    final actual = state.asData?.value;
    final idUsuario = (actual != null && actual.idUsuarioLocal.isNotEmpty)
        ? actual.idUsuarioLocal
        : ref.read(generadorUuidProvider)();

    final nuevas = PreferenciasEstudio(
      idUsuarioLocal: idUsuario,
      fechaExamen: fechaExamen,
      metaDiaria: normalizarMetaDiaria(metaDiaria),
      horaEstudio: horaEstudio.clamp(0, 23),
      minutoEstudio: minutoEstudio.clamp(0, 59),
      onboardingCompletado: true,
    );

    await repositorio.guardar(nuevas);
    state = AsyncData<PreferenciasEstudio?>(nuevas);
    return nuevas;
  }

  /// Actualiza las metas de estudio desde Ajustes conservando la identidad local.
  Future<PreferenciasEstudio> actualizarMetas({
    required DateTime fechaExamen,
    required int metaDiaria,
    required int horaEstudio,
    required int minutoEstudio,
  }) async {
    return completarOnboarding(
      fechaExamen: fechaExamen,
      metaDiaria: metaDiaria,
      horaEstudio: horaEstudio,
      minutoEstudio: minutoEstudio,
    );
  }
}

final preferenciasEstudioProvider =
    AsyncNotifierProvider<PreferenciasEstudioNotifier, PreferenciasEstudio?>(
      PreferenciasEstudioNotifier.new,
    );
