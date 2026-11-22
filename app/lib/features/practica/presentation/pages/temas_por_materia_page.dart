import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';
import 'package:prepion/features/practica/presentation/providers/temas_de_materia_provider.dart';
import 'package:prepion/features/practica/presentation/widgets/estilo_materia.dart';

class TemasPorMateriaPage extends ConsumerWidget {
  const TemasPorMateriaPage({required this.materia, super.key});

  final String materia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoTemas = ref.watch(temasDeMateriaProvider(materia));
    final estilo = estiloDeMateria(context, materia);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(estilo.icono, color: estilo.acento),
            const SizedBox(width: 10),
            Flexible(child: Text(materia, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: estadoTemas.when(
          data: (temas) {
            if (temas.isEmpty) {
              return const _Vacio();
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < temas.length; i++) ...[
                        if (i > 0) const Divider(),
                        _FilaTema(
                          key: ValueKey(temas[i].id),
                          tema: temas[i],
                          acento: estilo.acento,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              const Center(child: Text('No se pudieron cargar los temas.')),
        ),
      ),
    );
  }
}

class _FilaTema extends StatelessWidget {
  const _FilaTema({required this.tema, required this.acento, super.key});

  final ResumenTema tema;
  final Color acento;

  @override
  Widget build(BuildContext context) {
    final tipografia = Theme.of(context).textTheme;
    final habilitado = tema.cantidadPreguntas > 0;
    final cantidad = tema.cantidadPreguntas == 1
        ? '1 pregunta'
        : '${tema.cantidadPreguntas} preguntas';

    return ListTile(
      enabled: habilitado,
      contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
      title: Text(tema.nombre),
      subtitle: habilitado
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(cantidad),
                const SizedBox(height: 10),
                BarraDominio(dominio: tema.porcentajeDominio, acento: acento),
              ],
            )
          : const Text('Sin preguntas todavía'),
      trailing: habilitado
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  textoDominio(tema.porcentajeDominio),
                  style: tema.porcentajeDominio == null
                      ? tipografia.labelMedium
                      : tipografia.titleMedium,
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded),
              ],
            )
          : null,
      onTap: habilitado
          ? () => context.push('/practica-libre/${tema.id}')
          : null,
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Esta materia todavía no tiene temas. Prueba con otra materia.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: context.tokens.textoSecundario),
        ),
      ),
    );
  }
}
