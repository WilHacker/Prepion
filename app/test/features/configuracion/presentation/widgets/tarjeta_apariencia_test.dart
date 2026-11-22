import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/modo_tema_provider.dart';
import 'package:prepion/features/configuracion/presentation/widgets/tarjeta_apariencia.dart';

void main() {
  testWidgets('cambia el modo del tema al elegir claro u oscuro', (
    tester,
  ) async {
    // Preparar
    final contenedor = ProviderContainer();
    addTearDown(contenedor.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: contenedor,
        child: const MaterialApp(home: Scaffold(body: TarjetaApariencia())),
      ),
    );
    expect(contenedor.read(modoTemaProvider), ThemeMode.dark);

    // Actuar
    await tester.tap(find.byKey(const Key('opcion_modo_claro')));
    await tester.pump();

    // Verificar
    expect(contenedor.read(modoTemaProvider), ThemeMode.light);
    expect(find.text('Apariencia'), findsOneWidget);

    await tester.tap(find.byKey(const Key('opcion_modo_oscuro')));
    await tester.pump();
    expect(contenedor.read(modoTemaProvider), ThemeMode.dark);
  });
}
