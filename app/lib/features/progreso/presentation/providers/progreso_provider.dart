import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/practica/data/practica_repositorio.dart';
import 'package:prepion/features/practica/domain/racha.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/features/progreso/data/progreso_repositorio.dart';
import 'package:prepion/features/progreso/domain/calcular_progreso.dart';
import 'package:prepion/features/progreso/domain/resumen_progreso.dart';

/// Fecha del examen. Vale null por defecto; `app/integracion_preferencias.dart`
/// la sustituye por la que el postulante eligió en el onboarding.
final fechaExamenProvider = Provider<DateTime?>((ref) => null);

/// Resumen de progreso del postulante, recalculado cada vez que se abre el panel.
final progresoProvider = FutureProvider.autoDispose<ResumenProgreso>((
  ref,
) async {
  final repositorio = ref.read(progresoRepositorioProvider);
  final ahora = ref.read(relojProvider)();
  final fechasDeRespuestas = await ref
      .read(practicaRepositorioProvider)
      .fechasDeRespuestas();

  return calcularProgreso(
    respuestas: await repositorio.respuestas(),
    temas: await repositorio.temas(),
    racha: calcularRacha(respuestasEn: fechasDeRespuestas, hoy: ahora),
    ahora: ahora,
    fechaExamen: ref.read(fechaExamenProvider),
  );
}, retry: (reintentos, error) => null);
