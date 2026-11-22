import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';

/// Puerto de almacenamiento para las preferencias locales del postulante.
abstract interface class RepositorioPreferencias {
  Future<PreferenciasEstudio?> cargar();

  Future<void> guardar(PreferenciasEstudio preferencias);
}
