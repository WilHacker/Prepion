import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/domain/racha.dart';

// Fechas locales a mediodía: el cálculo cuenta días del calendario del usuario.
DateTime _dia(int dia, [int hora = 12]) => DateTime(2026, 11, dia, hora);

void main() {
  group('calcularRacha', () {
    test('cuenta los días seguidos que terminan hoy', () {
      expect(
        calcularRacha(
          respuestasEn: [_dia(21), _dia(22), _dia(23)],
          hoy: _dia(23),
        ),
        3,
      );
    });

    test('cuenta una sola vez los días con varias respuestas', () {
      expect(
        calcularRacha(
          respuestasEn: [_dia(23, 8), _dia(23, 12), _dia(23, 20)],
          hoy: _dia(23),
        ),
        1,
      );
    });

    test('mantiene la racha viva si hoy todavía no se practicó', () {
      expect(
        calcularRacha(respuestasEn: [_dia(21), _dia(22)], hoy: _dia(23)),
        2,
      );
    });

    test('se corta cuando falta un día', () {
      expect(
        calcularRacha(
          respuestasEn: [_dia(19), _dia(22), _dia(23)],
          hoy: _dia(23),
        ),
        2,
      );
    });

    test('es cero cuando el último día practicado fue hace más de uno', () {
      expect(calcularRacha(respuestasEn: [_dia(20)], hoy: _dia(23)), 0);
    });

    test('es cero cuando nunca se practicó', () {
      expect(calcularRacha(respuestasEn: const [], hoy: _dia(23)), 0);
    });

    test('ignora respuestas con fecha futura', () {
      expect(calcularRacha(respuestasEn: [_dia(25)], hoy: _dia(23)), 0);
    });
  });
}
