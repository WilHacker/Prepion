import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/app/prepion_app.dart';

void main() {
  testWidgets('abre la página de inicio cuando arranca la app', (tester) async {
    // Preparar y actuar
    await tester.pumpWidget(const ProviderScope(child: PrepionApp()));
    await tester.pumpAndSettle();

    // Verificar
    expect(find.text('Prepion'), findsOneWidget);
  });
}
