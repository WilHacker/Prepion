import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:prepion/features/cuentas/domain/cuenta.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String claveTokenCuenta = 'cuenta_token';
const String claveDatosCuenta = 'cuenta_datos';

/// Registro, inicio de sesión y panel de administración contra el servidor.
///
/// La app sigue funcionando sin cuenta y sin red: esto solo lo usan quienes
/// quieren respaldar su progreso o administrar la plataforma.
class RepositorioCuentas {
  RepositorioCuentas(this._prefs, this._cliente);

  final SharedPreferences _prefs;
  final Dio _cliente;

  /// Cuenta de la última sesión iniciada en este dispositivo, si hay.
  Cuenta? sesionGuardada() {
    final texto = _prefs.getString(claveDatosCuenta);
    if (texto == null || _prefs.getString(claveTokenCuenta) == null) {
      return null;
    }
    try {
      return Cuenta.desdeJson(
        (jsonDecode(texto) as Map<String, dynamic>).cast<String, Object?>(),
      );
    } on Object {
      return null;
    }
  }

  Future<Cuenta> iniciarSesion(String correo, String contrasena) =>
      _autenticar('/auth/login', correo, contrasena);

  Future<Cuenta> registrar(String correo, String contrasena) =>
      _autenticar('/auth/registro', correo, contrasena);

  Future<void> cerrarSesion() async {
    await _prefs.remove(claveTokenCuenta);
    await _prefs.remove(claveDatosCuenta);
  }

  Future<List<Cuenta>> listarUsuarios() async {
    final datos = await _admin<List<dynamic>>('GET', '/admin/usuarios');
    return datos.map((e) => Cuenta.desdeJson(_mapa(e))).toList(growable: false);
  }

  Future<ResumenAdmin> resumen() async => ResumenAdmin.desdeJson(
    _mapa(await _admin<Object?>('GET', '/admin/resumen')),
  );

  Future<List<ExamenAnalizado>> examenes() async {
    final datos = await _admin<List<dynamic>>('GET', '/admin/examenes');
    return datos
        .map((e) => ExamenAnalizado.desdeJson(_mapa(e)))
        .toList(growable: false);
  }

  /// Pide al servidor que busque exámenes nuevos en el portal; devuelve cuántos bajó.
  Future<int> recolectarExamenes() async {
    final datos = await _admin<Object?>('POST', '/admin/examenes/recolectar');
    return (_mapa(datos)['descargados']! as List<dynamic>).length;
  }

  /// Extrae y lista las preguntas de un PDF descargado para previsualizarlas.
  Future<List<PreguntaExtraidaAdmin>> preguntasDeExamen(String archivo) async {
    final datos = await _admin<List<dynamic>>(
      'GET',
      '/admin/examenes/$archivo/preguntas',
    );
    return datos
        .map((e) => PreguntaExtraidaAdmin.desdeJson(_mapa(e)))
        .toList(growable: false);
  }

  /// Publica las preguntas seleccionadas de un PDF como nueva versión del banco.
  Future<ResultadoPublicacionExamen> publicarPreguntasDeExamen(
    String archivo,
    List<Map<String, Object?>> preguntas,
  ) async {
    final datos = await _admin<Object?>(
      'POST',
      '/admin/examenes/$archivo/publicar',
      data: <String, Object?>{'preguntas': preguntas},
    );
    return ResultadoPublicacionExamen.desdeJson(_mapa(datos));
  }

  /// Descarga el contenido JSON completo de una versión del banco publicada.
  Future<Map<String, Object?>> descargarBanco(int version) async {
    final datos = await _llamar<Object?>(
      () => _cliente.get<Object?>('/preguntas/banco/descargar/$version'),
    );
    return _mapa(datos);
  }

  /// Recalibra el modelo con las respuestas reales; devuelve la versión publicada.
  Future<int> recalibrar() async =>
      _mapa(
            await _admin<Object?>('POST', '/admin/conocimiento/recalibrar'),
          )['version']!
          as int;

  Map<String, Object?> _mapa(Object? valor) =>
      (valor! as Map<String, dynamic>).cast<String, Object?>();

  Future<T> _admin<T>(String metodo, String ruta, {Object? data}) async {
    final token = _prefs.getString(claveTokenCuenta);
    if (token == null) {
      throw const ErrorCuentas('Inicia sesión para continuar.');
    }
    return _llamar<T>(
      () => _cliente.request<T>(
        ruta,
        data: data,
        options: Options(
          method: metodo,
          headers: <String, String>{'Authorization': 'Bearer $token'},
          // Analizar PDF o recolectar del portal puede tardar más que una consulta.
          receiveTimeout: const Duration(seconds: 120),
        ),
      ),
    );
  }

  Future<Cuenta> _autenticar(
    String ruta,
    String correo,
    String contrasena,
  ) async {
    final datos = await _llamar<Map<String, dynamic>>(
      () => _cliente.post<Map<String, dynamic>>(
        ruta,
        data: <String, String>{
          'correo': correo.trim(),
          'contrasena': contrasena,
        },
      ),
    );
    final cuenta = Cuenta.desdeJson(
      (datos['cuenta'] as Map<String, dynamic>).cast<String, Object?>(),
    );
    await _prefs.setString(claveTokenCuenta, datos['token'] as String);
    await _prefs.setString(claveDatosCuenta, jsonEncode(cuenta.aJson()));
    return cuenta;
  }

  Future<T> _llamar<T>(Future<Response<T>> Function() peticion) async {
    try {
      final respuesta = await peticion();
      final datos = respuesta.data;
      if (datos == null) {
        throw const ErrorCuentas('Respuesta vacía del servidor.');
      }
      return datos;
    } on DioException catch (error) {
      throw ErrorCuentas(_mensaje(error));
    }
  }

  String _mensaje(DioException error) {
    final respuesta = error.response;
    if (respuesta == null) {
      return 'No hay conexión con el servidor.';
    }
    final datos = respuesta.data;
    final detalle = datos is Map<String, dynamic> ? datos['detail'] : null;
    if (respuesta.statusCode == 422 || detalle is! String) {
      return 'Revisa los datos: correo válido y contraseña de 8 caracteres o más.';
    }
    return detalle;
  }
}
