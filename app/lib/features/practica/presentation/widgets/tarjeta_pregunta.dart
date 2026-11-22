import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/theme.dart';
import 'package:prepion/features/practica/presentation/widgets/tarjeta_enunciado.dart';
import 'package:prepion/shared/database/app_database.dart';

const letrasDeOpcion = ['A', 'B', 'C', 'D', 'E'];

/// Una pregunta lista para responder: enunciado, opciones A–E y "No sé".
///
/// Al responder ([muestraClave]) se bloquean los botones y se marca la opción
/// correcta en azul y, si falló, la elegida en naranja, cada una con su ícono.
class TarjetaPregunta extends StatelessWidget {
  const TarjetaPregunta({
    required this.pregunta,
    required this.onElegir,
    required this.onNoSe,
    this.letraElegida,
    this.muestraClave = false,
    super.key,
  });

  final Pregunta pregunta;
  final ValueChanged<String> onElegir;
  final VoidCallback onNoSe;
  final String? letraElegida;
  final bool muestraClave;

  @override
  Widget build(BuildContext context) {
    final rutaImagen = pregunta.rutaImagen;
    final cantidad = pregunta.opciones.length.clamp(0, letrasDeOpcion.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TarjetaEnunciado(
          enunciado: pregunta.enunciado,
          fuente: pregunta.fuente,
          imagen: rutaImagen == null ? null : AssetImage(rutaImagen),
        ),
        const SizedBox(height: 12),
        // El recorte ya muestra las opciones: aquí solo van las letras.
        if (rutaImagen == null)
          for (var i = 0; i < cantidad; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _boton(
                context,
                letrasDeOpcion[i],
                '${letrasDeOpcion[i]}) ${pregunta.opciones[i]}',
                alinearIzquierda: true,
              ),
            )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < cantidad; i++)
                SizedBox(
                  width: 64,
                  child: _boton(context, letrasDeOpcion[i], letrasDeOpcion[i]),
                ),
            ],
          ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: muestraClave ? null : onNoSe,
          child: const Text('No sé'),
        ),
      ],
    );
  }

  Widget _boton(
    BuildContext context,
    String letra,
    String texto, {
    bool alinearIzquierda = false,
  }) {
    final esCorrecta = muestraClave && letra == pregunta.respuesta;
    final esFallada = muestraClave && letra == letraElegida && !esCorrecta;
    final fondo = esCorrecta
        ? ColoresPrepion.tinteCorrecto
        : esFallada
        ? ColoresPrepion.tinteIncorrecto
        : null;
    final borde = esCorrecta
        ? context.tokens.azul
        : esFallada
        ? context.tokens.naranja
        : context.tokens.borde;
    // Además del color, un ícono indica cuál es la correcta y cuál falló.
    final tamanoIcono = alinearIzquierda ? 22.0 : 16.0;
    final icono = esCorrecta
        ? Icon(
            Icons.check_circle_rounded,
            size: tamanoIcono,
            color: context.tokens.azul,
            semanticLabel: 'Respuesta correcta',
          )
        : esFallada
        ? Icon(
            Icons.cancel_rounded,
            size: tamanoIcono,
            color: context.tokens.naranja,
            semanticLabel: 'Tu respuesta',
          )
        : null;
    final etiqueta = Text(
      texto,
      textAlign: alinearIzquierda ? TextAlign.start : TextAlign.center,
    );
    return OutlinedButton(
      onPressed: muestraClave ? null : () => onElegir(letra),
      style: OutlinedButton.styleFrom(
        backgroundColor: fondo ?? context.tokens.superficie,
        disabledBackgroundColor: fondo,
        foregroundColor: context.tokens.textoPrincipal,
        disabledForegroundColor: fondo == null
            ? context.tokens.textoSecundario
            : context.tokens.textoPrincipal,
        side: BorderSide(color: borde, width: fondo == null ? 1 : 1.5),
        minimumSize: const Size.fromHeight(52),
        padding: EdgeInsets.symmetric(
          horizontal: alinearIzquierda ? 16 : 6,
          vertical: 12,
        ),
        textStyle: Theme.of(context).textTheme.bodyMedium,
      ),
      child: alinearIzquierda
          ? Row(
              children: [
                Expanded(child: etiqueta),
                if (icono != null) ...[const SizedBox(width: 8), icono],
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                etiqueta,
                if (icono != null) ...[const SizedBox(width: 4), icono],
              ],
            ),
    );
  }
}
