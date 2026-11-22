import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/modo_tema_provider.dart';
import 'package:prepion/app/theme.dart';

/// Elige entre el modo claro y el oscuro; comparte estado con el botón del inicio.
class TarjetaApariencia extends ConsumerWidget {
  const TarjetaApariencia({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final tipografia = Theme.of(context).textTheme;
    final modo = ref.watch(modoTemaProvider);
    void elegir(ThemeMode nuevo) =>
        ref.read(modoTemaProvider.notifier).state = nuevo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Apariencia', style: tipografia.titleMedium),
          Text('Elige cómo prefieres estudiar', style: tipografia.bodySmall),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _OpcionModo(
                  key: const Key('opcion_modo_claro'),
                  icono: Icons.light_mode_rounded,
                  texto: 'Modo Claro',
                  seleccionada: modo == ThemeMode.light,
                  onTap: () => elegir(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OpcionModo(
                  key: const Key('opcion_modo_oscuro'),
                  icono: Icons.dark_mode_rounded,
                  texto: 'Modo Oscuro',
                  seleccionada: modo != ThemeMode.light,
                  onTap: () => elegir(ThemeMode.dark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OpcionModo extends StatelessWidget {
  const _OpcionModo({
    required this.icono,
    required this.texto,
    required this.seleccionada,
    required this.onTap,
    super.key,
  });

  final IconData icono;
  final String texto;
  final bool seleccionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = seleccionada
        ? ColoresPrepion.textoSobreAcento
        : tokens.textoPrincipal;
    return Semantics(
      button: true,
      selected: seleccionada,
      child: Material(
        color: seleccionada ? ColoresPrepion.azulCielo : tokens.fondo,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: seleccionada ? ColoresPrepion.azulCielo : tokens.borde,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(icono, size: 18, color: color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      texto,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
