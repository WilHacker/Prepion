import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/progreso/domain/resumen_progreso.dart';

/// Colores fijos del semáforo (no dependen del tema).
Color colorDeSemaforo(Semaforo semaforo) => switch (semaforo) {
  Semaforo.rojo => const Color(0xFFE5484D),
  Semaforo.amarillo => const Color(0xFFF9C80E),
  Semaforo.verde => const Color(0xFF30A46C),
};
