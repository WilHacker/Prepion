import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/practica/data/practica_libre_repositorio.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';

final temasDeMateriaProvider = StreamProvider.family<List<ResumenTema>, String>(
  (ref, materia) {
    final repo = ref.watch(practicaLibreRepositorioProvider);
    return repo.watchTemasDeMateria(materia);
  },
);
