import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/app/prepion_app.dart';
import 'package:prepion/features/practica/data/banco_local_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final contenedor = ProviderContainer();
  // Carga el banco inicial antes de la primera pantalla (< 500 ms, sin red).
  await contenedor.read(bancoLocalServiceProvider).importarSemillaSiHaceFalta();
  runApp(
    UncontrolledProviderScope(container: contenedor, child: const PrepionApp()),
  );
}
