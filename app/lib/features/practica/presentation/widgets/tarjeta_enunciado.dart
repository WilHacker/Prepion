import 'package:material_ui/material_ui.dart';

/// Enunciado de una pregunta: texto o, si tiene fórmulas o figuras, su recorte
/// en imagen con zoom de pellizco. Siempre cita la fuente oficial.
///
/// La imagen ya incluye el enunciado y las opciones, y el texto de esas
/// preguntas sale roto del PDF; por eso, con imagen, no se muestra el texto.
class TarjetaEnunciado extends StatelessWidget {
  const TarjetaEnunciado({
    required this.enunciado,
    required this.fuente,
    this.imagen,
    super.key,
  });

  final String enunciado;
  final String fuente;

  /// Recorte de la pregunta; por ejemplo `AssetImage(pregunta.rutaImagen)`.
  final ImageProvider<Object>? imagen;

  static const _zoomMaximo = 4.0;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _contenido(tema),
            const SizedBox(height: 12),
            Text(
              fuente,
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contenido(ThemeData tema) {
    final recorte = imagen;
    if (recorte == null) return _texto(tema);
    return InteractiveViewer(
      maxScale: _zoomMaximo,
      child: Image(
        image: recorte,
        fit: BoxFit.fitWidth,
        width: double.infinity,
        semanticLabel: 'Pregunta con fórmula o figura. Pellizca para ampliar.',
        errorBuilder: (context, error, stackTrace) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No se pudo cargar la imagen de la pregunta.',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            _texto(tema),
          ],
        ),
      ),
    );
  }

  Widget _texto(ThemeData tema) =>
      Text(enunciado, style: tema.textTheme.bodyLarge);
}
