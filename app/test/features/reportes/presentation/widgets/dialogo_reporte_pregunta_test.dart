import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/reportes/data/reportes_service.dart';
import 'package:prepion/features/reportes/presentation/widgets/dialogo_reporte_pregunta.dart';

class _ServicioReportesFalso implements ReportesService {
  String? ultimoPreguntaId;
  String? ultimoMotivo;
  String? ultimoComentario;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<bool> enviarReporte({
    required String preguntaId,
    required String motivo,
    String? comentario,
  }) async {
    ultimoPreguntaId = preguntaId;
    ultimoMotivo = motivo;
    ultimoComentario = comentario;
    return true;
  }
}

void main() {
  testWidgets('muestra opciones, permite seleccionar motivo y enviar reporte', (
    tester,
  ) async {
    // Arrange
    final servicioFalso = _ServicioReportesFalso();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [reportesServiceProvider.overrideWithValue(servicioFalso)],
        child: const MaterialApp(
          home: Scaffold(
            body: DialogoReportePregunta(preguntaId: 'preg-test-1'),
          ),
        ),
      ),
    );

    // Assert: elementos iniciales
    expect(find.text('Reportar problema'), findsOneWidget);
    expect(find.text('Respuesta incorrecta'), findsOneWidget);
    expect(find.text('Imagen o fórmula borrosa'), findsOneWidget);
    expect(find.text('Error tipográfico'), findsOneWidget);

    // Act: Seleccionar "Imagen o fórmula borrosa"
    await tester.tap(find.text('Imagen o fórmula borrosa'));
    await tester.pumpAndSettle();

    // Act: Escribir comentario
    await tester.enterText(
      find.byType(TextField),
      'No se distingue la fracción en el exponente',
    );
    await tester.pumpAndSettle();

    // Act: Enviar reporte
    await tester.tap(find.text('Enviar reporte'));
    await tester.pump();

    // Assert: Se llamó al servicio con los datos correctos
    expect(servicioFalso.ultimoPreguntaId, 'preg-test-1');
    expect(servicioFalso.ultimoMotivo, 'imagen_borrosa');
    expect(
      servicioFalso.ultimoComentario,
      'No se distingue la fracción en el exponente',
    );
  });
}
