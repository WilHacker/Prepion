import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/reportes/data/reportes_service.dart';

/// Diálogo modal para que el postulante reporte anomalías en una pregunta (HU-09).
class DialogoReportePregunta extends ConsumerStatefulWidget {
  const DialogoReportePregunta({required this.preguntaId, super.key});

  final String preguntaId;

  static Future<void> mostrar(
    BuildContext context, {
    required String preguntaId,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => DialogoReportePregunta(preguntaId: preguntaId),
    );
  }

  @override
  ConsumerState<DialogoReportePregunta> createState() =>
      _DialogoReportePreguntaState();
}

class _DialogoReportePreguntaState
    extends ConsumerState<DialogoReportePregunta> {
  String _motivoSeleccionado = 'respuesta_incorrecta';
  final _comentarioController = TextEditingController();
  bool _enviando = false;

  static const _motivos = [
    ('respuesta_incorrecta', 'Respuesta incorrecta'),
    ('imagen_borrosa', 'Imagen o fórmula borrosa'),
    ('error_tipografico', 'Error tipográfico'),
    ('otro', 'Otro motivo'),
  ];

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    final servicio = ref.read(reportesServiceProvider);
    await servicio.enviarReporte(
      preguntaId: widget.preguntaId,
      motivo: _motivoSeleccionado,
      comentario: _comentarioController.text.trim().isEmpty
          ? null
          : _comentarioController.text.trim(),
    );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gracias por tu reporte. Nuestro equipo de curación lo revisará.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reportar problema'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué problema detectaste en esta pregunta?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (clave, etiqueta) in _motivos)
                  ChoiceChip(
                    label: Text(etiqueta),
                    selected: _motivoSeleccionado == clave,
                    onSelected: _enviando
                        ? null
                        : (seleccionado) {
                            if (seleccionado) {
                              setState(() => _motivoSeleccionado = clave);
                            }
                          },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioController,
              enabled: !_enviando,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Comentario adicional (opcional)',
                hintText: 'Describe el error encontrado...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _enviando ? null : _enviar,
          child: _enviando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar reporte'),
        ),
      ],
    );
  }
}
