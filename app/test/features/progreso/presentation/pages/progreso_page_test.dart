import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/progreso/domain/resumen_progreso.dart';
import 'package:prepion/features/progreso/presentation/pages/progreso_page.dart';
import 'package:prepion/features/progreso/presentation/providers/progreso_provider.dart';

ResumenProgreso _resumen({
  int racha = 3,
  int totalRespuestas = 20,
  int? dias = 10,
  List<DominioTema> temas = const [
    DominioTema(
      temaId: 't1',
      materia: 'Física',
      nombre: 'Cinemática',
      dominio: 0.45,
      respuestas: 5,
    ),
  ],
}) => ResumenProgreso(
  materias: const [
    DominioMateria(materia: 'Aritmética-Álgebra', dominio: 0.7, respuestas: 10),
    DominioMateria(materia: 'Geometría-Trigonometría', respuestas: 0),
    DominioMateria(materia: 'Física', dominio: 0.3, respuestas: 4),
    DominioMateria(materia: 'Química', dominio: 0.5, respuestas: 4),
    DominioMateria(materia: 'Biología', dominio: 0.9, respuestas: 4),
  ],
  temasAReforzar: temas,
  nivel: NivelPreparacion.medio,
  racha: racha,
  totalRespuestas: totalRespuestas,
  diasParaElExamen: dias,
);

Future<void> _montar(
  WidgetTester tester,
  Future<ResumenProgreso> Function() cargar, {
  Widget home = const ProgresoPage(),
  String? etiqueta,
}) async {
  // Pantalla alta para que el ListView construya todas las secciones.
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        progresoProvider.overrideWith((ref) => cargar()),
        etiquetaModeloConocimientoProvider.overrideWithValue(etiqueta),
      ],
      child: MaterialApp(home: home),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('muestra un indicador mientras calcula el progreso', (
    tester,
  ) async {
    // Preparar y actuar
    final completer = Completer<ResumenProgreso>();
    await _montar(tester, () => completer.future);

    // Verificar
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('avisa del error cuando falla el cálculo', (tester) async {
    // Preparar y actuar
    await _montar(tester, () async => throw StateError('falla'));
    await tester.pump();

    // Verificar
    expect(find.text('No se pudo calcular tu progreso.'), findsOneWidget);
  });

  testWidgets('invita a practicar cuando no hay respuestas', (tester) async {
    // Preparar y actuar
    await _montar(tester, () async => _resumen(totalRespuestas: 0));

    // Verificar
    expect(
      find.text(
        'Todavía no tienes respuestas. ¡Practica un poco para ver tu progreso!',
      ),
      findsOneWidget,
    );
    expect(find.text('Practicar hoy'), findsOneWidget);
  });

  testWidgets('navega a /practica cuando se toca Practicar hoy', (
    tester,
  ) async {
    // Preparar
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const ProgresoPage()),
        GoRoute(
          path: '/practica',
          builder: (_, _) => const Scaffold(body: Text('pantalla práctica')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progresoProvider.overrideWith(
            (ref) async => _resumen(totalRespuestas: 0),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Actuar
    await tester.tap(find.text('Practicar hoy'));
    await tester.pumpAndSettle();

    // Verificar
    expect(find.text('pantalla práctica'), findsOneWidget);
  });

  testWidgets('muestra nivel, racha, examen, gráfico y temas con datos', (
    tester,
  ) async {
    // Preparar y actuar
    await _montar(tester, () async => _resumen());

    // Verificar
    expect(find.text('Nivel estimado: Medio'), findsOneWidget);
    expect(
      find.text('Estimación basada en tu práctica; no garantiza la admisión.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    expect(find.text('3 días'), findsOneWidget);
    expect(find.text('Faltan 10 días para tu examen'), findsOneWidget);
    expect(find.text('Dominio por materia'), findsOneWidget);
    expect(find.text('Temas que debes reforzar'), findsOneWidget);
    expect(find.text('Cinemática'), findsOneWidget);
  });

  testWidgets('usa singular cuando la racha y el examen son de un día', (
    tester,
  ) async {
    // Preparar y actuar
    await _montar(tester, () async => _resumen(racha: 1, dias: 1));

    // Verificar
    expect(find.text('1 día'), findsOneWidget);
    expect(find.text('Falta 1 día para tu examen'), findsOneWidget);
  });

  testWidgets('oculta los días del examen cuando no hay fecha', (tester) async {
    // Preparar y actuar
    await _montar(tester, () async => _resumen(dias: null, temas: const []));

    // Verificar
    expect(find.textContaining('para tu examen'), findsNothing);
    expect(find.text('Aún no hay temas para reforzar.'), findsOneWidget);
  });

  testWidgets('muestra la etiqueta del modelo de conocimiento al final', (
    tester,
  ) async {
    // Preparar y actuar
    await _montar(
      tester,
      () async => _resumen(),
      etiqueta: 'Modelo de conocimiento v1 · datos simulados',
    );
    await tester.pump();

    // Verificar
    expect(
      find.text('Modelo de conocimiento v1 · datos simulados'),
      findsOneWidget,
    );
  });

  testWidgets('no muestra etiqueta cuando no hay modelo', (tester) async {
    // Preparar y actuar
    await _montar(tester, () async => _resumen());
    await tester.pump();

    // Verificar
    expect(find.textContaining('Modelo de conocimiento'), findsNothing);
  });
}
