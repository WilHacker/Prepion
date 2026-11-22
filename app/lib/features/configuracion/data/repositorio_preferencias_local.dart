import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';
import 'package:prepion/features/configuracion/domain/repositorio_preferencias.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Claves de persistencia en shared_preferences.
abstract final class ClavesPreferencias {
  static const String idUsuarioLocal = 'id_usuario_local';
  static const String fechaExamen = 'fecha_examen';
  static const String metaDiaria = 'meta_diaria';
  static const String horaEstudio = 'hora_estudio_hora';
  static const String minutoEstudio = 'hora_estudio_minuto';
  static const String onboardingCompletado = 'onboarding_completado';
  static const String recordatorioActivo = 'recordatorio_activo';
}

/// Implementación local de preferencias respaldada por `shared_preferences`.
class RepositorioPreferenciasLocal implements RepositorioPreferencias {
  const RepositorioPreferenciasLocal(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<PreferenciasEstudio?> cargar() async {
    final idUsuario = _prefs.getString(ClavesPreferencias.idUsuarioLocal);
    if (idUsuario == null || idUsuario.isEmpty) {
      return null;
    }

    final fechaTexto = _prefs.getString(ClavesPreferencias.fechaExamen);
    final fechaExamen =
        (fechaTexto != null ? DateTime.tryParse(fechaTexto) : null) ??
        DateTime.now().add(const Duration(days: 60));

    final metaDiaria = normalizarMetaDiaria(
      _prefs.getInt(ClavesPreferencias.metaDiaria) ?? metaDiariaPorDefecto,
    );
    final horaEstudio =
        _prefs.getInt(ClavesPreferencias.horaEstudio) ?? horaEstudioPorDefecto;
    final minutoEstudio =
        _prefs.getInt(ClavesPreferencias.minutoEstudio) ??
        minutoEstudioPorDefecto;
    final onboardingCompletado =
        _prefs.getBool(ClavesPreferencias.onboardingCompletado) ?? false;
    final recordatorioActivo =
        _prefs.getBool(ClavesPreferencias.recordatorioActivo) ?? true;

    return PreferenciasEstudio(
      idUsuarioLocal: idUsuario,
      fechaExamen: fechaExamen,
      metaDiaria: metaDiaria,
      horaEstudio: horaEstudio.clamp(0, 23),
      minutoEstudio: minutoEstudio.clamp(0, 59),
      onboardingCompletado: onboardingCompletado,
      recordatorioActivo: recordatorioActivo,
    );
  }

  @override
  Future<void> guardar(PreferenciasEstudio preferencias) async {
    await _prefs.setString(
      ClavesPreferencias.idUsuarioLocal,
      preferencias.idUsuarioLocal,
    );
    await _prefs.setString(
      ClavesPreferencias.fechaExamen,
      preferencias.fechaExamen.toIso8601String(),
    );
    await _prefs.setInt(
      ClavesPreferencias.metaDiaria,
      normalizarMetaDiaria(preferencias.metaDiaria),
    );
    await _prefs.setInt(
      ClavesPreferencias.horaEstudio,
      preferencias.horaEstudio.clamp(0, 23),
    );
    await _prefs.setInt(
      ClavesPreferencias.minutoEstudio,
      preferencias.minutoEstudio.clamp(0, 59),
    );
    await _prefs.setBool(
      ClavesPreferencias.onboardingCompletado,
      preferencias.onboardingCompletado,
    );
    await _prefs.setBool(
      ClavesPreferencias.recordatorioActivo,
      preferencias.recordatorioActivo,
    );
  }
}
