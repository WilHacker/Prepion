import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/features/progreso/domain/resumen_hoy.dart';

void main() {
  final ahora = DateTime(2026, 11, 22, 18);

  test('devuelve el resumen vacío cuando no hay respuestas', () {
    // Actuar
    final resumen = calcularResumenHoy(respuestas: const [], ahora: ahora);

    // Verificar
    expect(resumen, ResumenHoy.vacio);
    expect(resumen.precision, isNull);
  });

  test('cuenta las respuestas de hoy, la racha y la precisión total', () {
    // Preparar
    final respuestas = <RegistroRespuesta>[
      (respondidaEn: DateTime(2026, 11, 21, 20), esCorrecta: false),
      (respondidaEn: DateTime(2026, 11, 22, 9), esCorrecta: true),
      (respondidaEn: DateTime(2026, 11, 22, 10), esCorrecta: true),
      (respondidaEn: DateTime(2026, 11, 22, 11), esCorrecta: false),
    ];

    // Actuar
    final resumen = calcularResumenHoy(respuestas: respuestas, ahora: ahora);

    // Verificar
    expect(resumen.respondidasHoy, 3);
    expect(resumen.racha, 2);
    expect(resumen.precision, 0.5);
    expect(
      resumen,
      const ResumenHoy(racha: 2, respondidasHoy: 3, precision: 0.5),
    );
    expect(
      resumen.hashCode,
      const ResumenHoy(racha: 2, respondidasHoy: 3, precision: 0.5).hashCode,
    );
  });
}
