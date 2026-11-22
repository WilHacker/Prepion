import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/shared/notifications/planificacion_recordatorio.dart';

void main() {
  test('programa para hoy de forma recurrente cuando la hora aún no pasó y no practicó', () {
    // Preparar
    final ahora = DateTime(2026, 11, 22, 14, 30);

    // Actuar
    final plan = calcularPlanRecordatorio(
      hora: 19,
      minuto: 0,
      metaDiaria: 10,
      ahoraLocal: ahora,
    );

    // Verificar
    expect(plan.fechaProgramada, DateTime(2026, 11, 22, 19, 0));
    expect(plan.esRecurrenteDiario, isTrue);
    expect(plan.cuerpo, 'Tus 10 preguntas de hoy te esperan (5 min)');
    expect(plan.payload, rutaPracticaDiaria);
  });

  test(
    'programa para mañana de forma recurrente cuando la hora de hoy ya pasó',
    () {
      // Preparar
      final ahora = DateTime(2026, 11, 22, 20, 15);

      // Actuar
      final plan = calcularPlanRecordatorio(
        hora: 19,
        minuto: 0,
        metaDiaria: 5,
        ahoraLocal: ahora,
      );

      // Verificar
      expect(plan.fechaProgramada, DateTime(2026, 11, 23, 19, 0));
      expect(plan.esRecurrenteDiario, isTrue);
      expect(plan.cuerpo, 'Tus 5 preguntas de hoy te esperan (3 min)');
    },
  );

  test('posterga el aviso de hoy hacia mañana sin repetición cuando ya practicó antes de la hora', () {
    // Preparar
    final ahora = DateTime(2026, 11, 22, 11, 0);

    // Actuar
    final plan = calcularPlanRecordatorio(
      hora: 19,
      minuto: 30,
      metaDiaria: 20,
      ahoraLocal: ahora,
      yaPracticoHoy: true,
    );

    // Verificar
    expect(plan.fechaProgramada, DateTime(2026, 11, 23, 19, 30));
    expect(plan.esRecurrenteDiario, isFalse);
    expect(plan.cuerpo, 'Tus 20 preguntas de hoy te esperan (10 min)');
  });

  test('mantiene recurrencia diaria para mañana cuando ya practicó después de la hora', () {
    // Preparar
    final ahora = DateTime(2026, 11, 22, 21, 0);

    // Actuar
    final plan = calcularPlanRecordatorio(
      hora: 19,
      minuto: 0,
      metaDiaria: 10,
      ahoraLocal: ahora,
      yaPracticoHoy: true,
    );

    // Verificar
    expect(plan.fechaProgramada, DateTime(2026, 11, 23, 19, 0));
    expect(plan.esRecurrenteDiario, isTrue);
  });

  test('detecta correctamente si existen respuestas registradas hoy', () {
    // Preparar
    final ahora = DateTime(2026, 11, 22, 15, 0);

    // Actuar y verificar
    expect(
      practicoHoy(<DateTime>[
        DateTime(2026, 11, 21, 23, 59),
      ], ahoraLocal: ahora),
      isFalse,
    );
    expect(
      practicoHoy(<DateTime>[DateTime(2026, 11, 22, 8, 10)], ahoraLocal: ahora),
      isTrue,
    );
  });

  test('resuelve rutas válidas desde el payload de la notificación', () {
    // Actuar y verificar
    expect(resolverRutaDesdePayload('/practica'), '/practica');
    expect(resolverRutaDesdePayload('  /practica  '), '/practica');
    expect(resolverRutaDesdePayload(null), isNull);
    expect(resolverRutaDesdePayload(''), isNull);
    expect(resolverRutaDesdePayload('practica'), isNull);
  });
}
