import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/practica/presentation/pages/resumen_sesion_page.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/features/practica/presentation/widgets/hoja_explicacion.dart';
import 'package:prepion/features/practica/presentation/widgets/tarjeta_pregunta.dart';

/// Práctica diaria: una pregunta a la vez, con explicación inmediata.
class PracticaPage extends ConsumerStatefulWidget {
  const PracticaPage({super.key});

  @override
  ConsumerState<PracticaPage> createState() => _PracticaPageState();
}

class _PracticaPageState extends ConsumerState<PracticaPage> {
  final _desplazamiento = ScrollController();
  final _claveDeLaExplicacion = GlobalKey();

  @override
  void dispose() {
    _desplazamiento.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Se arma la sesión al abrir; no puede ir en build porque cambia el estado.
    Future.microtask(ref.read(sesionPracticaProvider.notifier).iniciar);
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(sesionPracticaProvider);
    return switch (estado.fase) {
      FaseSesion.cargando => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      FaseSesion.vacia => _vacia(context),
      FaseSesion.terminada => ResumenSesionPage(estado: estado),
      FaseSesion.respondiendo ||
      FaseSesion.explicando => _pregunta(context, estado),
    };
  }

  Widget _vacia(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Práctica de hoy')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '¡Hoy no tienes más preguntas para practicar!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _pregunta(BuildContext context, EstadoSesion estado) {
    final sesion = ref.read(sesionPracticaProvider.notifier);
    final pregunta = estado.preguntaActual;
    final respuesta = estado.respuesta;
    final total = estado.preguntas.length;
    final explicando = estado.fase == FaseSesion.explicando;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Salir de la práctica',
          onPressed: () => _confirmarSalida(context),
        ),
        title: Text('${estado.indice + 1}/$total'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (estado.indice + (explicando ? 1 : 0)) / total,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _desplazamiento,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TarjetaPregunta(
              pregunta: pregunta,
              onElegir: (letra) => _alResponder(() => sesion.elegir(letra)),
              onNoSe: () => _alResponder(sesion.noSe),
              letraElegida: estado.letraElegida,
              muestraClave: explicando,
            ),
            if (explicando && respuesta != null) ...[
              const SizedBox(height: 16),
              KeyedSubtree(
                key: _claveDeLaExplicacion,
                child: HojaExplicacion(
                  respuesta: respuesta,
                  respuestaCorrecta: pregunta.respuesta,
                  explicacion: pregunta.explicacion,
                  esUltima: estado.indice + 1 >= total,
                  onDificultad: sesion.marcarDificultad,
                  onSiguiente: () => _siguiente(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Responde y baja hasta la explicación: queda debajo del borde de la pantalla.
  void _alResponder(VoidCallback responder) {
    responder();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final explicacion = _claveDeLaExplicacion.currentContext;
      if (explicacion == null) return;
      unawaited(
        Scrollable.ensureVisible(
          explicacion,
          duration: const Duration(milliseconds: 250),
        ),
      );
    });
  }

  Future<void> _siguiente(BuildContext context) async {
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(sesionPracticaProvider.notifier).siguiente();
      // La pregunta nueva empieza desde arriba.
      if (_desplazamiento.hasClients) _desplazamiento.jumpTo(0);
    } on Exception {
      mensajes.showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar tu respuesta. Inténtalo de nuevo.'),
        ),
      );
    }
  }

  Future<void> _confirmarSalida(BuildContext context) async {
    final navegador = Navigator.of(context);
    final salir = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('¿Salir de la práctica?'),
        content: const Text('Lo que ya respondiste queda guardado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: const Text('Seguir'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (salir ?? false) navegador.pop();
  }
}
