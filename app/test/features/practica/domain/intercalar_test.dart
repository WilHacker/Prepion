import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/domain/intercalar.dart';

void main() {
  group('intercalar', () {
    test('alterna un elemento de cada grupo conservando el orden interno', () {
      expect(
        intercalar([
          ['a1', 'a2', 'a3'],
          ['q1', 'q2'],
          ['b1'],
        ]),
        ['a1', 'q1', 'b1', 'a2', 'q2', 'a3'],
      );
    });

    test('sigue con los grupos que quedan cuando uno se acaba', () {
      expect(
        intercalar([
          ['a1'],
          ['q1', 'q2', 'q3'],
        ]),
        ['a1', 'q1', 'q2', 'q3'],
      );
    });

    test('devuelve una lista vacía cuando no hay grupos', () {
      expect(intercalar(const <List<String>>[]), isEmpty);
    });
  });
}
