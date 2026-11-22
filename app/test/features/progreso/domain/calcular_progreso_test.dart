import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/progreso/domain/bkt.dart';
import 'package:prepion/features/progreso/domain/calcular_progreso.dart';
import 'package:prepion/features/progreso/domain/resumen_progreso.dart';

const _materias = [
  'Aritmética-Álgebra',
  'Geometría-Trigonometría',
  'Física',
  'Química',
  'Biología',
];

final _ahora = DateTime(2026, 11, 22, 10);

const _temas = [
  TemaParaProgreso(
    id: 't1',
    materia: 'Aritmética-Álgebra',
    nombre: 'Ecuaciones',
  ),
  TemaParaProgreso(
    id: 't2',
    materia: 'Aritmética-Álgebra',
    nombre: 'Fracciones',
  ),
  TemaParaProgreso(id: 't3', materia: 'Física', nombre: 'Cinemática'),
  TemaParaProgreso(id: 't4', materia: 'Química', nombre: 'Estequiometría'),
  TemaParaProgreso(id: 't5', materia: 'Biología', nombre: 'Células'),
  TemaParaProgreso(
    id: 't6',
    materia: 'Geometría-Trigonometría',
    nombre: 'Identidades',
  ),
];

/// [n] respuestas del tema, todas aciertos o todas fallos, un minuto aparte.
List<RespuestaParaProgreso> _respuestas(String temaId, int n, bool acierto) => [
  for (var i = 0; i < n; i++)
    RespuestaParaProgreso(
      temaId: temaId,
      esCorrecta: acierto,
      respondidaEn: DateTime.utc(2026, 11, 20, 8, i),
    ),
];

/// Respuestas del tema con aciertos y fallos en el orden dado, un minuto aparte.
List<RespuestaParaProgreso> _secuencia(String temaId, List<bool> aciertos) => [
  for (var i = 0; i < aciertos.length; i++)
    RespuestaParaProgreso(
      temaId: temaId,
      esCorrecta: aciertos[i],
      respondidaEn: DateTime.utc(2026, 11, 20, 8, i),
    ),
];

/// Una respuesta de cada materia practicada: los 5 temas con la misma secuencia.
List<RespuestaParaProgreso> _lasCincoMaterias(
  List<List<bool>> secuenciaPorTema,
) => [
  for (var i = 0; i < secuenciaPorTema.length; i++)
    ..._secuencia(['t1', 't6', 't3', 't4', 't5'][i], secuenciaPorTema[i]),
];

ResumenProgreso _calcular(
  List<RespuestaParaProgreso> respuestas, {
  DateTime? fechaExamen,
  int racha = 0,
}) => calcularProgreso(
  respuestas: respuestas,
  temas: _temas,
  racha: racha,
  ahora: _ahora,
  fechaExamen: fechaExamen,
);

void main() {
  test('siempre trae las 5 materias en orden, sin datos si no practicó', () {
    // Actuar
    final resumen = _calcular(const []);

    // Verificar
    expect(resumen.materias.map((m) => m.materia), _materias);
    expect(resumen.materias.every((m) => m.dominio == null), isTrue);
    expect(resumen.materias.every((m) => m.respuestas == 0), isTrue);
    expect(resumen.dominioGlobal, isNull);
    expect(resumen.nivel, NivelPreparacion.sinDatos);
    expect(resumen.temasAReforzar, isEmpty);
    expect(resumen.totalRespuestas, 0);
  });

  test('el dominio de un tema sigue el BKT en orden cronológico', () {
    // Preparar: llegan desordenadas, primero fallo y luego acierto
    final respuestas = [
      RespuestaParaProgreso(
        temaId: 't3',
        esCorrecta: true,
        respondidaEn: DateTime.utc(2026, 11, 20, 9),
      ),
      RespuestaParaProgreso(
        temaId: 't3',
        esCorrecta: false,
        respondidaEn: DateTime.utc(2026, 11, 20, 8),
      ),
    ];
    final esperado = actualizarDominio(
      actualizarDominio(0.3, acerto: false),
      acerto: true,
    );

    // Actuar
    final resumen = _calcular(respuestas);

    // Verificar
    expect(resumen.temasAReforzar.single.dominio, closeTo(esperado, 1e-9));
    expect(resumen.temasAReforzar.single.respuestas, 2);
  });

  test('el dominio de la materia es el promedio de sus temas practicados', () {
    // Preparar
    final respuestas = [
      ..._respuestas('t1', 3, true),
      ..._respuestas('t2', 3, false),
    ];
    final d1 = _calcular(_respuestas('t1', 3, true)).materias.first.dominio!;
    final d2 = _calcular(_respuestas('t2', 3, false)).materias.first.dominio!;

    // Actuar
    final aritmetica = _calcular(respuestas).materias.first;

    // Verificar
    expect(aritmetica.dominio, closeTo((d1 + d2) / 2, 1e-9));
    expect(aritmetica.respuestas, 6);
  });

  test('el dominio global promedia las 5 materias y las no practicadas '
      'cuentan con el dominio inicial', () {
    // Preparar
    final respuestas = [
      ..._respuestas('t1', 5, true),
      ..._respuestas('t3', 5, false),
    ];

    // Actuar
    final resumen = _calcular(respuestas);

    // Verificar: 2 materias con datos y 3 sin practicar (valen 0,3 cada una)
    final algebra = resumen.materias[0].dominio!;
    final fisica = resumen.materias[2].dominio!;
    expect(
      resumen.dominioGlobal,
      closeTo((algebra + fisica + 3 * const ParametrosBkt().inicial) / 5, 1e-9),
    );
  });

  group('nivel', () {
    test('es sinDatos con menos de 10 respuestas aunque todas acierten', () {
      // Actuar
      final resumen = _calcular(_respuestas('t1', 9, true));

      // Verificar
      expect(resumen.nivel, NivelPreparacion.sinDatos);
      expect(resumen.totalRespuestas, 9);
    });

    test('es bajo cuando el dominio global está bajo el umbral rojo', () {
      // Actuar
      final resumen = _calcular(_respuestas('t1', 10, false));

      // Verificar
      expect(resumen.dominioGlobal, lessThan(umbralRojo));
      expect(resumen.nivel, NivelPreparacion.bajo);
    });

    test('es medio cuando el dominio global queda entre los umbrales', () {
      // Preparar: 2 temas con dos aciertos y 3 con acierto y fallo (global 0,55)
      final respuestas = _lasCincoMaterias([
        [true, true],
        [true, true],
        [true, false],
        [true, false],
        [true, false],
      ]);

      // Actuar
      final resumen = _calcular(respuestas);

      // Verificar
      expect(resumen.totalRespuestas, 10);
      expect(resumen.dominioGlobal, greaterThanOrEqualTo(umbralRojo));
      expect(resumen.dominioGlobal, lessThan(umbralVerde));
      expect(resumen.nivel, NivelPreparacion.medio);
    });

    test('es alto cuando las 5 materias alcanzan el umbral verde', () {
      // Preparar
      final respuestas = _lasCincoMaterias(List.filled(5, [true, true]));

      // Actuar
      final resumen = _calcular(respuestas);

      // Verificar
      expect(resumen.dominioGlobal, greaterThanOrEqualTo(umbralVerde));
      expect(resumen.nivel, NivelPreparacion.alto);
    });

    test('no llega a alto por dominar una sola materia', () {
      // Actuar: 10 aciertos, todos de Aritmética-Álgebra
      final resumen = _calcular(_respuestas('t1', 10, true));

      // Verificar: las otras 4 materias sin practicar frenan el nivel
      expect(resumen.materias.first.dominio, greaterThan(0.95));
      expect(resumen.nivel, isNot(NivelPreparacion.alto));
    });
  });

  group('temasAReforzar', () {
    test('trae los 3 más débiles, del más débil al más fuerte', () {
      // Preparar
      final respuestas = [
        ..._respuestas('t1', 4, true),
        ..._respuestas('t2', 1, true),
        ..._respuestas('t3', 4, false),
        ..._respuestas('t4', 1, false),
        ..._respuestas('t5', 2, false),
      ];

      // Actuar
      final temas = _calcular(respuestas).temasAReforzar;

      // Verificar
      expect(temas, hasLength(3));
      expect(temas.map((t) => t.temaId), ['t3', 't5', 't4']);
      expect(temas[0].dominio, lessThanOrEqualTo(temas[1].dominio));
      expect(temas[1].dominio, lessThanOrEqualTo(temas[2].dominio));
    });

    test('ante igual dominio gana el de más respuestas y luego el nombre', () {
      // Preparar: los tres con un solo fallo, empatan en dominio y respuestas
      final respuestas = [
        ..._respuestas('t5', 1, false),
        ..._respuestas('t4', 1, false),
        ..._respuestas('t3', 1, false),
      ];

      // Actuar
      final temas = _calcular(respuestas).temasAReforzar;

      // Verificar: nombres Cinemática < Células < Estequiometría
      expect(temas.map((t) => t.temaId), ['t3', 't5', 't4']);
    });

    test('con empate de dominio va primero el de más respuestas', () {
      // Preparar: con adivinar = error = 0.5 y aprendizaje = 0 el dominio
      // no cambia, así que todos empatan en el inicial
      const neutro = ParametrosBkt(aprendizaje: 0, adivinar: 0.5, error: 0.5);
      final respuestas = [
        ..._respuestas('t1', 1, true),
        ..._respuestas('t2', 3, true),
      ];

      // Actuar
      final temas = calcularProgreso(
        respuestas: respuestas,
        temas: _temas,
        racha: 0,
        ahora: _ahora,
        parametros: neutro,
      ).temasAReforzar;

      // Verificar
      expect(temas.map((t) => t.temaId), ['t2', 't1']);
    });

    test('no incluye temas que nunca se practicaron', () {
      // Actuar
      final temas = _calcular(_respuestas('t1', 2, true)).temasAReforzar;

      // Verificar
      expect(temas.map((t) => t.temaId), ['t1']);
    });
  });

  group('diasParaElExamen', () {
    test('es null cuando no hay fecha de examen', () {
      expect(_calcular(const []).diasParaElExamen, isNull);
    });

    test('cuenta días de calendario ignorando la hora', () {
      // Actuar
      final resumen = _calcular(
        const [],
        fechaExamen: DateTime(2026, 12, 2, 7),
      );

      // Verificar
      expect(resumen.diasParaElExamen, 10);
    });

    test('es 0 el mismo día del examen', () {
      final resumen = _calcular(
        const [],
        fechaExamen: DateTime(2026, 11, 22, 23),
      );

      expect(resumen.diasParaElExamen, 0);
    });

    test('es 0 cuando el examen ya pasó', () {
      final resumen = _calcular(const [], fechaExamen: DateTime(2026, 11, 1));

      expect(resumen.diasParaElExamen, 0);
    });
  });

  test('ignora las respuestas de temas desconocidos', () {
    // Preparar
    final respuestas = [
      ..._respuestas('t1', 2, true),
      ..._respuestas('fantasma', 5, true),
    ];

    // Actuar
    final resumen = _calcular(respuestas);

    // Verificar
    expect(resumen.totalRespuestas, 2);
    expect(resumen.temasAReforzar.map((t) => t.temaId), ['t1']);
  });

  test('copia la racha recibida', () {
    expect(_calcular(const [], racha: 4).racha, 4);
  });
}
