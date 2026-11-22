import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/progreso/domain/resumen_progreso.dart';
import 'package:prepion/features/progreso/presentation/widgets/colores_semaforo.dart';

/// Tarjeta con el nivel de preparación estimado y la advertencia ética.
class MedidorNivel extends StatelessWidget {
  const MedidorNivel({required this.nivel, super.key});

  final NivelPreparacion nivel;

  static const _segmentos = [
    (NivelPreparacion.bajo, 'Bajo', Semaforo.rojo),
    (NivelPreparacion.medio, 'Medio', Semaforo.amarillo),
    (NivelPreparacion.alto, 'Alto', Semaforo.verde),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nivel == NivelPreparacion.sinDatos)
              const Text(
                'Responde al menos 10 preguntas para estimar tu nivel.',
              )
            else ...[
              Text(
                'Nivel estimado: ${_nombre(nivel)}',
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final (valor, nombre, semaforo) in _segmentos)
                    Expanded(
                      child: _Segmento(nombre, semaforo, valor == nivel),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Estimación basada en tu práctica; no garantiza la admisión.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _nombre(NivelPreparacion nivel) =>
      _segmentos.firstWhere((segmento) => segmento.$1 == nivel).$2;
}

class _Segmento extends StatelessWidget {
  const _Segmento(this.nombre, this.semaforo, this.activo);

  final String nombre;
  final Semaforo semaforo;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final color = colorDeSemaforo(semaforo);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          Container(
            height: activo ? 16 : 8,
            decoration: BoxDecoration(
              color: activo ? color : color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nombre,
            style: TextStyle(
              fontWeight: activo ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
