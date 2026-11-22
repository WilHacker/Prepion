import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/practica/presentation/widgets/tarjeta_enunciado.dart';

const _enunciado = 'Hallar el coeficiente del agente reductor.';
const _fuente = 'Examen de ingreso FCyT · 1.ª opción · 2-2026 · Q16 (serie 1)';

/// PNG de 1x1 píxel, suficiente para no depender de assets reales.
final _png = Uint8List.fromList(const [
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0d, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0xf8, 0xff, 0xff, 0x3f,
  0x00, 0x05, 0xfe, 0x02, 0xfe, 0xa7, 0x35, 0x81, 0x84, 0x00, 0x00, 0x00,
  0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
]);

/// Proveedor de imagen que siempre falla, para probar el texto de respaldo.
class _ImagenQueFalla extends ImageProvider<_ImagenQueFalla> {
  @override
  Future<_ImagenQueFalla> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _ImagenQueFalla key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    Future<ImageInfo>.error(Exception('no se pudo cargar')),
  );
}

Widget _envolver(Widget hijo) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: hijo)),
);

void main() {
  testWidgets('muestra el enunciado y la fuente cuando no hay imagen', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      _envolver(const TarjetaEnunciado(enunciado: _enunciado, fuente: _fuente)),
    );

    // Verificar
    expect(find.text(_enunciado), findsOneWidget);
    expect(find.text(_fuente), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsNothing);
  });

  testWidgets('muestra la imagen con zoom y no el texto cuando hay imagen', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      _envolver(
        TarjetaEnunciado(
          enunciado: _enunciado,
          fuente: _fuente,
          imagen: MemoryImage(_png),
        ),
      ),
    );

    // Verificar: el recorte ya incluye enunciado y opciones.
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text(_enunciado), findsNothing);
    expect(find.text(_fuente), findsOneWidget);
  });

  testWidgets('describe la imagen para lectores de pantalla', (tester) async {
    // Actuar
    await tester.pumpWidget(
      _envolver(
        TarjetaEnunciado(
          enunciado: _enunciado,
          fuente: _fuente,
          imagen: MemoryImage(_png),
        ),
      ),
    );

    // Verificar
    final imagen = tester.widget<Image>(find.byType(Image));
    expect(imagen.semanticLabel, contains('fórmula o figura'));
  });

  testWidgets('vuelve al texto y avisa cuando la imagen no carga', (
    tester,
  ) async {
    // Actuar
    await tester.pumpWidget(
      _envolver(
        TarjetaEnunciado(
          enunciado: _enunciado,
          fuente: _fuente,
          imagen: _ImagenQueFalla(),
        ),
      ),
    );
    await tester.pump();

    // Verificar
    expect(find.text(_enunciado), findsOneWidget);
    expect(
      find.text('No se pudo cargar la imagen de la pregunta.'),
      findsOneWidget,
    );
    expect(find.text(_fuente), findsOneWidget);
  });
}
