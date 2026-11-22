import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/domain/planificador_repaso.dart';

final _lunes = DateTime.utc(2026, 11, 23, 9);

void main() {
  group('RespuestaDelPostulante', () {
    test('mapea cada respuesta a su calificación FSRS', () {
      expect(
        RespuestaDelPostulante.incorrecta.calificacion,
        Calificacion.again,
      );
      expect(RespuestaDelPostulante.noSe.calificacion, Calificacion.again);
      expect(
        RespuestaDelPostulante.correctaMeCosto.calificacion,
        Calificacion.hard,
      );
      expect(RespuestaDelPostulante.correcta.calificacion, Calificacion.good);
      expect(
        RespuestaDelPostulante.correctaFacil.calificacion,
        Calificacion.easy,
      );
    });

    test('solo las respuestas acertadas cuentan como correctas', () {
      final correctas = RespuestaDelPostulante.values.where(
        (respuesta) => respuesta.esCorrecta,
      );

      expect(correctas, [
        RespuestaDelPostulante.correctaMeCosto,
        RespuestaDelPostulante.correcta,
        RespuestaDelPostulante.correctaFacil,
      ]);
    });
  });

  group('PlanificadorRepaso', () {
    final planificador = PlanificadorRepaso();

    test('reprograma a un día una pregunta nueva que se falla', () {
      // Actuar
      final tarjeta = planificador.revisar(
        preguntaId: 'p1',
        calificacion: Calificacion.again,
        ahora: _lunes,
      );

      // Verificar: sin pasos de minutos, lo fallado vuelve al día siguiente.
      expect(tarjeta.vence.difference(_lunes), const Duration(days: 1));
      expect(tarjeta.ultimaRevision, _lunes);
    });

    test('amplía el intervalo cuando se acierta con "bien"', () {
      // Actuar
      final tarjeta = planificador.revisar(
        preguntaId: 'p1',
        calificacion: Calificacion.good,
        ahora: _lunes,
      );

      // Verificar
      expect(tarjeta.vence.difference(_lunes).inDays, greaterThan(1));
    });

    test('da más intervalo con "fácil" que con "me costó"', () {
      // Actuar
      final dificil = planificador.revisar(
        preguntaId: 'p1',
        calificacion: Calificacion.hard,
        ahora: _lunes,
      );
      final facil = planificador.revisar(
        preguntaId: 'p1',
        calificacion: Calificacion.easy,
        ahora: _lunes,
      );

      // Verificar
      expect(facil.vence.isAfter(dificil.vence), isTrue);
    });

    test('alarga el intervalo en cada acierto consecutivo', () {
      // Preparar
      final primera = planificador.revisar(
        preguntaId: 'p1',
        calificacion: Calificacion.good,
        ahora: _lunes,
      );
      final intervaloInicial = primera.vence.difference(_lunes);

      // Actuar: se repasa justo cuando vence.
      final segunda = planificador.revisar(
        preguntaId: 'p1',
        actual: primera,
        calificacion: Calificacion.good,
        ahora: primera.vence,
      );

      // Verificar
      expect(
        segunda.vence.difference(primera.vence),
        greaterThan(intervaloInicial),
      );
    });

    test('vuelve a poner a un día una pregunta repasada que se falla', () {
      // Preparar
      final aprendida = planificador.revisar(
        preguntaId: 'p1',
        calificacion: Calificacion.easy,
        ahora: _lunes,
      );

      // Actuar
      final fallada = planificador.revisar(
        preguntaId: 'p1',
        actual: aprendida,
        calificacion: Calificacion.again,
        ahora: aprendida.vence,
      );

      // Verificar
      expect(
        fallada.vence.difference(aprendida.vence),
        const Duration(days: 1),
      );
      expect(fallada.estabilidad, lessThan(aprendida.estabilidad!));
    });

    test('conserva el id de la pregunta y guarda estabilidad y dificultad', () {
      // Actuar
      final tarjeta = planificador.revisar(
        preguntaId: 'pregunta-7',
        calificacion: Calificacion.good,
        ahora: _lunes,
      );

      // Verificar
      expect(tarjeta.preguntaId, 'pregunta-7');
      expect(tarjeta.estabilidad, isNotNull);
      expect(tarjeta.dificultad, isNotNull);
    });

    test('es predecible: la misma revisión da siempre el mismo resultado', () {
      // Actuar
      final una = planificador.revisar(
        preguntaId: 'p1',
        calificacion: Calificacion.good,
        ahora: _lunes,
      );
      final otra = planificador.revisar(
        preguntaId: 'p1',
        calificacion: Calificacion.good,
        ahora: _lunes,
      );

      // Verificar
      expect(una.vence, otra.vence);
    });
  });
}
