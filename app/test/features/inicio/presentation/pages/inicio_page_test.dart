import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/inicio/presentation/pages/inicio_page.dart';
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
  });
}
