import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/data/banco_local_service.dart';
import 'package:prepion/features/practica/domain/banco_invalido_error.dart';
import 'package:prepion/shared/database/app_database.dart';

Map<String, Object?> _bancoDePrueba({String enunciado = 'Enunciado 1'}) => {
  'version': 1,
  'examenes': [
    {
      'id': 'examen-1',
      'gestion': '2-2026',
      'tipo': '1op',
      'archivo': '2026-2-1op.pdf',
    },
  ],
  'temas': [
    {'id': 'tema-1', 'materia': 'Química', 'nombre': 'Estequiometría'},
  ],
  'preguntas': [
    {
      'id': 'pregunta-1',
      'examenId': 'examen-1',
      'codigo': 'B18',
      'temaId': 'tema-1',
      'enunciado': enunciado,
      'opciones': ['a', 'b', 'c', 'd', 'e'],
      'respuesta': 'A',
      'explicacion': 'Porque sí.',
      'rutaImagen': null,
      'fuente': 'Examen de ingreso FCyT · 1.ª opción · 2-2026 · B18',
    },
  ],
};

void main() {
  late AppDatabase baseDeDatos;

  setUp(() {
    baseDeDatos = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await baseDeDatos.close();
  });

  BancoLocalService servicioCon(Object? banco) => BancoLocalService(
    baseDeDatos,
    () async => banco is String ? banco : jsonEncode(banco),
  );

  test(
    'importa exámenes, temas y preguntas cuando la base está vacía',
    () async {
      // Preparar
      final servicio = servicioCon(_bancoDePrueba());

      // Actuar
      final seImporto = await servicio.importarSemillaSiHaceFalta();

      // Verificar
      final preguntas = await baseDeDatos.select(baseDeDatos.preguntas).get();
      expect(seImporto, isTrue);
      expect(
        await baseDeDatos.select(baseDeDatos.examenes).get(),
        hasLength(1),
      );
      expect(await baseDeDatos.select(baseDeDatos.temas).get(), hasLength(1));
      expect(preguntas.single.opciones, ['a', 'b', 'c', 'd', 'e']);
      expect(preguntas.single.rutaImagen, isNull);
    },
  );

  test('no vuelve a importar cuando ya hay preguntas guardadas', () async {
    // Preparar
    await servicioCon(_bancoDePrueba()).importarSemillaSiHaceFalta();
    final otraSemilla = servicioCon(_bancoDePrueba(enunciado: 'Otro texto'));

    // Actuar
    final seImporto = await otraSemilla.importarSemillaSiHaceFalta();

    // Verificar
    final pregunta = await baseDeDatos
        .select(baseDeDatos.preguntas)
        .getSingle();
    expect(seImporto, isFalse);
    expect(pregunta.enunciado, 'Enunciado 1');
  });

  test('no guarda nada cuando la semilla no trae preguntas', () async {
    // Preparar
    final servicio = servicioCon({
      'version': 0,
      'examenes': <Object?>[],
      'temas': <Object?>[],
      'preguntas': <Object?>[],
    });

    // Actuar
    final seImporto = await servicio.importarSemillaSiHaceFalta();

    // Verificar
    expect(seImporto, isFalse);
    expect(await baseDeDatos.select(baseDeDatos.preguntas).get(), isEmpty);
  });

  test('lanza BancoInvalidoError cuando el texto no es JSON', () async {
    // Preparar
    final servicio = servicioCon('esto no es json');

    // Actuar y verificar
    expect(
      servicio.importarSemillaSiHaceFalta,
      throwsA(isA<BancoInvalidoError>()),
    );
  });

  test('lanza BancoInvalidoError cuando falta un campo obligatorio', () async {
    // Preparar
    final banco = _bancoDePrueba();
    final preguntas = banco['preguntas']! as List<Object?>;
    (preguntas.first! as Map<String, Object?>).remove('respuesta');
    final servicio = servicioCon(banco);

    // Actuar y verificar
    expect(
      servicio.importarSemillaSiHaceFalta,
      throwsA(
        isA<BancoInvalidoError>().having(
          (error) => error.mensaje,
          'mensaje',
          contains('respuesta'),
        ),
      ),
    );
  });

  test('no deja datos a medias cuando una pregunta apunta a un examen '
      'inexistente', () async {
    // Preparar
    final banco = _bancoDePrueba();
    final preguntas = banco['preguntas']! as List<Object?>;
    (preguntas.first! as Map<String, Object?>)['examenId'] = 'no-existe';
    final servicio = servicioCon(banco);

    // Actuar
    await expectLater(
      servicio.importarSemillaSiHaceFalta,
      throwsA(isA<BancoInvalidoError>()),
    );

    // Verificar
    expect(await baseDeDatos.select(baseDeDatos.examenes).get(), isEmpty);
  });
}
