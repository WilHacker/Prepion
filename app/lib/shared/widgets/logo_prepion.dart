import 'package:material_ui/material_ui.dart';

const rutaLogoPrepion = 'assets/icon/logo_prepion.png';

/// Logo oficial de Prepion, siempre con su proporción original.
class LogoPrepion extends StatelessWidget {
  const LogoPrepion({this.tamano = 32, super.key});

  /// Alto del logo en dp; la marca pide al menos 24.
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      rutaLogoPrepion,
      height: tamano,
      fit: BoxFit.contain,
      semanticLabel: 'Logo de Prepion',
      errorBuilder: (context, error, stackTrace) =>
          SizedBox(width: tamano, height: tamano),
    );
  }
}
