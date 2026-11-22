import 'package:go_router/go_router.dart';

import 'package:prepion/features/inicio/presentation/pages/inicio_page.dart';

final router = GoRouter(
  routes: [GoRoute(path: '/', builder: (context, state) => const InicioPage())],
);
