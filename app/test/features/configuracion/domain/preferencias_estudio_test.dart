import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';

void main() {
  test('normaliza la meta diaria cuando llega fuera de rango', () {
    // Actuar y verificar
    expect(normalizarMetaDiaria(0), metaDiariaPorDefecto);
    expect(normalizarMetaDiaria(-5), metaDiariaPorDefecto);
    expect(normalizarMetaDiaria(100), 50);
    expect(normalizarMetaDiaria(20), 20);
  });

  test('formatea hora y fecha corta correctamente en español', () {
    // Actuar y verificar
    expect(formatearHoraEstudio(9, 5), '09:05');
    expect(formatearHoraEstudio(19, 30), '19:30');
    expect(formatearFechaCorta(DateTime(2027, 1, 25)), '25 ene 2027');
  });

  test('calcula los días restantes hasta el examen sin valores negativos', () {
    // Preparar
    final prefs = PreferenciasEstudio(
      idUsuarioLocal: 'uuid-1',
      fechaExamen: DateTime(2027, 1, 25),
      metaDiaria: 10,
      horaEstudio: 19,
      minutoEstudio: 0,
      onboardingCompletado: true,
    );

    // Actuar y verificar
    expect(prefs.diasRestantes(hoy: DateTime(2027, 1, 20)), 5);
    expect(prefs.diasRestantes(hoy: DateTime(2027, 2, 1)), 0);
    expect(prefs.horaEstudioFormateada, '19:00');
    expect(prefs.fechaExamenFormateada, '25 ene 2027');
    expect(prefs.copyWith(metaDiaria: 20).metaDiaria, 20);
  });

  test('genera parámetros públicos por defecto con fechas futuras', () {
    // Actuar
    final parametros = ParametrosPublicos.porDefecto(
      hoy: DateTime(2026, 11, 22),
    );

    // Verificar
    expect(parametros.fechasTentativasExamen.length, 3);
    expect(parametros.fechaExamenRecomendada, DateTime(2027, 1, 25));
    expect(parametros.metasDiariasOpciones, <int>[5, 10, 20]);
    expect(parametros.horaEstudioRecomendada, (19, 0));
  });

  test('parsea parámetros públicos desde JSON camelCase de la API', () {
    // Preparar
    final json = <String, Object?>{
      'fechasTentativasExamen': <Object?>[
        <String, Object?>{
          'etiqueta': '1.ª opción · Gestión 1-2027',
          'fecha': '2027-01-25',
          'esRecomendada': true,
        },
      ],
      'metasDiariasOpciones': <Object?>[5, 10, 20],
      'metaDiariaSugerida': 20,
      'horaEstudioSugerida': '20:30',
      'minPreguntasDiarias': 5,
      'maxPreguntasDiarias': 50,
    };

    // Actuar
    final parametros = ParametrosPublicos.desdeJson(json);

    // Verificar
    expect(parametros.metaDiariaSugerida, 20);
    expect(parametros.horaEstudioRecomendada, (20, 30));
    expect(parametros.fechaExamenRecomendada, DateTime(2027, 1, 25));
  });

  test('usa valores de respaldo cuando el JSON de parámetros está vacío', () {
    // Actuar
    final parametros = ParametrosPublicos.desdeJson(<String, Object?>{
      'horaEstudioSugerida': 'invalida',
    });

    // Verificar
    expect(parametros.fechasTentativasExamen, isNotEmpty);
    expect(parametros.metasDiariasOpciones, metasDiariasDisponibles);
    expect(parametros.horaEstudioRecomendada, (19, 0));
  });
}
