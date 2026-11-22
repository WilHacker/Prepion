import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/practica/presentation/providers/preguntas_banco_provider.dart';
import 'package:prepion/features/practica/presentation/widgets/tarjeta_enunciado.dart';
import 'package:prepion/shared/database/app_database.dart';

const _letras = ['A', 'B', 'C', 'D', 'E'];

/// Lista todas las preguntas del banco local para revisarlas en el celular:
/// cómo se ven las imágenes, los textos y las fuentes, y si la clave es la correcta.
class VistaPreviaBancoPage extends ConsumerWidget {
  const VistaPreviaBancoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preguntas = ref.watch(preguntasDelBancoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Banco de preguntas')),
      body: preguntas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, pila) =>
            const Center(child: Text('No se pudo leer el banco de preguntas.')),
        data: (lista) => lista.isEmpty
            ? const Center(
                child: Text('Todavía no hay preguntas en el banco local.'),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: lista.length,
                itemBuilder: (context, indice) =>
                    _ItemPregunta(pregunta: lista[indice]),
              ),
      ),
    );
  }
}

class _ItemPregunta extends StatefulWidget {
  const _ItemPregunta({required this.pregunta});

  final Pregunta pregunta;

  @override
  State<_ItemPregunta> createState() => _ItemPreguntaState();
}

class _ItemPreguntaState extends State<_ItemPregunta> {
  bool _muestraRespuesta = false;

  @override
  Widget build(BuildContext context) {
    final pregunta = widget.pregunta;
    final rutaImagen = pregunta.rutaImagen;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TarjetaEnunciado(
            enunciado: pregunta.enunciado,
            fuente: pregunta.fuente,
            imagen: rutaImagen == null ? null : AssetImage(rutaImagen),
          ),
          const SizedBox(height: 8),
          // El recorte ya muestra las opciones: aquí solo van las letras.
          if (rutaImagen == null) _opcionesConTexto() else _soloLetras(),
          TextButton(
            onPressed: () =>
                setState(() => _muestraRespuesta = !_muestraRespuesta),
            child: Text(
              _muestraRespuesta ? 'Ocultar respuesta' : 'Ver respuesta',
            ),
          ),
          if (_muestraRespuesta) ...[
            Text(
              'Respuesta correcta: ${pregunta.respuesta}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(pregunta.explicacion),
          ],
        ],
      ),
    );
  }

  Widget _opcionesConTexto() {
    final opciones = widget.pregunta.opciones;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < opciones.length && i < _letras.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('${_letras[i]}) ${opciones[i]}'),
          ),
      ],
    );
  }

  Widget _soloLetras() {
    final cantidad = widget.pregunta.opciones.length.clamp(0, _letras.length);
    return Wrap(
      spacing: 8,
      children: [
        for (var i = 0; i < cantidad; i++) Chip(label: Text(_letras[i])),
      ],
    );
  }
}
