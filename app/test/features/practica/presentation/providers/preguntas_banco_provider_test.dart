import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/presentation/providers/preguntas_banco_provider.dart';
import 'package:prepion/shared/database/app_database.dart';

Future<void> _insertar(AppDatabase base, String codigo) => base
    .into(base.preguntas)
    .insert(
      PreguntasCompanion.insert(
        id: 'id-$codigo',
        examenId: 'examen-1',
        codigo: codigo,
        temaId: const Value(null),
        enunciado: 'Enunciado $codigo',
        opciones: const ['a', 'b'],
        respuesta: 'A',
        explicacion: 'Explicación',
        fuente: 'Fuente',
      ),
    );

void main() {
  late AppDatabase baseDeDatos;

  setUp(() async {
    baseDeDatos = AppDatabase(NativeDatabase.memory());
    await baseDeDatos
        .into(baseDeDatos.examenes)
        .insert(
          ExamenesCompanion.insert(
            id: 'examen-1',
            gestion: '2-2026',
            tipo: '2op',
            archivo: '2026-2-2op.pdf',
          ),
        );
  });

  tearDown(() async {
    await baseDeDatos.close();
  });

  test('ordena por serie y número y no por texto (G6 antes que G10)', () async {
    // Preparar
    for (final codigo in ['S1-G10', 'S2-A1', 'S1-G6', 'S1-A1']) {
      await _insertar(baseDeDatos, codigo);
    }
    final contenedor = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(baseDeDatos)],
    );
    addTearDown(contenedor.dispose);
    // Riverpod 3 pausa los proveedores sin oyentes: hay que escuchar para recibir datos.
    contenedor.listen(preguntasDelBancoProvider, (anterior, actual) {});

    // Actuar
    final preguntas = await contenedor.read(preguntasDelBancoProvider.future);

    // Verificar
    expect(preguntas.map((p) => p.codigo), [
      'S1-A1',
      'S1-G6',
      'S1-G10',
      'S2-A1',
    ]);
  });

  test('devuelve una lista vacía cuando no hay preguntas guardadas', () async {
    // Preparar
    final contenedor = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(baseDeDatos)],
    );
    addTearDown(contenedor.dispose);
    // Riverpod 3 pausa los proveedores sin oyentes: hay que escuchar para recibir datos.
    contenedor.listen(preguntasDelBancoProvider, (anterior, actual) {});

    // Actuar
    final preguntas = await contenedor.read(preguntasDelBancoProvider.future);

    // Verificar
    expect(preguntas, isEmpty);
  });
}
