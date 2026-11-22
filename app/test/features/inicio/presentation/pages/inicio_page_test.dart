import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/prepion_app.dart';
import 'package:prepion/app/router.dart';
import 'package:prepion/features/inicio/presentation/pages/inicio_page.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';
import 'package:prepion/features/practica/presentation/providers/catalogo_provider.dart';
import 'package:prepion/features/practica/presentation/providers/preguntas_banco_provider.dart';
import 'package:prepion/features/progreso/domain/resumen_progreso.dart';
import 'package:prepion/features/progreso/presentation/providers/progreso_provider.dart';
import 'package:prepion/shared/database/app_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('muestra el nombre de la app cuando se abre el inicio', (
    tester,
  ) async {
    // Preparar
    SharedPreferences.setMockInitialValues(<String, Object>{});

    // Actuar
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: InicioPage())),
    );
    await tester.pumpAndSettle();

    // Verificar
    expect(find.text('Prepion'), findsOneWidget);
    expect(find.text('Practicar hoy'), findsOneWidget);
    expect(find.text('Ver banco de preguntas'), findsOneWidget);
    expect(find.text('Mi progreso'), findsOneWidget);
  });

  testWidgets('abre la vista previa del banco cuando se toca el botón', (
    tester,
  ) async {
    // Preparar
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final testRouter = crearRouter(initialLocation: '/inicio');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preguntasDelBancoProvider.overrideWith(
            (ref) => Stream.value(const <Pregunta>[]),
          ),
        ],
        child: MaterialApp.router(routerConfig: testRouter),
      ),
    );
    await tester.pumpAndSettle();

    // Actuar
    await tester.tap(find.text('Ver banco de preguntas'));
    await tester.pumpAndSettle();

    // Verificar
    expect(find.text('Banco de preguntas'), findsOneWidget);
    expect(
      find.text('Todavía no hay preguntas en el banco local.'),
      findsOneWidget,
    );
  });

  testWidgets('abre el panel de progreso cuando se toca el botón', (
    tester,
  ) async {
    // Preparar
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final testRouter = crearRouter(initialLocation: '/inicio');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progresoProvider.overrideWith(
            (ref) async => const ResumenProgreso(
              materias: [],
              temasAReforzar: [],
              nivel: NivelPreparacion.sinDatos,
              racha: 0,
              totalRespuestas: 0,
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: testRouter),
      ),
    );
    await tester.pumpAndSettle();

    // Actuar
    await tester.tap(find.text('Mi progreso'));
    await tester.pumpAndSettle();

    // Verificar
    expect(
      find.text(
        'Todavía no tienes respuestas. ¡Practica un poco para ver tu progreso!',
      ),
      findsOneWidget,
    );
  });

  testWidgets('abre el catálogo de materias cuando se toca Práctica libre', (
    tester,
  ) async {
    // Preparar
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final testRouter = crearRouter(initialLocation: '/inicio');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogoMateriasProvider.overrideWith(
            (ref) => Stream.value(const <ResumenMateria>[]),
          ),
        ],
        child: MaterialApp.router(routerConfig: testRouter),
      ),
    );
    await tester.pumpAndSettle();

    // Actuar
    await tester.tap(find.text('Práctica libre por materia'));
    await tester.pumpAndSettle();

    // Verificar
    expect(find.text('Materias'), findsOneWidget);
  });

  testWidgets(
    'alterna entre el tema oscuro y el claro con el botón del inicio',
    (tester) async {
      // Preparar
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(
        ProviderScope(
          child: PrepionApp(
            routerConfig: crearRouter(initialLocation: '/inicio'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      Brightness brilloActual() =>
          Theme.of(tester.element(find.text('Practicar hoy'))).brightness;
      expect(brilloActual(), Brightness.dark);

      // Actuar
      await tester.tap(find.byKey(const Key('boton_cambiar_tema')));
      await tester.pumpAndSettle();

      // Verificar
      expect(brilloActual(), Brightness.light);
      final boton = tester.getSize(find.byKey(const Key('boton_cambiar_tema')));
      expect(boton.width, greaterThanOrEqualTo(48));
      expect(boton.height, greaterThanOrEqualTo(48));
      expect(find.byTooltip('Cambiar tema'), findsOneWidget);

      await tester.tap(find.byKey(const Key('boton_cambiar_tema')));
      await tester.pumpAndSettle();
      expect(brilloActual(), Brightness.dark);
    },
  );
}
