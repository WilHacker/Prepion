import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/app/integracion_preferencias.dart';
import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/features/progreso/presentation/providers/progreso_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer contenedor;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    contenedor = ProviderContainer(overrides: sobrescriturasDePreferencias);
    addTearDown(contenedor.dispose);
    // Riverpod 3 pausa los proveedores sin oyentes.
    contenedor
      ..listen(preferenciasEstudioProvider, (anterior, actual) {})
      ..listen(metaDiariaProvider, (anterior, actual) {})
      ..listen(fechaExamenProvider, (anterior, actual) {});
  });

  Future<void> completarOnboarding({int meta = 20}) async {
    await contenedor.read(preferenciasEstudioProvider.future);
    await contenedor
        .read(preferenciasEstudioProvider.notifier)
        .completarOnboarding(
          fechaExamen: DateTime(2027, 1, 25),
          metaDiaria: meta,
          horaEstudio: 8,
          minutoEstudio: 30,
        );
  }

  test('usa la meta por defecto mientras no hay onboarding', () async {
    // Actuar
    await contenedor.read(preferenciasEstudioProvider.future);

    // Verificar
    expect(contenedor.read(metaDiariaProvider), metaDiariaPorDefecto);
    expect(contenedor.read(fechaExamenProvider), isNull);
  });

  test('la práctica usa la meta diaria que eligió el postulante', () async {
    // Actuar
    await completarOnboarding();

    // Verificar
    expect(contenedor.read(metaDiariaProvider), 20);
  });

  test('el progreso recibe la fecha del examen del postulante', () async {
    // Actuar
    await completarOnboarding();

    // Verificar
    expect(contenedor.read(fechaExamenProvider), DateTime(2027, 1, 25));
  });

  test(
    'se actualiza cuando el postulante cambia sus metas en Ajustes',
    () async {
      // Preparar
      await completarOnboarding();

      // Actuar
      await contenedor
          .read(preferenciasEstudioProvider.notifier)
          .actualizarMetas(
            fechaExamen: DateTime(2027, 2, 10),
            metaDiaria: 5,
            horaEstudio: 8,
            minutoEstudio: 30,
          );

      // Verificar
      expect(contenedor.read(metaDiariaProvider), 5);
      expect(contenedor.read(fechaExamenProvider), DateTime(2027, 2, 10));
    },
  );
}
