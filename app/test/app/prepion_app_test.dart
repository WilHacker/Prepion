import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/app/prepion_app.dart';
import 'package:prepion/app/router.dart';
import 'package:prepion/features/configuracion/data/repositorio_preferencias_local.dart';
import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('abre el onboarding cuando es el primer arranque de la app', (
    tester,
  ) async {
    // Preparar
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final testRouter = crearRouter();

    // Actuar
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          parametrosPublicosProvider.overrideWith(
            (ref) async =>
                ParametrosPublicos.porDefecto(hoy: DateTime(2026, 11, 22)),
          ),
        ],
        child: PrepionApp(routerConfig: testRouter),
      ),
    );
    await tester.pumpAndSettle();

    // Verificar
    expect(find.text('Prepion'), findsOneWidget);
    expect(find.text('Empezar a practicar ahora'), findsOneWidget);
  });

  testWidgets(
    'abre la pantalla de inicio cuando el onboarding ya fue completado',
    (tester) async {
      // Preparar
      SharedPreferences.setMockInitialValues(<String, Object>{
        ClavesPreferencias.idUsuarioLocal:
            '11111111-2222-4333-8444-555555555555',
        ClavesPreferencias.fechaExamen: DateTime(2027, 1, 25).toIso8601String(),
        ClavesPreferencias.metaDiaria: 10,
        ClavesPreferencias.horaEstudio: 19,
        ClavesPreferencias.minutoEstudio: 0,
        ClavesPreferencias.onboardingCompletado: true,
      });
      final testRouter = crearRouter();

      // Actuar
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            parametrosPublicosProvider.overrideWith(
              (ref) async =>
                  ParametrosPublicos.porDefecto(hoy: DateTime(2026, 11, 22)),
            ),
          ],
          child: PrepionApp(routerConfig: testRouter),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar
      expect(find.text('Meta de hoy: 10 preguntas'), findsOneWidget);
    },
  );
}
