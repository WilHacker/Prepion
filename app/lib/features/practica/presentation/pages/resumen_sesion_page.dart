import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';

/// Cierre de la sesión: aciertos, fallos, tiempo total y racha de días.
class ResumenSesionPage extends StatelessWidget {
  const ResumenSesionPage({required this.estado, super.key});

  final EstadoSesion estado;

  @override
  Widget build(BuildContext context) {
    final total = estado.resultados.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Sesión terminada')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¡Buen trabajo!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            _dato(context, 'Aciertos', '${estado.aciertos} de $total'),
            _dato(context, 'Para repasar', '${estado.fallos}'),
            _dato(context, 'Tiempo', formatearDuracion(estado.tiempoTotalMs)),
            _dato(
              context,
              'Racha',
              estado.racha == 1 ? '1 día' : '${estado.racha} días',
              icono: Icons.local_fire_department,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Terminar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(
    BuildContext context,
    String etiqueta,
    String valor, {
    IconData? icono,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        if (icono != null) ...[Icon(icono), const SizedBox(width: 8)],
        Expanded(child: Text(etiqueta)),
        Text(valor, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

/// 83 000 ms → "01:23".
String formatearDuracion(int milisegundos) {
  final segundos = milisegundos ~/ 1000;
  final minutos = (segundos ~/ 60).toString().padLeft(2, '0');
  final resto = (segundos % 60).toString().padLeft(2, '0');
  return '$minutos:$resto';
}
