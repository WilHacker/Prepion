import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/features/progreso/presentation/providers/progreso_provider.dart';

/// Conecta lo que el postulante elige en el onboarding (meta diaria y fecha del
/// examen) con la práctica y el panel de progreso.
///
/// Vive en `app/` porque una feature no debe importar a otra: aquí es donde se
/// juntan. Se aplica como `overrides` al crear el contenedor en `main.dart`.
final List<Override> sobrescriturasDePreferencias = [
  metaDiariaProvider.overrideWith(
    (ref) =>
        ref.watch(preferenciasEstudioProvider).asData?.value?.metaDiaria ??
        metaDiariaPorDefecto,
  ),
  fechaExamenProvider.overrideWith(
    (ref) => ref.watch(preferenciasEstudioProvider).asData?.value?.fechaExamen,
  ),
];
