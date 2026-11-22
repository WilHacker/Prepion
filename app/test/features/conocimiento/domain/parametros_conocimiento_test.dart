import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/features/conocimiento/domain/parametros_conocimiento.dart';

Map<String, Object?> _paquete({
  Object? version = 3,
  List<Object?>? preguntas,
  List<Object?>? bkt,
}) => {
  'version': version,
  'origen': 'simulado',
  'usuarios': 60,
  'generadoEn': '2026-11-22T18:00:00Z',
  'preguntas':
      preguntas ??
      [
        {'preguntaId': 'p1', 'dificultad': 0.42},
      ],
  'bkt':
      bkt ??
      [
        {
          'temaId': 't1',
          'pInicial': 0.3,
          'pAprendizaje': 0.1,
          'pAdivinar': 0.2,
          'pError': 0.1,
        },
      ],
};

Matcher get _rechaza => throwsA(isA<ParametrosConocimientoInvalidosError>());

void main() {
  test('lee un paquete válido completo', () {
    // Actuar
    final p = ParametrosConocimiento.fromJson(_paquete());

    // Verificar
    expect(p.version, 3);
    expect(p.origen, 'simulado');
    expect(p.usuarios, 60);
    expect(p.generadoEn, DateTime.utc(2026, 11, 22, 18));
    expect(p.dificultadPorPregunta, {'p1': 0.42});
    expect(p.bktPorTema['t1']!.pAprendizaje, 0.1);
  });

  test('tolera que falten origen, usuarios y generadoEn', () {
    // Preparar
    final json = _paquete()
      ..remove('origen')
      ..remove('usuarios')
      ..remove('generadoEn');

    // Actuar
    final p = ParametrosConocimiento.fromJson(json);

    // Verificar
    expect(p.origen, isNull);
    expect(p.usuarios, isNull);
    expect(p.generadoEn, isNull);
  });

  group('rechaza', () {
    final casos = <String, Object?>{
      'una versión negativa': _paquete(version: -1),
      'una versión no entera': _paquete(version: 1.5),
      'una versión de texto': _paquete(version: '1'),
      'una estructura que no es objeto': [1, 2],
      'preguntas que no es lista': {..._paquete(), 'preguntas': 'x'},
      'una pregunta sin id': _paquete(
        preguntas: [
          {'preguntaId': ' ', 'dificultad': 0.1},
        ],
      ),
      'un tema sin id': _paquete(
        bkt: [
          {
            'temaId': '',
            'pInicial': 0.3,
            'pAprendizaje': 0.1,
            'pAdivinar': 0.2,
            'pError': 0.1,
          },
        ],
      ),
      'una dificultad fuera de rango': _paquete(
        preguntas: [
          {'preguntaId': 'p', 'dificultad': 6.5},
        ],
      ),
      'una dificultad no finita': _paquete(
        preguntas: [
          {'preguntaId': 'p', 'dificultad': double.nan},
        ],
      ),
      'una probabilidad igual a 0': _paquete(
        bkt: [
          {
            'temaId': 't',
            'pInicial': 0,
            'pAprendizaje': 0.1,
            'pAdivinar': 0.2,
            'pError': 0.1,
          },
        ],
      ),
      'una probabilidad igual a 1': _paquete(
        bkt: [
          {
            'temaId': 't',
            'pInicial': 0.3,
            'pAprendizaje': 0.1,
            'pAdivinar': 1,
            'pError': 0.1,
          },
        ],
      ),
      'una probabilidad infinita': _paquete(
        bkt: [
          {
            'temaId': 't',
            'pInicial': 0.3,
            'pAprendizaje': double.infinity,
            'pAdivinar': 0.2,
            'pError': 0.1,
          },
        ],
      ),
      'una probabilidad de texto': _paquete(
        bkt: [
          {
            'temaId': 't',
            'pInicial': 'x',
            'pAprendizaje': 0.1,
            'pAdivinar': 0.2,
            'pError': 0.1,
          },
        ],
      ),
      'más de 5000 preguntas': _paquete(
        preguntas: [
          for (var i = 0; i < 5001; i++) {'preguntaId': '$i', 'dificultad': 0},
        ],
      ),
      'más de 5000 temas': _paquete(
        bkt: [
          for (var i = 0; i < 5001; i++)
            {
              'temaId': '$i',
              'pInicial': 0.3,
              'pAprendizaje': 0.1,
              'pAdivinar': 0.2,
              'pError': 0.1,
            },
        ],
      ),
      'una fecha inválida': {..._paquete(), 'generadoEn': 'ayer'},
      'usuarios negativos': {..._paquete(), 'usuarios': -2},
    };
    for (final caso in casos.entries) {
      test(caso.key, () {
        // Actuar y verificar
        expect(() => ParametrosConocimiento.fromJson(caso.value), _rechaza);
      });
    }
  });
}
