import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/features/practica/data/banco_local_service.dart';
import 'package:prepion/features/sincronizacion/data/sincronizacion_repositorio.dart';
import 'package:prepion/features/sincronizacion/data/sincronizacion_service.dart';
import 'package:prepion/shared/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late SincronizacionRepositorio repo;
  late BancoLocalService bancoService;
  late Dio dio;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    db = AppDatabase(NativeDatabase.memory());
    repo = SincronizacionRepositorio(db);
    bancoService = BancoLocalService(db, () async => '{}');
    dio = Dio(BaseOptions(baseUrl: 'http://test.local/api'));

    // Insertar examen y pregunta para cumplir integridad referencial
    await db
        .into(db.examenes)
        .insert(
          ExamenesCompanion.insert(
            id: 'ex1',
            gestion: '2-2026',
            tipo: '1op',
            archivo: 'x',
          ),
        );
    await db
        .into(db.preguntas)
        .insert(
          PreguntasCompanion.insert(
            id: 'p1',
            examenId: 'ex1',
            codigo: 'MAT-01',
            enunciado: '¿2+2?',
            opciones: ['3', '4'],
            respuesta: 'B',
            explicacion: '4',
            fuente: 'oficial',
          ),
        );
  });

  tearDown(() => db.close());

  test(
    'sincroniza respuestas satisfactoriamente cuando el servidor responde 200',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final ahora = DateTime.now();
      await db
          .into(db.colaSincronizacion)
          .insert(
            ColaSincronizacionCompanion.insert(
              idEvento: 'ev1',
              preguntaId: 'p1',
              esCorrecta: true,
              tiempoMs: 1500,
              respondidaEn: ahora,
              creadoEn: ahora,
              actualizadoEn: ahora,
            ),
          );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == '/sincronizacion/lote') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {'recibidos': 1, 'insertados': 1, 'duplicados': 0},
                ),
              );
            }
            handler.next(options);
          },
        ),
      );

      final service = SincronizacionService(
        clienteApi: dio,
        repositorio: repo,
        bancoLocalService: bancoService,
        almacenamiento: prefs,
      );

      final enviados = await service.sincronizarRespuestas();
      expect(enviados, 1);

      final pendientes = await repo.obtenerPendientes();
      expect(pendientes, isEmpty);
    },
  );

  test(
    'silencia errores de red y marca intentos fallidos sin lanzar excepciones',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final ahora = DateTime.now();
      await db
          .into(db.colaSincronizacion)
          .insert(
            ColaSincronizacionCompanion.insert(
              idEvento: 'ev1',
              preguntaId: 'p1',
              esCorrecta: true,
              tiempoMs: 1500,
              respondidaEn: ahora,
              creadoEn: ahora,
              actualizadoEn: ahora,
            ),
          );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
          },
        ),
      );

      final service = SincronizacionService(
        clienteApi: dio,
        repositorio: repo,
        bancoLocalService: bancoService,
        almacenamiento: prefs,
      );

      final enviados = await service.sincronizarRespuestas();
      expect(enviados, 0);

      final fila = await (db.select(
        db.colaSincronizacion,
      )..where((t) => t.idEvento.equals('ev1'))).getSingle();

      expect(fila.estado, 'fallido');
      expect(fila.intentos, 1);
    },
  );

  test('descarga nuevo banco cuando la versión remota es mayor', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(claveVersionBancoLocal, 1);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/preguntas/banco/actual') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'version': 2,
                  'cantidad': 1,
                  'publicadaEn': '2026-11-22T00:00:00Z',
                },
              ),
            );
          }
          if (options.path == '/preguntas/banco/descargar/2') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'version': 2,
                  'examenes': [
                    {
                      'id': 'ex2',
                      'gestion': '1-2026',
                      'tipo': '1op',
                      'archivo': 'f',
                    },
                  ],
                  'temas': [
                    {'id': 't1', 'materia': 'Matemáticas', 'nombre': 'Álgebra'},
                  ],
                  'preguntas': [
                    {
                      'id': 'p2',
                      'examenId': 'ex2',
                      'codigo': 'MAT-02',
                      'temaId': 't1',
                      'enunciado': '¿3+3?',
                      'opciones': ['5', '6'],
                      'respuesta': 'B',
                      'explicacion': '6',
                      'fuente': 'oficial',
                    },
                  ],
                },
              ),
            );
          }
          handler.next(options);
        },
      ),
    );

    final service = SincronizacionService(
      clienteApi: dio,
      repositorio: repo,
      bancoLocalService: bancoService,
      almacenamiento: prefs,
    );

    final actualizado = await service.sincronizarBancoSiHayNuevaVersion();
    expect(actualizado, isTrue);

    final versionFinal = prefs.getInt(claveVersionBancoLocal);
    expect(versionFinal, 2);
  });
}
