import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/progreso/domain/resumen_progreso.dart';
import 'package:prepion/features/progreso/presentation/providers/progreso_provider.dart';
import 'package:prepion/features/progreso/presentation/widgets/grafico_dominio.dart';
import 'package:prepion/features/progreso/presentation/widgets/medidor_nivel.dart';
import 'package:prepion/features/progreso/presentation/widgets/temas_a_reforzar.dart';

class ProgresoPage extends ConsumerWidget {
  const ProgresoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progreso = ref.watch(progresoProvider);
    final etiqueta = ref.watch(etiquetaModeloConocimientoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mi progreso')),
      body: progreso.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('No se pudo calcular tu progreso.')),
        data: (resumen) => resumen.totalRespuestas == 0
            ? const _EstadoVacio()
            : _Contenido(resumen: resumen, etiquetaModelo: etiqueta),
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Todavía no tienes respuestas. '
              '¡Practica un poco para ver tu progreso!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.push('/practica'),
              child: const Text('Practicar hoy'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.resumen, this.etiquetaModelo});

  final ResumenProgreso resumen;
  final String? etiquetaModelo;

  static String _dias(int n) => n == 1 ? '1 día' : '$n días';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dias = resumen.diasParaElExamen;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MedidorNivel(nivel: resumen.nivel),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.local_fire_department),
            const SizedBox(width: 4),
            Text(_dias(resumen.racha)),
            const Spacer(),
            if (dias != null)
              Text(
                dias == 1
                    ? 'Falta 1 día para tu examen'
                    : 'Faltan $dias días para tu examen',
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Dominio por materia', style: textTheme.titleMedium),
        const SizedBox(height: 12),
        GraficoDominio(materias: resumen.materias),
        const SizedBox(height: 24),
        Text('Temas que debes reforzar', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        TemasAReforzar(temas: resumen.temasAReforzar),
        if (etiquetaModelo != null) ...[
          const SizedBox(height: 24),
          Text(
            etiquetaModelo!,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
