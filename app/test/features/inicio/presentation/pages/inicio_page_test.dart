import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/inicio/presentation/pages/inicio_page.dart';

void main() {
  testWidgets('muestra el nombre de la app cuando se abre el inicio', (
    tester,
  ) async {
    // Preparar y actuar
    await tester.pumpWidget(const MaterialApp(home: InicioPage()));

    // Verificar
    expect(find.text('Prepion'), findsOneWidget);
  });
}
