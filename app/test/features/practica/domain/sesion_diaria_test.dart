import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/domain/sesion_diaria.dart';
import 'package:prepion/features/practica/domain/tarjeta_repaso.dart';

final _hoy = DateTime.utc(2026, 11, 23, 9);

TarjetaRepaso _tarjeta(String id, {required Duration vence}) => TarjetaRepaso(
  preguntaId: id,
  estado: 2,
  vence: _hoy.add(vence),
  estabilidad: 3,
  dificultad: 5,
  ultimaRevision: _hoy.subtract(const Duration(days: 3)),
);

void main() {
  group('armarSesion', () {
    test('pone primero los repasos vencidos, del más atrasado al menos', () {
      // Preparar
      final tarjetas = [
        _tarjeta('reciente', vence: const Duration(hours: -2)),
        _tarjeta('atrasada', vence: const Duration(days: -3)),
      ];

      // Actuar
      final sesion = armarSesion(
        tarjetas: tarjetas,
        nuevas: const ['n1'],
        ahora: _hoy,
        meta: 10,
      );

      // Verificar
      expect(sesion, ['atrasada', 'reciente', 'n1']);
    });

    test('completa la meta con preguntas nuevas', () {
      // Actuar
      final sesion = armarSesion(
        tarjetas: [_tarjeta('r1', vence: const Duration(days: -1))],
        nuevas: const ['n1', 'n2', 'n3', 'n4'],
        ahora: _hoy,
        meta: 3,
      );

      // Verificar
      expect(sesion, ['r1', 'n1', 'n2']);
    });

    test('no incluye repasos que todavía no vencen', () {
      // Actuar
      final sesion = armarSesion(
        tarjetas: [_tarjeta('futura', vence: const Duration(days: 2))],
        nuevas: const ['n1'],
        ahora: _hoy,
        meta: 5,
      );

      // Verificar
      expect(sesion, ['n1']);
    });

    test('incluye el repaso que vence exactamente ahora', () {
      // Actuar
      final sesion = armarSesion(
        tarjetas: [_tarjeta('justa', vence: Duration.zero)],
        nuevas: const [],
        ahora: _hoy,
        meta: 5,
      );

      // Verificar
      expect(sesion, ['justa']);
    });

    test('nunca pasa de la meta aunque haya más repasos vencidos', () {
      // Actuar
      final sesion = armarSesion(
        tarjetas: [
          for (var i = 0; i < 6; i++)
            _tarjeta('r$i', vence: Duration(days: -(i + 1))),
        ],
        nuevas: const ['n1'],
        ahora: _hoy,
        meta: 4,
      );

      // Verificar: se quedan los 4 más atrasados y no entra nada nuevo.
      expect(sesion, ['r5', 'r4', 'r3', 'r2']);
    });

    test('devuelve una sesión vacía cuando la meta es cero', () {
      expect(
        armarSesion(
          tarjetas: const [],
          nuevas: const ['n1'],
          ahora: _hoy,
          meta: 0,
        ),
        isEmpty,
      );
    });

    test('devuelve una sesión vacía cuando no hay nada que practicar', () {
      expect(
        armarSesion(
          tarjetas: const [],
          nuevas: const [],
          ahora: _hoy,
          meta: 10,
        ),
        isEmpty,
      );
    });
  });
}
