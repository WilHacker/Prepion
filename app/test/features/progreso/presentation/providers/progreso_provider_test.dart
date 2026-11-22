import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/features/progreso/domain/resumen_progreso.dart';
import 'package:prepion/features/progreso/presentation/providers/progreso_provider.dart';
import 'package:prepion/shared/database/app_database.dart';

void main() {
  late AppDatabase baseDeDatos;
  late ProviderContainer contenedor;
  final ahora = DateTime.utc(2026, 11, 22, 15);

  ProviderContainer crear({DateTime? fechaExamen}) {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(baseDeDatos),
        relojProvider.overrideWithValue(() => ahora),
        fechaExamenProvider.overrideWithValue(fechaExamen),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<ResumenProgreso> leer() {
    contenedor.listen(progresoProvider, (anterior, actual) {});
    return contenedor.read(progresoProvider.future);
  }

  setUp(() async {
    baseDeDatos = AppDatabase(NativeDatabase.memory());
    await baseDeDatos
        .into(baseDeDatos.examenes)
        .insert(
          ExamenesCompanion.insert(
            id: 'examen-1',
            gestion: '2-2026',
            tipo: '2op',
            archivo: 'x.pdf',
          ),
        );
    await baseDeDatos
        .into(baseDeDatos.temas)
        .insert(
          TemasCompanion.insert(
            id: 't-fis',
            materia: 'Física',
            nombre: 'Cinemática',
          ),
        );
    await baseDeDatos
        .into(baseDeDatos.preguntas)
        .insert(
          PreguntasCompanion.insert(
            id: 'p1',
            examenId: 'examen-1',
            codigo: 'S1-F1',
            temaId: const Value('t-fis'),
            enunciado: 'Enunciado',
            opciones: const ['a', 'b'],
            respuesta: 'B',
            explicacion: 'Explicación',
            fuente: 'Fuente',
          ),
        );
    contenedor = crear();
  });

  tearDown(() async {
    await baseDeDatos.close();
  });

  test('sin respuestas devuelve un resumen sin datos', () async {
    // Actuar
    final resumen = await leer();

    // Verificar
    expect(resumen.nivel, NivelPreparacion.sinDatos);
    expect(resumen.materias, hasLength(5));
    expect(resumen.racha, 0);
    expect(resumen.diasParaElExamen, isNull);
  });

  test('combina respuestas guardadas, racha y fecha de examen', () async {
    // Preparar
    await baseDeDatos
        .into(baseDeDatos.respuestasLocales)
        .insert(
          RespuestasLocalesCompanion.insert(
            idEvento: 'e1',
            preguntaId: 'p1',
            esCorrecta: true,
            calificacion: 3,
            tiempoMs: 1000,
            respondidaEn: ahora,
          ),
        );
    contenedor = crear(fechaExamen: DateTime(2026, 12, 2));

    // Actuar
    final resumen = await leer();

    // Verificar
    expect(resumen.totalRespuestas, 1);
    expect(resumen.racha, 1);
    expect(resumen.diasParaElExamen, 10);
    expect(resumen.temasAReforzar.single.temaId, 't-fis');
    expect(
      resumen.materias.firstWhere((m) => m.materia == 'Física').respuestas,
      1,
    );
  });
}
