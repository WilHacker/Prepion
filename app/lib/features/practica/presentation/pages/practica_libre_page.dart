import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica_libre.dart';
import 'package:prepion/features/practica/presentation/widgets/hoja_explicacion.dart';
import 'package:prepion/features/practica/presentation/widgets/tarjeta_pregunta.dart';
import 'package:prepion/features/reportes/presentation/widgets/dialogo_reporte_pregunta.dart';

class PracticaLibrePage extends ConsumerStatefulWidget {
  const PracticaLibrePage({required this.temaId, super.key});

  final String temaId;

  @override
  ConsumerState<PracticaLibrePage> createState() => _PracticaLibrePageState();
}

class _PracticaLibrePageState extends ConsumerState<PracticaLibrePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(sesionPracticaLibreProvider(widget.temaId).notifier)
          .cargar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(sesionPracticaLibreProvider(widget.temaId));
    final notifier = ref.read(
      sesionPracticaLibreProvider(widget.temaId).notifier,
    );
    final temaTitulo = estado.tema?.nombre ?? 'Práctica libre';
    final enCurso =
        estado.fase == FaseSesionLibre.respondiendo ||
        estado.fase == FaseSesionLibre.explicando;
    final total = estado.preguntas.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(temaTitulo, overflow: TextOverflow.ellipsis),
        actions: [
          if (enCurso)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '${estado.indice + 1}/$total',
                  semanticsLabel: 'Pregunta ${estado.indice + 1} de $total',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
        ],
        bottom: enCurso && total > 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: LinearProgressIndicator(
                  value: (estado.indice + 1) / total,
                  minHeight: 4,
                ),
              )
            : null,
      ),
      body: switch (estado.fase) {
        FaseSesionLibre.cargando => const Center(
          child: CircularProgressIndicator(),
        ),
        FaseSesionLibre.vacia => _vistaVacia(context),
        FaseSesionLibre.respondiendo ||
        FaseSesionLibre.explicando => _vistaPregunta(context, estado, notifier),
        FaseSesionLibre.terminada => _vistaTerminada(context, estado, notifier),
      },
    );
  }

  Widget _vistaVacia(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 56,
              color: context.tokens.textoSecundario,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin preguntas todavía',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Este tema aún no tiene preguntas en tu banco local. '
              'Elige otro tema para seguir practicando.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: context.tokens.textoSecundario),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('Volver a temas'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vistaPregunta(
    BuildContext context,
    EstadoSesionLibre estado,
    SesionPracticaLibre notifier,
  ) {
    final pregunta = estado.preguntaActual!;
    final esExplicando = estado.fase == FaseSesionLibre.explicando;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TarjetaPregunta(
            pregunta: pregunta,
            onElegir: (letra) => notifier.elegir(letra),
            onNoSe: () => notifier.noSe(),
            letraElegida: estado.letraElegida,
            muestraClave: esExplicando,
          ),
          if (esExplicando && estado.respuesta != null) ...[
            const SizedBox(height: 16),
            HojaExplicacion(
              respuesta: estado.respuesta!,
              respuestaCorrecta: pregunta.respuesta,
              explicacion: pregunta.explicacion,
              esUltima: estado.esUltima,
              mostrarCalificacion: false,
              onSiguiente: () => notifier.siguiente(),
              onDificultad: (_) {},
              onReportarError: () => DialogoReportePregunta.mostrar(
                context,
                preguntaId: pregunta.id,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _vistaTerminada(
    BuildContext context,
    EstadoSesionLibre estado,
    SesionPracticaLibre notifier,
  ) {
    final total = estado.totalRespondidas == 0 ? 1 : estado.totalRespondidas;
    final porcentaje = ((estado.aciertos / total) * 100).round();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded, size: 64, color: context.tokens.azul),
            const SizedBox(height: 16),
            Text(
              '¡Práctica completada!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${estado.aciertos} de ${estado.totalRespondidas} correctas ($porcentaje%)',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: context.tokens.textoSecundario),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => notifier.reiniciar(),
              child: const Text('Volver a practicar'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Elegir otro tema'),
            ),
          ],
        ),
      ),
    );
  }
}
