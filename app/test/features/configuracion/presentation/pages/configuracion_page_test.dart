import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/prepion_app.dart';
import 'package:prepion/app/router.dart';
import 'package:prepion/features/configuracion/data/repositorio_preferencias_local.dart';
import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'permite actualizar la meta diaria desde Ajustes conservando el UUID',
    (tester) async {
      // Preparar
      const idExistente = '99999999-aaaa-4bbb-8ccc-dddddddddddd';
      SharedPreferences.setMockInitialValues(<String, Object>{
        ClavesPreferencias.idUsuarioLocal: idExistente,
        ClavesPreferencias.fechaExamen: DateTime(2027, 1, 25).toIso8601String(),
        ClavesPreferencias.metaDiaria: 10,
        ClavesPreferencias.horaEstudio: 19,
        ClavesPreferencias.minutoEstudio: 0,
        ClavesPreferencias.onboardingCompletado: true,
      });

      final testRouter = crearRouter(initialLocation: '/inicio');
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

      // Actuar: abrir ajustes, cambiar meta a 5 y guardar
      await tester.tap(find.byKey(const Key('boton_ir_ajustes')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('chip_meta_5')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('boton_guardar_ajustes')));
      await tester.pumpAndSettle();

      // Verificar
      expect(find.text('Meta de hoy: 5 preguntas'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ClavesPreferencias.idUsuarioLocal), idExistente);
      expect(prefs.getInt(ClavesPreferencias.metaDiaria), 5);
    },
  );
}
