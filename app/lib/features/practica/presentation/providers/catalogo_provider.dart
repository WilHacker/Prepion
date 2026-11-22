import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prepion/features/practica/data/practica_libre_repositorio.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';

final catalogoMateriasProvider = StreamProvider<List<ResumenMateria>>((ref) {
  final repo = ref.watch(practicaLibreRepositorioProvider);
  return repo.watchMaterias();
});
