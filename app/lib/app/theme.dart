import 'package:material_ui/material_ui.dart';

/// Paleta académica intencional de Prepion (FCyT · UMSS).
abstract final class ColoresPrepion {
  static const Color azulMarino = Color(0xFF0F2942);
  static const Color azulMedio = Color(0xFF1D4E7A);
  static const Color ambar = Color(0xFFE07A22);
  static const Color ambarSuave = Color(0xFFFFF3E6);
  static const Color fondo = Color(0xFFF6F8FB);
  static const Color superficie = Color(0xFFFFFFFF);
  static const Color borde = Color(0xFFD9E2EC);
  static const Color textoPrincipal = Color(0xFF102A43);
  static const Color textoSecundario = Color(0xFF486581);
  static const Color exito = Color(0xFF1F7A4C);
}

ThemeData crearTemaPrepion() {
  final esquema = ColorScheme.fromSeed(
    seedColor: ColoresPrepion.azulMarino,
    primary: ColoresPrepion.azulMarino,
    secondary: ColoresPrepion.ambar,
    surface: ColoresPrepion.superficie,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: ColoresPrepion.fondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColoresPrepion.fondo,
      foregroundColor: ColoresPrepion.textoPrincipal,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: ColoresPrepion.superficie,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: ColoresPrepion.borde),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ColoresPrepion.azulMarino,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ColoresPrepion.azulMarino,
        side: const BorderSide(color: ColoresPrepion.borde),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ColoresPrepion.textoSecundario,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
