import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/features/practica/data/practica_libre_repositorio.dart';
import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica_libre.dart';
import 'package:prepion/shared/database/app_database.dart';

class _FakePracticaLibreRepositorio implements PracticaLibreRepositorio {
  _FakePracticaLibreRepositorio(this.preguntas);

  final List<Pregunta> preguntas;
  final List<Map<String, dynamic>> respuestasRegistradas = [];

  @override
  Future<Tema?> obtenerTema(String temaId) async {
    return Tema(id: temaId, materia: 'Química', nombre: 'Estequiometría');
  }

  @override
  Future<List<Pregunta>> obtenerPreguntasDeTema(String temaId) async {
    return preguntas;
  }

  @override
  Future<void> registrarRespuestaLibre({
    required String idEvento,
    required String preguntaId,
    required String? opcionElegida,
    required bool esCorrecta,
    required int tiempoMs,
    required DateTime respondidaEn,
  }) async {
    respuestasRegistradas.add({
      'idEvento': idEvento,
      'preguntaId': preguntaId,
      'opcionElegida': opcionElegida,
      'esCorrecta': esCorrecta,
      'tiempoMs': tiempoMs,
    });
  }

  @override
  Stream<List<ResumenMateria>> watchMaterias() => Stream.value([]);

  @override
  Stream<List<ResumenTema>> watchTemasDeMateria(String materiaOficial) =>
      Stream.value([]);

  @override
  Future<List<ResumenMateria>> obtenerMaterias() async => [];

  @override
  Future<List<ResumenTema>> obtenerTemasDeMateria(
    String materiaOficial,
  ) async => [];
}

void main() {
  const p1 = Pregunta(
    id: 'p1',
    examenId: 'e1',
    codigo: 'Q1',
    temaId: 't1',
    enunciado: 'Enunciado 1',
    opciones: ['A', 'B'],
    respuesta: 'A',
    explicacion: 'Expl 1',
    fuente: 'Fuente 1',
  );
  const p2 = Pregunta(
    id: 'p2',
    examenId: 'e1',
    codigo: 'Q2',
    temaId: 't1',
    enunciado: 'Enunciado 2',
    opciones: ['A', 'B'],
    respuesta: 'B',
    explicacion: 'Expl 2',
    fuente: 'Fuente 2',
  );

  test('carga preguntas y avanza en la sesion libre', () async {
    final fakeRepo = _FakePracticaLibreRepositorio([p1, p2]);
    final container = ProviderContainer(
      overrides: [
        practicaLibreRepositorioProvider.overrideWithValue(fakeRepo),
        relojProvider.overrideWithValue(() => DateTime.utc(2026, 11, 22, 12)),
        generadorDeIdProvider.overrideWithValue(() => 'uuid-1'),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(sesionPracticaLibreProvider('t1').notifier);
    await notifier.cargar();

    var estado = container.read(sesionPracticaLibreProvider('t1'));
    expect(estado.fase, FaseSesionLibre.respondiendo);
    expect(estado.preguntas, hasLength(2));
    expect(estado.indice, 0);

    await notifier.elegir('A');
    estado = container.read(sesionPracticaLibreProvider('t1'));
    expect(estado.fase, FaseSesionLibre.explicando);
    expect(estado.aciertos, 1);
    expect(estado.totalRespondidas, 1);
    expect(estado.respuesta, RespuestaDelPostulante.correcta);
    expect(fakeRepo.respuestasRegistradas, hasLength(1));

    notifier.siguiente();
    estado = container.read(sesionPracticaLibreProvider('t1'));
    expect(estado.fase, FaseSesionLibre.respondiendo);
    expect(estado.indice, 1);

    await notifier.noSe();
    estado = container.read(sesionPracticaLibreProvider('t1'));
    expect(estado.fase, FaseSesionLibre.explicando);
    expect(estado.aciertos, 1);
    expect(estado.totalRespondidas, 2);
    expect(estado.respuesta, RespuestaDelPostulante.noSe);

    notifier.siguiente();
    estado = container.read(sesionPracticaLibreProvider('t1'));
    expect(estado.fase, FaseSesionLibre.terminada);

    notifier.reiniciar();
    estado = container.read(sesionPracticaLibreProvider('t1'));
    expect(estado.fase, FaseSesionLibre.respondiendo);
    expect(estado.indice, 0);
    expect(estado.aciertos, 0);
  });

  test('pasa a fase vacia si el tema no tiene preguntas', () async {
    final fakeRepo = _FakePracticaLibreRepositorio([]);
    final container = ProviderContainer(
      overrides: [practicaLibreRepositorioProvider.overrideWithValue(fakeRepo)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(
      sesionPracticaLibreProvider('t_vacio').notifier,
    );
    await notifier.cargar();

    final estado = container.read(sesionPracticaLibreProvider('t_vacio'));
    expect(estado.fase, FaseSesionLibre.vacia);
  });
}
