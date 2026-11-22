import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/progreso/domain/resumen_progreso.dart';
import 'package:prepion/features/progreso/presentation/widgets/colores_semaforo.dart';

/// Hasta 3 temas con menor dominio.
class TemasAReforzar extends StatelessWidget {
  const TemasAReforzar({required this.temas, super.key});

  final List<DominioTema> temas;

  @override
  Widget build(BuildContext context) {
    if (temas.isEmpty) {
      return const Text('Aún no hay temas para reforzar.');
    }
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final tema in temas.take(3))
          ListTile(
            leading: Icon(
              Icons.circle,
              size: 14,
              color: colorDeSemaforo(semaforoDe(tema.dominio)),
            ),
            title: Text(tema.nombre),
            subtitle: Text(tema.materia),
            trailing: Text(
              '${(tema.dominio * 100).round()} %',
              style: textTheme.titleSmall,
            ),
          ),
      ],
    );
  }
}
