import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/configuracion/presentation/pages/configuracion_page.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:prepion/features/inicio/presentation/pages/acceso_cuenta_page.dart';
import 'package:prepion/features/inicio/presentation/pages/inicio_page.dart';
import 'package:prepion/features/inicio/presentation/pages/onboarding_page.dart';
import 'package:prepion/features/practica/presentation/pages/practica_page.dart';
import 'package:prepion/features/practica/presentation/pages/vista_previa_banco_page.dart';
import 'package:prepion/features/progreso/presentation/pages/progreso_page.dart';

class PuertaEntradaPage extends ConsumerWidget {
  const PuertaEntradaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferenciasAsync = ref.watch(preferenciasEstudioProvider);
    return preferenciasAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const OnboardingPage(),
      data: (preferencias) {
        if (preferencias != null && preferencias.onboardingCompletado) {
          return const InicioPage();
        }
        return const OnboardingPage();
      },
    );
  }
}

GoRouter crearRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const PuertaEntradaPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/inicio', builder: (context, state) => const InicioPage()),
      GoRoute(
        path: '/ajustes',
        builder: (context, state) => const ConfiguracionPage(),
      ),
      GoRoute(
        path: '/iniciar-sesion',
        builder: (context, state) => const AccesoCuentaPage(),
      ),
      GoRoute(
        path: '/practica',
        builder: (context, state) => const PracticaPage(),
      ),
      GoRoute(
        path: '/banco',
        builder: (context, state) => const VistaPreviaBancoPage(),
      ),
      GoRoute(
        path: '/progreso',
        builder: (context, state) => const ProgresoPage(),
      ),
    ],
  );
}

final GoRouter router = crearRouter();
