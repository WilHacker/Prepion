import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/theme.dart';
import 'package:prepion/features/cuentas/domain/cuenta.dart';
import 'package:prepion/features/cuentas/presentation/providers/cuentas_provider.dart';
import 'package:prepion/features/practica/data/banco_local_service.dart';
import 'package:prepion/features/practica/presentation/providers/preguntas_banco_provider.dart';

/// Previsualiza las preguntas extraídas de un examen válido y permite
/// publicarlas al banco oficial y sincronizarlas al dispositivo al instante.
class ExamenAdminPreguntasPage extends ConsumerStatefulWidget {
  const ExamenAdminPreguntasPage({required this.archivo, super.key});

  final String archivo;

  @override
  ConsumerState<ExamenAdminPreguntasPage> createState() =>
      _ExamenAdminPreguntasPageState();
}

class _ExamenAdminPreguntasPageState
    extends ConsumerState<ExamenAdminPreguntasPage> {
  static const _letras = ['A', 'B', 'C', 'D', 'E'];

  bool _cargando = true;
  bool _publicando = false;
  String? _error;
  List<PreguntaExtraidaAdmin> _preguntas = const [];
  final Set<String> _seleccionadas = <String>{};
  final Map<String, String> _respuestas = <String, String>{};
  final Map<String, TextEditingController> _temas =
      <String, TextEditingController>{};
  final Map<String, TextEditingController> _explicaciones =
      <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(_cargar);
  }

  @override
  void dispose() {
    for (final c in _temas.values) {
      c.dispose();
    }
    for (final c in _explicaciones.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final repo = await ref.read(repositorioCuentasProvider.future);
      final lista = await repo.preguntasDeExamen(widget.archivo);
      if (!mounted) return;
      _seleccionadas.clear();
      for (final p in lista) {
        if (p.tieneOpcionesTexto) {
          _seleccionadas.add(p.codigo);
        }
        _respuestas[p.codigo] = 'A';
        _temas[p.codigo] = TextEditingController(text: p.materia);
        _explicaciones[p.codigo] = TextEditingController(
          text: 'Revisada desde el examen oficial ${widget.archivo}.',
        );
      }
      setState(() {
        _preguntas = lista;
        _cargando = false;
      });
    } on ErrorCuentas catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _cargando = false;
      });
    }
  }

  Future<void> _publicar() async {
    if (_seleccionadas.isEmpty) return;
    setState(() => _publicando = true);
    try {
      final repo = await ref.read(repositorioCuentasProvider.future);
      final entradas = <Map<String, Object?>>[
        for (final p in _preguntas)
          if (_seleccionadas.contains(p.codigo))
            <String, Object?>{
              'codigo': p.codigo,
              'respuesta': _respuestas[p.codigo] ?? 'A',
              'tema': (_temas[p.codigo]?.text.trim().isNotEmpty ?? false)
                  ? _temas[p.codigo]!.text.trim()
                  : p.materia,
              'explicacion':
                  (_explicaciones[p.codigo]?.text.trim().isNotEmpty ?? false)
                  ? _explicaciones[p.codigo]!.text.trim()
                  : 'Revisada desde el examen oficial ${widget.archivo}.',
            },
      ];
      final res = await repo.publicarPreguntasDeExamen(
        widget.archivo,
        entradas,
      );
      final bancoJson = await repo.descargarBanco(res.version);
      await ref.read(bancoLocalServiceProvider).importarBanco(bancoJson);
      ref
        ..invalidate(resumenAdminProvider)
        ..invalidate(preguntasDelBancoProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Banco v${res.version} actualizado '
            '(+${res.agregadas} nuevas · ${res.totalBanco} total). '
            'Ya disponibles en la app.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on ErrorCuentas catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensaje)));
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.archivo)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : _preguntas.isEmpty
          ? const Center(
              child: Text('No se extrajeron preguntas legibles de este PDF.'),
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _preguntas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _tarjeta(_preguntas[i]),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('boton_publicar_examen'),
                        onPressed: _publicando || _seleccionadas.isEmpty
                            ? null
                            : _publicar,
                        icon: const Icon(Icons.publish_outlined),
                        label: Text(
                          _publicando
                              ? 'Publicando y sincronizando...'
                              : 'Agregar ${_seleccionadas.length} al banco',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _tarjeta(PreguntaExtraidaAdmin p) {
    final marcada = _seleccionadas.contains(p.codigo);
    final habilitada = p.tieneOpcionesTexto;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  value: marcada,
                  onChanged: habilitada
                      ? (v) => setState(() {
                          if (v ?? false) {
                            _seleccionadas.add(p.codigo);
                          } else {
                            _seleccionadas.remove(p.codigo);
                          }
                        })
                      : null,
                ),
                Expanded(
                  child: Text(
                    '${p.codigo} · ${p.materia}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                if (!habilitada)
                  const Text(
                    'Requiere imagen',
                    style: TextStyle(color: ColoresPrepion.ambar, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(p.enunciado.isEmpty ? '(Sin texto extraído)' : p.enunciado),
            if (p.opciones.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (var i = 0; i < p.opciones.length && i < _letras.length; i++)
                Text(
                  '${_letras[i]}) ${p.opciones[i]}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
            if (marcada) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: <Widget>[
                  for (final letra in _letras)
                    ChoiceChip(
                      label: Text(letra),
                      selected: _respuestas[p.codigo] == letra,
                      onSelected: (_) =>
                          setState(() => _respuestas[p.codigo] = letra),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _temas[p.codigo],
                decoration: const InputDecoration(
                  labelText: 'Tema',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _explicaciones[p.codigo],
                decoration: const InputDecoration(
                  labelText: 'Explicación',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
