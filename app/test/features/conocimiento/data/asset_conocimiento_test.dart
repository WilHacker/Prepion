import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/features/conocimiento/domain/parametros_conocimiento.dart';

Future<Object?> _json(String ruta) async =>
    jsonDecode(await rootBundle.loadString(ruta));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('paquete de conocimiento empaquetado en la app', () {
    test('es válido para el modelo estricto', () async {
      // Actuar
      final json = await _json('assets/datos/parametros_conocimiento.json');

      // Verificar: fromJson lanza si algo no cumple las reglas de validación.
      final parametros = ParametrosConocimiento.fromJson(json);
      expect(parametros.version, greaterThanOrEqualTo(1));
      expect(parametros.dificultadPorPregunta, isNotEmpty);
      expect(parametros.bktPorTema, isNotEmpty);
    });

    test('cubre exactamente las preguntas y los temas del banco', () async {
      // Preparar
      final banco = await _json(
        'assets/datos/banco_semilla.json',
      ) as Map<String, dynamic>;
      final idsPreguntas = {
        for (final p in banco['preguntas'] as List<dynamic>)
          (p as Map<String, dynamic>)['id'] as String,
      };
      final idsTemas = {
        for (final t in banco['temas'] as List<dynamic>)
          (t as Map<String, dynamic>)['id'] as String,
      };

      // Actuar
      final parametros = ParametrosConocimiento.fromJson(
        await _json('assets/datos/parametros_conocimiento.json'),
      );

      // Verificar: un id de más o de menos significaría parámetros de otro banco.
      expect(parametros.dificultadPorPregunta.keys.toSet(), idsPreguntas);
      expect(parametros.bktPorTema.keys.toSet(), idsTemas);
    });

    test('declara de dónde salen sus datos', () async {
      // Actuar
      final parametros = ParametrosConocimiento.fromJson(
        await _json('assets/datos/parametros_conocimiento.json'),
      );

      // Verificar: no debe presentarse como real si fue calibrado con simulación.
      expect(parametros.origen, anyOf('simulado', 'real'));
    });
  });
}
