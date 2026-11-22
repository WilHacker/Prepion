import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';
import 'package:prepion/features/practica/presentation/providers/catalogo_provider.dart';
import 'package:prepion/features/practica/presentation/widgets/estilo_materia.dart';

class CatalogoMateriasPage extends ConsumerWidget {
  const CatalogoMateriasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoMaterias = ref.watch(catalogoMateriasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Materias')),
      body: SafeArea(
        top: false,
        child: estadoMaterias.when(
          data: (materias) => _Lista(materias: materias),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) =>
              const Center(child: Text('No se pudieron cargar las materias.')),
        ),
      ),
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.materias});

  final List<ResumenMateria> materias;

  @override
  Widget build(BuildContext context) {
    final tipografia = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        Text(
          'Practica un tema sin límite diario. Tu repaso de hoy no cambia.',
          style: tipografia.bodyMedium?.copyWith(
            color: context.tokens.textoSecundario,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < materias.length; i++) ...[
                if (i > 0) const Divider(),
                _FilaMateria(
                  key: ValueKey(materias[i].nombre),
                  materia: materias[i],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FilaMateria extends StatelessWidget {
  const _FilaMateria({required this.materia, super.key});

  final ResumenMateria materia;

  @override
  Widget build(BuildContext context) {
    final tipografia = Theme.of(context).textTheme;
    final estilo = estiloDeMateria(context, materia.nombre);
    final tienePreguntas = materia.cantidadPreguntas > 0;
    final detalle = tienePreguntas
        ? '${_contar(materia.cantidadPreguntas, 'pregunta', 'preguntas')} '
              'en ${_contar(materia.cantidadTemas, 'tema', 'temas')}'
        : 'Sin preguntas todavía';

    return Semantics(
      button: tienePreguntas,
      enabled: tienePreguntas,
      label:
          '${materia.nombre}. $detalle. '
          'Dominio: ${textoDominio(materia.porcentajeDominio)}',
      excludeSemantics: true,
      child: InkWell(
        onTap: tienePreguntas
            ? () => context.push(
                '/materias/${Uri.encodeComponent(materia.nombre)}',
              )
            : null,
        child: Opacity(
          opacity: tienePreguntas ? 1 : 0.55,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: estilo.acento.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(estilo.icono, color: estilo.acento),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(materia.nombre, style: tipografia.titleMedium),
                          Text(detalle, style: tipografia.bodySmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      textoDominio(materia.porcentajeDominio),
                      style: materia.porcentajeDominio == null
                          ? tipografia.labelMedium
                          : tipografia.titleMedium,
                    ),
                  ],
                ),
                if (tienePreguntas) ...[
                  const SizedBox(height: 14),
                  BarraDominio(
                    dominio: materia.porcentajeDominio,
                    acento: estilo.acento,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _contar(int cantidad, String singular, String plural) =>
    '$cantidad ${cantidad == 1 ? singular : plural}';
