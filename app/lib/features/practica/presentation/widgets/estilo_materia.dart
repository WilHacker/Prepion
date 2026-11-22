import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';

/// Cada materia oficial lleva uno de los cuatro acentos de la marca.
({Color acento, IconData icono}) estiloDeMateria(
  BuildContext context,
  String materia,
) {
  final tokens = context.tokens;
  return switch (materia) {
    'Matemáticas' => (acento: tokens.azul, icono: Icons.calculate_rounded),
    'Física' => (acento: tokens.naranja, icono: Icons.bolt_rounded),
    'Química' => (acento: tokens.dorado, icono: Icons.science_rounded),
    'Biología' => (acento: tokens.brillo, icono: Icons.eco_rounded),
    _ => (acento: tokens.textoSecundario, icono: Icons.book_rounded),
  };
}

String textoDominio(double? dominio) =>
    dominio == null ? 'Sin practicar' : '${(dominio * 100).round()}%';

/// Barra fina de dominio; el porcentaje siempre se muestra también en texto.
class BarraDominio extends StatelessWidget {
  const BarraDominio({required this.dominio, required this.acento, super.key});

  final double? dominio;
  final Color acento;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: dominio ?? 0,
          minHeight: 6,
          color: acento,
          backgroundColor: context.tokens.superficieHover,
        ),
      ),
    );
  }
}
