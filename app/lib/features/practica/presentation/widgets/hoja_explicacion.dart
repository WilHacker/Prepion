import 'package:material_ui/material_ui.dart';
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
    super.key,
  });

  final RespuestaDelPostulante respuesta;
  final String respuestaCorrecta;
  final String explicacion;
  final VoidCallback onSiguiente;
  final ValueChanged<RespuestaDelPostulante> onDificultad;
  final bool esUltima;
  final bool mostrarCalificacion;

  @override
  Widget build(BuildContext context) {
    final acerto = respuesta.esCorrecta;
    final fondo = acerto
        ? Colors.green.shade50
        : Theme.of(context).colorScheme.errorContainer;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titulo,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Respuesta correcta: $respuestaCorrecta',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(explicacion),
          if (acerto && mostrarCalificacion) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _opcion('Me costó', RespuestaDelPostulante.correctaMeCosto),
                _opcion('Fue fácil', RespuestaDelPostulante.correctaFacil),
              ],
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onSiguiente,
            child: Text(esUltima ? 'Ver resumen' : 'Siguiente'),
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
