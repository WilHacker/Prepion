import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/theme.dart';
import 'package:prepion/features/practica/domain/calificacion.dart';

/// Lo que se muestra tras responder: resultado, clave, explicación y "Siguiente".
///
/// Si acertó, puede afinar con "Me costó" o "Fue fácil" (alimenta el repaso).
class HojaExplicacion extends StatelessWidget {
  const HojaExplicacion({
    required this.respuesta,
    required this.respuestaCorrecta,
    required this.explicacion,
    required this.onSiguiente,
    required this.onDificultad,
    this.esUltima = false,
    this.mostrarCalificacion = true,
    this.onReportarError,
    super.key,
  });

  final RespuestaDelPostulante respuesta;
  final String respuestaCorrecta;
  final String explicacion;
  final VoidCallback onSiguiente;
  final ValueChanged<RespuestaDelPostulante> onDificultad;
  final bool esUltima;
  final bool mostrarCalificacion;
  final VoidCallback? onReportarError;

  @override
  Widget build(BuildContext context) {
    final tipografia = Theme.of(context).textTheme;
    final acerto = respuesta.esCorrecta;
    final (fondo, acento, icono) = switch (respuesta) {
      RespuestaDelPostulante.noSe => (
        context.tokens.superficieHover,
        context.tokens.dorado,
        Icons.lightbulb_rounded,
      ),
      RespuestaDelPostulante.incorrecta => (
        ColoresPrepion.tinteIncorrecto,
        context.tokens.naranja,
        Icons.cancel_rounded,
      ),
      _ => (
        ColoresPrepion.tinteCorrecto,
        context.tokens.azul,
        Icons.check_circle_rounded,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: acento.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: acento),
              const SizedBox(width: 10),
              Expanded(child: Text(_titulo, style: tipografia.titleLarge)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Respuesta correcta: $respuestaCorrecta',
            style: tipografia.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(explicacion, style: tipografia.bodyLarge),
          if (acerto && mostrarCalificacion) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _opcion('Me costó', RespuestaDelPostulante.correctaMeCosto),
                _opcion('Fue fácil', RespuestaDelPostulante.correctaFacil),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(
                onPressed: onSiguiente,
                child: Text(esUltima ? 'Ver resumen' : 'Siguiente'),
              ),
              const Spacer(),
              if (onReportarError != null)
                TextButton.icon(
                  onPressed: onReportarError,
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('Reportar error'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String get _titulo => switch (respuesta) {
    RespuestaDelPostulante.noSe => 'No pasa nada, así se aprende',
    RespuestaDelPostulante.incorrecta => 'Incorrecto',
    _ => '¡Correcto!',
  };

  Widget _opcion(String texto, RespuestaDelPostulante valor) => FilterChip(
    label: Text(texto),
    selected: respuesta == valor,
    onSelected: (_) => onDificultad(valor),
  );
}
