import 'package:material_ui/material_ui.dart';

/// Colores fijos de la marca (docs/brand_ui_design_system_skill.md).
///
/// Sirven como relleno sólido (botones, chips seleccionados, insignias) en los
/// dos temas, siempre con [textoSobreAcento] encima. Para texto, íconos y
/// bordes usa [TokensPrepion] (`context.tokens`), que cambia con el tema.
abstract final class ColoresPrepion {
  static const Color medianoche = Color(0xFF0B1320);
  static const Color naranjaSolar = Color(0xFFF86624);
  static const Color azulCielo = Color(0xFF2D9CDB);
  static const Color amarilloDorado = Color(0xFFF9C80E);
  static const Color amarilloBrillo = Color(0xFFFFF275);

  /// Texto sobre cualquier acento sólido (naranja, azul o amarillo).
  static const Color textoSobreAcento = medianoche;

  /// Fondos al 15 % para resultados; funcionan sobre los dos temas.
  static const Color tinteCorrecto = Color(0x262D9CDB);
  static const Color tinteIncorrecto = Color(0x26F86624);
}

/// Colores que dependen del tema: superficies, textos y acentos legibles.
///
/// En el tema claro los acentos se oscurecen para pasar 4,5:1 sobre blanco;
/// en el oscuro son los colores de la marca tal cual.
@immutable
class TokensPrepion extends ThemeExtension<TokensPrepion> {
  const TokensPrepion({
    required this.fondo,
    required this.superficie,
    required this.superficieHover,
    required this.borde,
    required this.textoPrincipal,
    required this.textoSecundario,
    required this.naranja,
    required this.azul,
    required this.dorado,
    required this.brillo,
    required this.foco,
  });

  static const oscuro = TokensPrepion(
    fondo: ColoresPrepion.medianoche,
    superficie: Color(0xFF131E30),
    superficieHover: Color(0xFF1B2A42),
    borde: Color(0x1AFFFFFF),
    textoPrincipal: Color(0xFFF8FAFC),
    textoSecundario: Color(0xFFA3B1C6),
    naranja: ColoresPrepion.naranjaSolar,
    azul: ColoresPrepion.azulCielo,
    dorado: ColoresPrepion.amarilloDorado,
    brillo: ColoresPrepion.amarilloBrillo,
    foco: ColoresPrepion.amarilloBrillo,
  );

  static const claro = TokensPrepion(
    fondo: Color(0xFFF8FAFC),
    superficie: Color(0xFFFFFFFF),
    superficieHover: Color(0xFFEEF2F7),
    borde: Color(0x1F0B1320),
    textoPrincipal: ColoresPrepion.medianoche,
    textoSecundario: Color(0xFF4A5872),
    naranja: Color(0xFFB8440F),
    azul: Color(0xFF176594),
    dorado: Color(0xFF7A5E00),
    brillo: Color(0xFF7C6A00),
    foco: Color(0xFF176594),
  );

  final Color fondo;
  final Color superficie;
  final Color superficieHover;
  final Color borde;
  final Color textoPrincipal;
  final Color textoSecundario;
  final Color naranja;
  final Color azul;
  final Color dorado;
  final Color brillo;
  final Color foco;

  @override
  TokensPrepion copyWith({
    Color? fondo,
    Color? superficie,
    Color? superficieHover,
    Color? borde,
    Color? textoPrincipal,
    Color? textoSecundario,
    Color? naranja,
    Color? azul,
    Color? dorado,
    Color? brillo,
    Color? foco,
  }) {
    return TokensPrepion(
      fondo: fondo ?? this.fondo,
      superficie: superficie ?? this.superficie,
      superficieHover: superficieHover ?? this.superficieHover,
      borde: borde ?? this.borde,
      textoPrincipal: textoPrincipal ?? this.textoPrincipal,
      textoSecundario: textoSecundario ?? this.textoSecundario,
      naranja: naranja ?? this.naranja,
      azul: azul ?? this.azul,
      dorado: dorado ?? this.dorado,
      brillo: brillo ?? this.brillo,
      foco: foco ?? this.foco,
    );
  }

  @override
  TokensPrepion lerp(TokensPrepion? other, double t) {
    if (other == null) return this;
    Color mezcla(Color a, Color b) => Color.lerp(a, b, t)!;
    return TokensPrepion(
      fondo: mezcla(fondo, other.fondo),
      superficie: mezcla(superficie, other.superficie),
      superficieHover: mezcla(superficieHover, other.superficieHover),
      borde: mezcla(borde, other.borde),
      textoPrincipal: mezcla(textoPrincipal, other.textoPrincipal),
      textoSecundario: mezcla(textoSecundario, other.textoSecundario),
      naranja: mezcla(naranja, other.naranja),
      azul: mezcla(azul, other.azul),
      dorado: mezcla(dorado, other.dorado),
      brillo: mezcla(brillo, other.brillo),
      foco: mezcla(foco, other.foco),
    );
  }
}

extension TokensDelTema on BuildContext {
  TokensPrepion get tokens =>
      Theme.of(this).extension<TokensPrepion>() ?? TokensPrepion.oscuro;
}

const _familia = 'Poppins';

TextTheme _crearTipografia(TokensPrepion t) {
  return TextTheme(
    displaySmall: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.64,
      color: t.textoPrincipal,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.42,
      color: t.textoPrincipal,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.25,
      letterSpacing: -0.36,
      color: t.textoPrincipal,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
      letterSpacing: -0.2,
      color: t.textoPrincipal,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: t.textoPrincipal,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: t.textoPrincipal,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.65,
      color: t.textoPrincipal,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.55,
      color: t.textoPrincipal,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.14,
      color: t.textoSecundario,
    ),
    labelLarge: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: 0.15,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: t.textoSecundario,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: t.textoSecundario,
    ),
  );
}

ThemeData _crearTema(TokensPrepion t, Brightness brillo) {
  final esquema = ColorScheme(
    brightness: brillo,
    primary: ColoresPrepion.naranjaSolar,
    onPrimary: ColoresPrepion.textoSobreAcento,
    secondary: t.azul,
    onSecondary: brillo == Brightness.dark
        ? ColoresPrepion.textoSobreAcento
        : Colors.white,
    secondaryContainer: ColoresPrepion.azulCielo,
    onSecondaryContainer: ColoresPrepion.textoSobreAcento,
    tertiary: t.dorado,
    onTertiary: brillo == Brightness.dark
        ? ColoresPrepion.textoSobreAcento
        : Colors.white,
    error: t.naranja,
    onError: brillo == Brightness.dark
        ? ColoresPrepion.textoSobreAcento
        : Colors.white,
    surface: t.fondo,
    onSurface: t.textoPrincipal,
    onSurfaceVariant: t.textoSecundario,
    surfaceContainerLowest: t.fondo,
    surfaceContainerLow: t.superficie,
    surfaceContainer: t.superficie,
    surfaceContainerHigh: t.superficieHover,
    surfaceContainerHighest: t.superficieHover,
    outline: t.textoSecundario,
    outlineVariant: t.borde,
  );
  final tipografia = _crearTipografia(t).apply(fontFamily: _familia);
  final forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  final bordeCampo = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: t.borde),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brillo,
    colorScheme: esquema,
    fontFamily: _familia,
    textTheme: tipografia,
    extensions: <ThemeExtension<dynamic>>[t],
    scaffoldBackgroundColor: t.fondo,
    focusColor: t.foco.withValues(alpha: 0.24),
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: t.fondo,
      foregroundColor: t.textoPrincipal,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: tipografia.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: t.superficie,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: t.borde),
      ),
    ),
    dividerTheme: DividerThemeData(color: t.borde, thickness: 1, space: 1),
    listTileTheme: ListTileThemeData(
      iconColor: t.textoSecundario,
      textColor: t.textoPrincipal,
      titleTextStyle: tipografia.titleMedium,
      subtitleTextStyle: tipografia.bodySmall,
      minVerticalPadding: 12,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: ColoresPrepion.naranjaSolar,
      linearTrackColor: t.superficieHover,
      circularTrackColor: t.superficieHover,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: t.superficie,
      selectedColor: ColoresPrepion.azulCielo,
      labelStyle: tipografia.labelLarge?.copyWith(color: t.textoPrincipal),
      secondaryLabelStyle: tipografia.labelLarge?.copyWith(
        color: ColoresPrepion.textoSobreAcento,
      ),
      checkmarkColor: ColoresPrepion.textoSobreAcento,
      side: BorderSide(color: t.borde),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: t.superficieHover,
      contentTextStyle: tipografia.bodyMedium,
      behavior: SnackBarBehavior.floating,
      shape: forma,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ColoresPrepion.naranjaSolar,
        foregroundColor: ColoresPrepion.textoSobreAcento,
        disabledBackgroundColor: t.superficieHover,
        disabledForegroundColor: t.textoSecundario,
        minimumSize: const Size(double.infinity, 52),
        shape: forma,
        textStyle: tipografia.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.azul,
        disabledForegroundColor: t.textoSecundario,
        side: BorderSide(color: t.azul, width: 1.5),
        minimumSize: const Size(double.infinity, 50),
        shape: forma,
        textStyle: tipografia.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.azul,
        minimumSize: const Size(48, 48),
        textStyle: tipografia.labelLarge,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.superficie,
      border: bordeCampo,
      enabledBorder: bordeCampo,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: t.foco, width: 2),
      ),
      labelStyle: tipografia.bodyMedium?.copyWith(color: t.textoSecundario),
      hintStyle: tipografia.bodyMedium?.copyWith(color: t.textoSecundario),
    ),
  );
}

/// Tema oficial de la marca y el que se usa por defecto.
ThemeData crearTemaPrepion() =>
    _crearTema(TokensPrepion.oscuro, Brightness.dark);

/// Misma marca sobre superficie clara, para quien estudia de día.
ThemeData crearTemaClaroPrepion() =>
    _crearTema(TokensPrepion.claro, Brightness.light);
