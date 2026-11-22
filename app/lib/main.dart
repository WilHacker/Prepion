import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prepion/app/prepion_app.dart';
import 'package:prepion/features/practica/data/banco_local_service.dart';
import 'package:prepion/features/sincronizacion/presentation/providers/sincronizacion_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final contenedor = ProviderContainer();
  // Carga el banco inicial antes de la primera pantalla (< 500 ms, sin red).
  await contenedor.read(bancoLocalServiceProvider).importarSemillaSiHaceFalta();
  // Inicia la escucha de conectividad y sincronización en segundo plano.
  contenedor.read(gestorSincronizacionAutoProvider);
  runApp(
    UncontrolledProviderScope(container: contenedor, child: const PrepionApp()),
  );
}
