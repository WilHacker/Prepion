import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/data/practica_repositorio.dart';
import 'package:prepion/features/practica/domain/calificacion.dart';
import 'package:prepion/features/practica/domain/tarjeta_repaso.dart';
import 'package:prepion/features/practica/presentation/pages/practica_page.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/shared/database/app_database.dart';

Pregunta _pregunta(int n) => Pregunta(
  id: 'p$n',
  examenId: 'e1',
  codigo: 'S1-Q$n',
  temaId: null,
  enunciado: 'Enunciado $n',
  opciones: const ['uno', 'dos', 'tres'],
  respuesta: 'B',
  explicacion: 'Explicación $n',
  rutaImagen: null,
  fuente: 'Fuente $n',
);

/// Repositorio en memoria: la prueba cubre la interfaz, no la base de datos.
class _RepositorioFalso extends PracticaRepositorio {
  _RepositorioFalso(this.preguntas, {this.falla = false})
    : super(AppDatabase(NativeDatabase.memory()));

  final List<Pregunta> preguntas;
  final bool falla;
  final guardadas = <String>[];

  @override
  Future<List<TarjetaRepaso>> tarjetas() async => const [];

  @override
  Future<List<String>> idsDePreguntasNuevas() async => [
    for (final p in preguntas) p.id,
  ];

  @override
  Future<List<Pregunta>> preguntasPorId(List<String> ids) async => [
    for (final id in ids) preguntas.firstWhere((p) => p.id == id),
  ];

  @override
  Future<TarjetaRepaso?> tarjetaDe(String preguntaId) async => null;

  @override
  Future<void> registrarRespuesta({
    required String idEvento,
    required String preguntaId,
    required String? opcionElegida,
    required RespuestaDelPostulante respuesta,
    required int tiempoMs,
    required DateTime respondidaEn,
    required TarjetaRepaso tarjeta,
  }) async {
    if (falla) throw Exception('disco lleno');
    guardadas.add('$preguntaId:${opcionElegida ?? 'nose'}:${respuesta.name}');
  }

  @override
  Future<List<DateTime>> fechasDeRespuestas() async => [DateTime.now()];
}

Widget _pagina(_RepositorioFalso repositorio) => ProviderScope(
  overrides: [
    practicaRepositorioProvider.overrideWithValue(repositorio),
    metaDiariaProvider.overrideWithValue(10),
  ],
  child: const MaterialApp(home: PracticaPage()),
);

Future<void> _abrir(WidgetTester tester, _RepositorioFalso repositorio) async {
  await tester.pumpWidget(_pagina(repositorio));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'avisa que no hay nada para practicar cuando el banco está vacío',
    (tester) async {
      // Actuar
      await _abrir(tester, _RepositorioFalso(const []));

      // Verificar
      expect(
        find.text('¡Hoy no tienes más preguntas para practicar!'),
        findsOneWidget,
      );
    },
  );

  testWidgets('muestra la primera pregunta con su progreso', (tester) async {
    // Actuar
    await _abrir(tester, _RepositorioFalso([_pregunta(1), _pregunta(2)]));

    // Verificar
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Enunciado 1'), findsOneWidget);
    expect(find.text('B) dos'), findsOneWidget);
    expect(find.text('Explicación 1'), findsNothing);
  });

  testWidgets('muestra la explicación apenas se responde', (tester) async {
    // Preparar
    await _abrir(tester, _RepositorioFalso([_pregunta(1), _pregunta(2)]));

    // Actuar
    await tester.tap(find.text('B) dos'));
    await tester.pumpAndSettle();

    // Verificar
    expect(find.text('¡Correcto!'), findsOneWidget);
    expect(find.text('Explicación 1'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
  });

  testWidgets('recorre la sesión completa y termina en el resumen', (
    tester,
  ) async {
    // Preparar
    final repositorio = _RepositorioFalso([_pregunta(1), _pregunta(2)]);
    await _abrir(tester, repositorio);

    // Actuar: acierta la primera, "No sé" en la segunda.
    await tester.tap(find.text('B) dos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('2/2'), findsOneWidget);
    await tester.tap(find.text('No sé'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver resumen'));
    await tester.pumpAndSettle();

    // Verificar
    expect(find.text('Sesión terminada'), findsOneWidget);
    expect(find.text('1 de 2'), findsOneWidget);
    expect(repositorio.guardadas, ['p1:B:correcta', 'p2:nose:noSe']);
  });

  testWidgets('guarda "Fue fácil" como una calificación más alta', (
    tester,
  ) async {
    // Preparar
    final repositorio = _RepositorioFalso([_pregunta(1)]);
    await _abrir(tester, repositorio);

    // Actuar
    await tester.tap(find.text('B) dos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fue fácil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver resumen'));
    await tester.pumpAndSettle();

    // Verificar
    expect(repositorio.guardadas, ['p1:B:correctaFacil']);
  });

  testWidgets(
    'pide confirmación antes de salir y conserva la sesión si se sigue',
    (tester) async {
      // Preparar
      await _abrir(tester, _RepositorioFalso([_pregunta(1)]));

      // Actuar
      await tester.tap(find.byTooltip('Salir de la práctica'));
      await tester.pumpAndSettle();
      expect(find.text('¿Salir de la práctica?'), findsOneWidget);
      await tester.tap(find.text('Seguir'));
      await tester.pumpAndSettle();

      // Verificar
      expect(find.text('¿Salir de la práctica?'), findsNothing);
      expect(find.text('Enunciado 1'), findsOneWidget);
    },
  );

  testWidgets('avisa con un mensaje cuando no se puede guardar la respuesta', (
    tester,
  ) async {
    // Preparar
    await _abrir(tester, _RepositorioFalso([_pregunta(1)], falla: true));
    await tester.tap(find.text('B) dos'));
    await tester.pumpAndSettle();

    // Actuar
    await tester.tap(find.text('Ver resumen'));
    await tester.pumpAndSettle();

    // Verificar: se queda en la pregunta para reintentar.
    expect(
      find.text('No se pudo guardar tu respuesta. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.text('Explicación 1'), findsOneWidget);
  });
}
