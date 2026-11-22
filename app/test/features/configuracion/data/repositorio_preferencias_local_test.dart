import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/features/configuracion/data/parametros_publicos_remote.dart';
import 'package:prepion/features/configuracion/data/repositorio_preferencias_local.dart';
import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('devuelve null cuando no existen preferencias guardadas', () async {
    // Preparar
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repo = RepositorioPreferenciasLocal(prefs);

    // Actuar
    final cargadas = await repo.cargar();

    // Verificar
    expect(cargadas, isNull);
  });

  test('persiste y recupera las preferencias en shared_preferences', () async {
    // Preparar
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repo = RepositorioPreferenciasLocal(prefs);
    final esperadas = PreferenciasEstudio(
      idUsuarioLocal: '11111111-2222-4333-8444-555555555555',
      fechaExamen: DateTime(2027, 1, 25),
      metaDiaria: 20,
      horaEstudio: 18,
      minutoEstudio: 30,
      onboardingCompletado: true,
    );

    // Actuar
    await repo.guardar(esperadas);
    final cargadas = await repo.cargar();

    // Verificar
    expect(cargadas, isNotNull);
    expect(cargadas!.idUsuarioLocal, esperadas.idUsuarioLocal);
    expect(cargadas.fechaExamen, esperadas.fechaExamen);
    expect(cargadas.metaDiaria, 20);
    expect(cargadas.horaEstudio, 18);
    expect(cargadas.minutoEstudio, 30);
    expect(cargadas.onboardingCompletado, isTrue);
    expect(
      prefs.getString(ClavesPreferencias.idUsuarioLocal),
      esperadas.idUsuarioLocal,
    );
  });

  test(
    'obtiene parámetros públicos remotos cuando el backend responde 200',
    () async {
      // Preparar
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response<Map<String, Object?>>(
                requestOptions: options,
                statusCode: 200,
                data: <String, Object?>{
                  'fechasTentativasExamen': <Object?>[
                    <String, Object?>{
                      'etiqueta': '1.ª opción · Gestión 1-2027',
                      'fecha': '2027-01-25',
                      'esRecomendada': true,
                    },
                  ],
                  'metasDiariasOpciones': <Object?>[5, 10, 20],
                  'metaDiariaSugerida': 5,
                  'horaEstudioSugerida': '21:15',
                  'minPreguntasDiarias': 5,
                  'maxPreguntasDiarias': 50,
                },
              ),
            );
          },
        ),
      );
      final remote = ParametrosPublicosRemote(dio);

      // Actuar
      final resultado = await remote.obtener();

      // Verificar
      expect(resultado.metaDiariaSugerida, 5);
      expect(resultado.horaEstudioRecomendada, (21, 15));
    },
  );

  test(
    'usa valores locales por defecto cuando no hay conexión con el backend',
    () async {
      // Preparar
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );
      final remote = ParametrosPublicosRemote(dio);

      // Actuar
      final resultado = await remote.obtener();

      // Verificar
      expect(resultado.metasDiariasOpciones, metasDiariasDisponibles);
      expect(resultado.fechasTentativasExamen, isNotEmpty);
    },
  );
}
