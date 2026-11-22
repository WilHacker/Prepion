import 'package:go_router/go_router.dart';

import 'package:prepion/features/inicio/presentation/pages/inicio_page.dart';
import 'package:prepion/features/practica/presentation/pages/vista_previa_banco_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const InicioPage()),
    GoRoute(
      path: '/banco',
      builder: (context, state) => const VistaPreviaBancoPage(),
    ),
  ],
);
