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
    final token = _prefs.getString(claveTokenCuenta);
    if (token == null) {
      throw const ErrorCuentas('Inicia sesión para continuar.');
    }
    final datos = await _llamar<List<dynamic>>(
      () => _cliente.get<List<dynamic>>(
        '/admin/usuarios',
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $token'},
        ),
      ),
    );
    return datos
        .map(
          (e) => Cuenta.desdeJson(
            (e as Map<String, dynamic>).cast<String, Object?>(),
          ),
        )
        .toList(growable: false);
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
