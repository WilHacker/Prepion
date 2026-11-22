import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:prepion/features/conocimiento/domain/parametros_conocimiento.dart';
import 'package:prepion/features/conocimiento/presentation/providers/conocimiento_provider.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/features/progreso/domain/bkt.dart';
import 'package:prepion/features/progreso/presentation/providers/progreso_provider.dart';

/// Conecta el paquete de conocimiento (dificultad IRT y BKT por tema) con la
/// práctica y el panel de progreso.
///
/// Vive en `app/` porque una feature no debe importar a otra. Se aplica como
/// `overrides` al crear el contenedor en `main.dart`.
final List<Override> sobrescriturasDeConocimiento = [
  dificultadPorPreguntaProvider.overrideWith(
    (ref) =>
        ref
            .watch(parametrosConocimientoProvider)
            .asData
            ?.value
            ?.dificultadPorPregunta ??
        const {},
  ),
  parametrosBktPorTemaProvider.overrideWith((ref) {
    final bkt = ref
        .watch(parametrosConocimientoProvider)
        .asData
        ?.value
        ?.bktPorTema;
    return {
      for (final entrada
          in (bkt ?? const <String, ParametrosBktTema>{}).entries)
        entrada.key: ParametrosBkt(
          inicial: entrada.value.pInicial,
          aprendizaje: entrada.value.pAprendizaje,
          adivinar: entrada.value.pAdivinar,
          error: entrada.value.pError,
        ),
    };
  }),
  etiquetaModeloConocimientoProvider.overrideWith((ref) {
    final paquete = ref.watch(parametrosConocimientoProvider).asData?.value;
    return paquete == null ? null : _etiquetaDe(paquete);
  }),
];

String _etiquetaDe(ParametrosConocimiento paquete) {
  final base = 'Modelo de conocimiento v${paquete.version}';
  return switch (paquete.origen) {
    'simulado' => '$base · datos simulados',
    'real' => '$base · datos reales',
    _ => base,
  };
}

/// Sincroniza el paquete en segundo plano; nunca lanza ni retrasa el arranque.
Future<void> iniciarSincronizacionConocimiento(
  ProviderContainer contenedor,
) async {
  try {
    await sincronizarConocimiento(contenedor);
  } on Exception catch (e) {
    debugPrint('No se pudo sincronizar el conocimiento: $e');
  }
}
