import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';
import 'package:prepion/features/practica/presentation/providers/temas_de_materia_provider.dart';

class TemasPorMateriaPage extends ConsumerWidget {
  const TemasPorMateriaPage({required this.materia, super.key});

  final String materia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoTemas = ref.watch(temasDeMateriaProvider(materia));

    return Scaffold(
      appBar: AppBar(title: Text(materia)),
      body: estadoTemas.when(
        data: (temas) {
          if (temas.isEmpty) {
            return const Center(
              child: Text('No hay temas registrados para esta materia.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: temas.length,
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tema = temas[index];
              return _itemTema(context, tema);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            const Center(child: Text('No se pudieron cargar los temas.')),
      ),
    );
  }

  Widget _itemTema(BuildContext context, ResumenTema tema) {
    final temaUi = Theme.of(context);
    final habilitado = tema.cantidadPreguntas > 0;
    final dominioTexto = tema.porcentajeDominio != null
        ? '${(tema.porcentajeDominio! * 100).round()}%'
        : '—';

    return ListTile(
      enabled: habilitado,
      title: Text(
        tema.nombre,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: habilitado ? null : temaUi.disabledColor,
        ),
      ),
      subtitle: Text(
        habilitado
            ? '${tema.cantidadPreguntas} preguntas'
            : 'Sin preguntas todavía',
        style: TextStyle(color: habilitado ? null : temaUi.disabledColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dominioTexto,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: habilitado && tema.porcentajeDominio != null
                  ? temaUi.colorScheme.primary
                  : temaUi.disabledColor,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: habilitado ? null : temaUi.disabledColor,
          ),
        ],
      ),
      onTap: habilitado
          ? () => context.push('/practica-libre/${tema.id}')
          : null,
    );
  }
}
