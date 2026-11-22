import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/conocimiento/domain/parametros_conocimiento.dart';
import 'package:prepion/shared/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

const claveCacheConocimiento = 'parametros_conocimiento';
const rutaAssetConocimiento = 'assets/datos/parametros_conocimiento.json';
const _rutaRemota = '/paquetes-conocimiento/actual';

/// Entrega el paquete de conocimiento: caché local > asset empaquetado > nada.
class RepositorioConocimiento {
  RepositorioConocimiento(
    this._prefs,
    this._cliente, {
    Future<String> Function()? cargarAsset,
  }) : _cargarAsset =
           cargarAsset ?? (() => rootBundle.loadString(rutaAssetConocimiento));

  final SharedPreferences _prefs;
  final Dio _cliente;
  final Future<String> Function() _cargarAsset;

  /// Mejor paquete válido disponible sin red; null si no hay ninguno.
  Future<ParametrosConocimiento?> cargar() async {
    final cache = _prefs.getString(claveCacheConocimiento);
    if (cache != null) {
      final desdeCache = _intentar(() => _decodificar(cache), 'caché');
      if (desdeCache != null) return desdeCache;
    }
    try {
      return _decodificar(await _cargarAsset());
    } on ParametrosConocimientoInvalidosError catch (e) {
      debugPrint('Paquete empaquetado inválido: ${e.mensaje}');
    } on FlutterError catch (e) {
      debugPrint('Paquete empaquetado ausente: ${e.message}');
    }
    return null;
  }

  /// Pide el paquete al servidor y lo guarda solo si su versión es mayor.
  /// Nunca lanza: ante cualquier fallo devuelve el paquete vigente.
  Future<ParametrosConocimiento?> sincronizar() async {
    final vigente = await cargar();
    try {
      final respuesta = await _cliente.get<Object?>(_rutaRemota);
      final datos = respuesta.data;
      final json = _desenvolver(datos is String ? _jsonODominio(datos) : datos);
      final remoto = ParametrosConocimiento.fromJson(json);
      if (vigente != null && remoto.version <= vigente.version) return vigente;
      await _prefs.setString(claveCacheConocimiento, jsonEncode(json));
      return remoto;
    } on DioException catch (e) {
      debugPrint('Sin paquete remoto de conocimiento: ${e.message}');
    } on ParametrosConocimientoInvalidosError catch (e) {
      debugPrint('Paquete remoto descartado: ${e.mensaje}');
    }
    return vigente;
  }

  /// El servidor responde `{version, contenido, actualizadoEn}` y el paquete va en
  /// `contenido`. También se acepta el paquete sin envolver (el del APK y las pruebas).
  Object? _desenvolver(Object? json) {
    if (json is Map<String, dynamic> && json['contenido'] is Map) {
      return json['contenido'];
    }
    return json;
  }

  ParametrosConocimiento? _intentar(
    ParametrosConocimiento Function() accion,
    String origen,
  ) {
    try {
      return accion();
    } on ParametrosConocimientoInvalidosError catch (e) {
      debugPrint('Paquete de $origen inválido, se ignora: ${e.mensaje}');
      return null;
    }
  }

  ParametrosConocimiento _decodificar(String texto) =>
      ParametrosConocimiento.fromJson(_jsonODominio(texto));

  Object? _jsonODominio(String texto) {
    try {
      return jsonDecode(texto);
    } on FormatException {
      throw const ParametrosConocimientoInvalidosError('El JSON está roto.');
    }
  }
}

final repositorioConocimientoProvider = FutureProvider<RepositorioConocimiento>(
  (ref) async => RepositorioConocimiento(
    await SharedPreferences.getInstance(),
    ref.watch(clienteApiProvider),
  ),
);
