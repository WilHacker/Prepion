import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/domain/catalogo.dart';
import 'package:prepion/features/practica/presentation/providers/catalogo_provider.dart';

class CatalogoMateriasPage extends ConsumerWidget {
  const CatalogoMateriasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoMaterias = ref.watch(catalogoMateriasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Materias')),
      body: estadoMaterias.when(
        data: (materias) => _listaMaterias(context, materias),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            const Center(child: Text('No se pudieron cargar las materias.')),
      ),
    );
  }

  Widget _listaMaterias(BuildContext context, List<ResumenMateria> materias) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materias.length,
      itemBuilder: (context, index) {
        final materia = materias[index];
        return _tarjetaMateria(context, materia);
      },
    );
  }

  Widget _tarjetaMateria(BuildContext context, ResumenMateria materia) {
    final tema = Theme.of(context);
    final dominioTexto = materia.porcentajeDominio != null
        ? '${(materia.porcentajeDominio! * 100).round()}%'
        : '—';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: tema.colorScheme.primaryContainer,
          foregroundColor: tema.colorScheme.onPrimaryContainer,
          child: Icon(_iconoPara(materia.nombre)),
        ),
        title: Text(
          materia.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${materia.cantidadPreguntas} preguntas · ${materia.cantidadTemas} temas',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              dominioTexto,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: materia.porcentajeDominio != null
                    ? tema.colorScheme.primary
                    : tema.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Dominio',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap: () =>
            context.push('/materias/${Uri.encodeComponent(materia.nombre)}'),
      ),
    );
  }

  IconData _iconoPara(String materia) {
    return switch (materia) {
      'Matemáticas' => Icons.calculate_outlined,
      'Física' => Icons.bolt_outlined,
      'Química' => Icons.science_outlined,
      'Biología' => Icons.eco_outlined,
      _ => Icons.book_outlined,
    };
  }
}
