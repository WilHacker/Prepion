import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/shared/database/app_database.dart';

final _inicio = DateTime.utc(2026, 11, 23, 9);

void main() {
  late AppDatabase baseDeDatos;
  late DateTime ahora;
  late int contadorDeIds;

  Future<void> sembrarBanco(int cantidad) async {
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
            id: 'tema-1',
            materia: 'Química',
            nombre: 'Estequiometría',
          ),
        );
    for (var i = 1; i <= cantidad; i++) {
      await baseDeDatos
          .into(baseDeDatos.preguntas)
          .insert(
            PreguntasCompanion.insert(
              id: 'p$i',
              examenId: 'examen-1',
              codigo: 'S1-Q$i',
              temaId: const Value('tema-1'),
              enunciado: 'Enunciado $i',
              opciones: const ['a', 'b', 'c', 'd', 'e'],
              respuesta: 'B', // la correcta de todas es B
              explicacion: 'Explicación $i',
              fuente: 'Fuente $i',
            ),
          );
    }
  }

  ProviderContainer crearContenedor({int meta = 10}) {
    final contenedor = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(baseDeDatos),
        relojProvider.overrideWithValue(() => ahora),
        generadorDeIdProvider.overrideWithValue(
          () => 'evento-${++contadorDeIds}',
        ),
        metaDiariaProvider.overrideWithValue(meta),
      ],
    );
    addTearDown(contenedor.dispose);
    // Riverpod 3 pausa los proveedores sin oyentes.
    contenedor.listen(sesionPracticaProvider, (anterior, actual) {});
    return contenedor;
  }

  setUp(() {
    baseDeDatos = AppDatabase(NativeDatabase.memory());
    ahora = _inicio;
    contadorDeIds = 0;
  });

  tearDown(() async {
    await baseDeDatos.close();
  });

  test('queda vacía cuando no hay preguntas para practicar', () async {
    final contenedor = crearContenedor();

    await contenedor.read(sesionPracticaProvider.notifier).iniciar();

    expect(contenedor.read(sesionPracticaProvider).fase, FaseSesion.vacia);
  });

  test('arma una sesión con exactamente la meta diaria de preguntas', () async {
    await sembrarBanco(5);
    final contenedor = crearContenedor(meta: 3);

    await contenedor.read(sesionPracticaProvider.notifier).iniciar();

    final estado = contenedor.read(sesionPracticaProvider);
    expect(estado.fase, FaseSesion.respondiendo);
    expect(estado.preguntas, hasLength(3));
    expect(estado.indice, 0);
  });

  test('acertar muestra la explicación como respuesta correcta', () async {
    await sembrarBanco(2);
    final contenedor = crearContenedor();
    final sesion = contenedor.read(sesionPracticaProvider.notifier);
    await sesion.iniciar();

    sesion.elegir('B');

    final estado = contenedor.read(sesionPracticaProvider);
    expect(estado.fase, FaseSesion.explicando);
    expect(estado.respuesta, RespuestaDelPostulante.correcta);
    expect(estado.letraElegida, 'B');
  });

  test('fallar muestra la explicación como respuesta incorrecta', () async {
    await sembrarBanco(2);
    final contenedor = crearContenedor();
    final sesion = contenedor.read(sesionPracticaProvider.notifier);
    await sesion.iniciar();

    sesion.elegir('C');

    expect(
      contenedor.read(sesionPracticaProvider).respuesta,
      RespuestaDelPostulante.incorrecta,
    );
  });

  test('"No sé" cuenta como fallo y no guarda una opción elegida', () async {
    await sembrarBanco(2);
    final contenedor = crearContenedor();
    final sesion = contenedor.read(sesionPracticaProvider.notifier);
    await sesion.iniciar();

    sesion.noSe();
    await sesion.siguiente();

    final respuesta = await baseDeDatos
        .select(baseDeDatos.respuestasLocales)
        .getSingle();
    expect(respuesta.opcionElegida, isNull);
    expect(respuesta.esCorrecta, isFalse);
    expect(respuesta.calificacion, 1);
  });

  test(
    '"Me costó" y "Fue fácil" afinan el acierto y se pueden deshacer',
    () async {
      await sembrarBanco(2);
      final contenedor = crearContenedor();
      final sesion = contenedor.read(sesionPracticaProvider.notifier);
      await sesion.iniciar();
      sesion.elegir('B');

      sesion.marcarDificultad(RespuestaDelPostulante.correctaMeCosto);
      expect(
        contenedor.read(sesionPracticaProvider).respuesta,
        RespuestaDelPostulante.correctaMeCosto,
      );

      sesion.marcarDificultad(RespuestaDelPostulante.correctaFacil);
      expect(
        contenedor.read(sesionPracticaProvider).respuesta,
        RespuestaDelPostulante.correctaFacil,
      );

      sesion.marcarDificultad(RespuestaDelPostulante.correctaFacil);
      expect(
        contenedor.read(sesionPracticaProvider).respuesta,
        RespuestaDelPostulante.correcta,
      );
    },
  );

  test('no permite afinar la dificultad de una respuesta fallada', () async {
    await sembrarBanco(2);
    final contenedor = crearContenedor();
    final sesion = contenedor.read(sesionPracticaProvider.notifier);
    await sesion.iniciar();
    sesion.elegir('A');

    sesion.marcarDificultad(RespuestaDelPostulante.correctaFacil);

    expect(
      contenedor.read(sesionPracticaProvider).respuesta,
      RespuestaDelPostulante.incorrecta,
    );
  });

  test(
    'guarda la respuesta con su calificación, tiempo y evento al seguir',
    () async {
      await sembrarBanco(2);
      final contenedor = crearContenedor();
      final sesion = contenedor.read(sesionPracticaProvider.notifier);
      await sesion.iniciar();
      ahora = _inicio.add(const Duration(seconds: 7));
      sesion.elegir('B');
      sesion.marcarDificultad(RespuestaDelPostulante.correctaFacil);

      await sesion.siguiente();

      final respuesta = await baseDeDatos
          .select(baseDeDatos.respuestasLocales)
          .getSingle();
      expect(respuesta.idEvento, 'evento-1');
      expect(respuesta.opcionElegida, 'B');
      expect(respuesta.esCorrecta, isTrue);
      expect(respuesta.calificacion, 4);
      expect(respuesta.tiempoMs, 7000);
      final estado = contenedor.read(sesionPracticaProvider);
      expect(estado.fase, FaseSesion.respondiendo);
      expect(estado.indice, 1);
      expect(estado.letraElegida, isNull);
    },
  );

  test('una pregunta fallada vuelve a tocar al día siguiente', () async {
    await sembrarBanco(1);
    final contenedor = crearContenedor();
    final sesion = contenedor.read(sesionPracticaProvider.notifier);
    await sesion.iniciar();
    sesion.elegir('A');

    await sesion.siguiente();

    final tarjeta = await baseDeDatos
        .select(baseDeDatos.tarjetasFsrs)
        .getSingle();
    expect(tarjeta.vence.toUtc(), _inicio.add(const Duration(days: 1)));
  });

  test(
    'un doble toque en "Siguiente" no guarda la respuesta dos veces',
    () async {
      await sembrarBanco(2);
      final contenedor = crearContenedor();
      final sesion = contenedor.read(sesionPracticaProvider.notifier);
      await sesion.iniciar();
      sesion.elegir('B');

      await Future.wait([sesion.siguiente(), sesion.siguiente()]);

      expect(
        await baseDeDatos.select(baseDeDatos.respuestasLocales).get(),
        hasLength(1),
      );
    },
  );

  test('termina con el resumen de aciertos, fallos, tiempo y racha', () async {
    await sembrarBanco(2);
    final contenedor = crearContenedor();
    final sesion = contenedor.read(sesionPracticaProvider.notifier);
    await sesion.iniciar();

    ahora = _inicio.add(const Duration(seconds: 3));
    sesion.elegir('B');
    await sesion.siguiente();
    ahora = _inicio.add(const Duration(seconds: 8));
    sesion.elegir('C');
    await sesion.siguiente();

    final estado = contenedor.read(sesionPracticaProvider);
    expect(estado.fase, FaseSesion.terminada);
    expect(estado.aciertos, 1);
    expect(estado.fallos, 1);
    expect(estado.tiempoTotalMs, 3000 + 5000);
    expect(estado.racha, 1);
  });

  test('al volver a practicar no repite lo que ya se respondió bien', () async {
    await sembrarBanco(2);
    final contenedor = crearContenedor();
    final sesion = contenedor.read(sesionPracticaProvider.notifier);
    await sesion.iniciar();
    for (var i = 0; i < 2; i++) {
      sesion.elegir('B');
      await sesion.siguiente();
    }

    await sesion.iniciar();

    expect(contenedor.read(sesionPracticaProvider).fase, FaseSesion.vacia);
  });

  test('ignora respuestas cuando no es el momento de responder', () async {
    await sembrarBanco(2);
    final contenedor = crearContenedor();
    final sesion = contenedor.read(sesionPracticaProvider.notifier);

    sesion.elegir('B'); // todavía cargando
    await sesion.iniciar();
    sesion.elegir('B');
    sesion.elegir('C'); // ya está explicando: no cambia

    final estado = contenedor.read(sesionPracticaProvider);
    expect(estado.letraElegida, 'B');
    expect(estado.fase, FaseSesion.explicando);
  });
}
