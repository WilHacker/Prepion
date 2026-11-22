import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/reportes/data/reportes_repositorio.dart';
import 'package:prepion/features/reportes/data/reportes_service.dart';
import 'package:prepion/shared/database/app_database.dart';

void main() {
  late AppDatabase db;
  late ReportesRepositorio repo;
  late Dio dio;
  late ReportesService servicio;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ReportesRepositorio(db);
    dio = Dio(BaseOptions(baseUrl: 'http://test.local/api'));
    servicio = ReportesService(
      clienteApi: dio,
      repositorio: repo,
      generadorUuid: () => 'uuid-falso-reporte',
    );
  });

  tearDown(() => db.close());

  test('envía reporte exitosamente cuando hay red y marca enviado', () async {
    // Arrange
    final llamadasPost = <Map<String, dynamic>>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          llamadasPost.add({'path': options.path, 'data': options.data});
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 201,
              data: {'id': 'rep-ok'},
            ),
          );
        },
      ),
    );

    // Act
    final resultado = await servicio.enviarReporte(
      preguntaId: 'preg-100',
      motivo: 'respuesta_incorrecta',
      comentario: 'La opción A no es la correcta',
    );

    // Assert
    expect(resultado, isTrue);
    expect(llamadasPost, hasLength(1));
    expect(llamadasPost.first['path'], '/reportes');

    final guardados = await db.select(db.colaReportes).get();
    expect(guardados, hasLength(1));
    expect(guardados.first.estado, 'enviado');
    expect(guardados.first.motivo, 'respuesta_incorrecta');
    expect(guardados.first.comentario, 'La opción A no es la correcta');
  });

  test('guarda como pendiente cuando no hay red sin lanzar error', () async {
    // Arrange: simular fallo de conexión
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Sin red',
              type: DioExceptionType.connectionError,
            ),
          );
        },
      ),
    );

    // Act
    final resultado = await servicio.enviarReporte(
      preguntaId: 'preg-101',
      motivo: 'imagen_borrosa',
    );

    // Assert
    expect(resultado, isTrue);
    final pendientes = await repo.obtenerPendientes();
    expect(pendientes, hasLength(1));
    expect(pendientes.first.estado, 'pendiente');
    expect(pendientes.first.motivo, 'imagen_borrosa');
  });

  test(
    'sincroniza reportes pendientes acumulados cuando vuelve la red',
    () async {
      // Arrange: un reporte encolado offline
      await repo.guardarReporte(
        id: 'rep-offline-1',
        preguntaId: 'preg-50',
        motivo: 'error_tipografico',
        comentario: 'Falta un punto',
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {'ok': true},
              ),
            );
          },
        ),
      );

      // Act
      final sincronizados = await servicio.sincronizarPendientes();

      // Assert
      expect(sincronizados, 1);
      final pendientesRestantes = await repo.obtenerPendientes();
      expect(pendientesRestantes, isEmpty);
      final todos = await db.select(db.colaReportes).get();
      expect(todos.first.estado, 'enviado');
    },
  );
}
