import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/router.dart';
import 'package:prepion/features/inicio/presentation/pages/inicio_page.dart';
import 'package:prepion/features/practica/presentation/providers/preguntas_banco_provider.dart';
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
}
