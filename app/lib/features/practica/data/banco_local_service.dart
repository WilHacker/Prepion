import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/features/practica/domain/banco_invalido_error.dart';
import 'package:prepion/shared/database/app_database.dart';

/// Ruta del banco inicial que viaja dentro de la app.
const rutaSemillaBanco = 'assets/datos/banco_semilla.json';

/// Lee el texto de la semilla; se inyecta para poder probar sin assets.
typedef CargadorDeSemilla = Future<String> Function();

Future<String> cargarSemillaDeAssets() =>
    rootBundle.loadString(rutaSemillaBanco);

/// Importa el banco inicial a la base local para practicar sin conexión.
class BancoLocalService {
  const BancoLocalService(this._baseDeDatos, this._cargarSemilla);

  final AppDatabase _baseDeDatos;
  final CargadorDeSemilla _cargarSemilla;

  /// Importa la semilla solo si aún no hay preguntas guardadas.
  ///
  /// Si ya hay preguntas no se toca nada: un banco más nuevo (descargado por
  /// sincronización) no debe ser pisado por la semilla del APK.
  /// Devuelve `true` si importó algo.
  Future<bool> importarSemillaSiHaceFalta() async {
    final cantidad = await _baseDeDatos.preguntas.count().getSingle();
    if (cantidad > 0) return false;

    final banco = _decodificar(await _cargarSemilla());
    final examenes = _lista(banco, 'examenes');
    final temas = _lista(banco, 'temas');
    final preguntas = _lista(banco, 'preguntas');
    if (preguntas.isEmpty) return false;

    final examenesFilas = examenes.map(_examenDe).toList();
    final temasFilas = temas.map(_temaDe).toList();
    final preguntasFilas = preguntas.map(_preguntaDe).toList();

    try {
      await _baseDeDatos.transaction(() async {
        await _baseDeDatos.batch((lote) {
          lote.insertAll(_baseDeDatos.examenes, examenesFilas);
          lote.insertAll(_baseDeDatos.temas, temasFilas);
          lote.insertAll(_baseDeDatos.preguntas, preguntasFilas);
        });
      });
    } on SqliteException catch (error) {
      throw BancoInvalidoError('El banco tiene datos inconsistentes: $error');
    }
    return true;
  }

  /// Importa o actualiza un banco descargado de la API (HU-08).
  Future<bool> importarBanco(Map<String, Object?> banco) async {
    final examenes = _lista(banco, 'examenes');
    final temas = _lista(banco, 'temas');
    final preguntas = _lista(banco, 'preguntas');
    if (preguntas.isEmpty) return false;

    final examenesFilas = examenes.map(_examenDe).toList();
    final temasFilas = temas.map(_temaDe).toList();
    final preguntasFilas = preguntas.map(_preguntaDe).toList();

    try {
      await _baseDeDatos.transaction(() async {
        await _baseDeDatos.batch((lote) {
          lote.insertAllOnConflictUpdate(_baseDeDatos.examenes, examenesFilas);
          lote.insertAllOnConflictUpdate(_baseDeDatos.temas, temasFilas);
          lote.insertAllOnConflictUpdate(
            _baseDeDatos.preguntas,
            preguntasFilas,
          );
        });
      });
    } on SqliteException catch (error) {
      throw BancoInvalidoError('El banco tiene datos inconsistentes: $error');
    }
    return true;
  }

  Map<String, Object?> _decodificar(String texto) {
    try {
      final decodificado = jsonDecode(texto);
      if (decodificado is Map<String, Object?>) return decodificado;
    } on FormatException {
      throw const BancoInvalidoError('El banco no es un JSON válido.');
    }
    throw const BancoInvalidoError('El banco debe ser un objeto JSON.');
  }

  List<Map<String, Object?>> _lista(Map<String, Object?> banco, String clave) {
    final valor = banco[clave];
    if (valor is! List<Object?>) {
      throw BancoInvalidoError('Falta la lista "$clave" en el banco.');
    }
    return valor.map((elemento) {
      if (elemento is Map<String, Object?>) return elemento;
      throw BancoInvalidoError('Un elemento de "$clave" no es un objeto.');
    }).toList();
  }

  ExamenesCompanion _examenDe(Map<String, Object?> fila) =>
      ExamenesCompanion.insert(
        id: _texto(fila, 'id'),
        gestion: _texto(fila, 'gestion'),
        tipo: _texto(fila, 'tipo'),
        archivo: _texto(fila, 'archivo'),
      );

  TemasCompanion _temaDe(Map<String, Object?> fila) => TemasCompanion.insert(
    id: _texto(fila, 'id'),
    materia: _texto(fila, 'materia'),
    nombre: _texto(fila, 'nombre'),
  );

  PreguntasCompanion _preguntaDe(Map<String, Object?> fila) =>
      PreguntasCompanion.insert(
        id: _texto(fila, 'id'),
        examenId: _texto(fila, 'examenId'),
        codigo: _texto(fila, 'codigo'),
        temaId: Value(_textoOpcional(fila, 'temaId')),
        enunciado: _texto(fila, 'enunciado'),
        opciones: _opciones(fila),
        respuesta: _texto(fila, 'respuesta'),
        explicacion: _texto(fila, 'explicacion'),
        rutaImagen: Value(_textoOpcional(fila, 'rutaImagen')),
        fuente: _texto(fila, 'fuente'),
      );

  String _texto(Map<String, Object?> fila, String campo) {
    final valor = fila[campo];
    if (valor is String && valor.isNotEmpty) return valor;
    throw BancoInvalidoError('Falta el campo de texto "$campo".');
  }

  String? _textoOpcional(Map<String, Object?> fila, String campo) {
    final valor = fila[campo];
    if (valor == null) return null;
    if (valor is String) return valor;
    throw BancoInvalidoError('El campo "$campo" debe ser texto o nulo.');
  }

  List<String> _opciones(Map<String, Object?> fila) {
    final valor = fila['opciones'];
    if (valor is List<Object?> &&
        valor.length >= 2 &&
        valor.every((o) => o is String)) {
      return valor.cast<String>();
    }
    throw const BancoInvalidoError(
      'El campo "opciones" debe ser una lista de al menos 2 textos.',
    );
  }
}

final bancoLocalServiceProvider = Provider<BancoLocalService>(
  (ref) =>
      BancoLocalService(ref.watch(appDatabaseProvider), cargarSemillaDeAssets),
);
