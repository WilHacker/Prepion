import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/app/theme.dart';

void main() {
  test('el tema oscuro usa los colores oficiales de la marca', () {
    // Actuar
    final tema = crearTemaPrepion();

    // Verificar
    expect(tema.brightness, Brightness.dark);
    expect(tema.scaffoldBackgroundColor, ColoresPrepion.medianoche);
    expect(tema.colorScheme.primary, ColoresPrepion.naranjaSolar);
    expect(tema.extension<TokensPrepion>(), TokensPrepion.oscuro);
    expect(tema.textTheme.bodyMedium?.fontFamily, 'Poppins');
  });

  test('el tema claro conserva Poppins y oscurece los acentos para texto', () {
    // Actuar
    final tema = crearTemaClaroPrepion();

    // Verificar
    expect(tema.brightness, Brightness.light);
    expect(tema.extension<TokensPrepion>(), TokensPrepion.claro);
    expect(tema.textTheme.bodyMedium?.fontFamily, 'Poppins');
    expect(tema.colorScheme.primary, ColoresPrepion.naranjaSolar);
    expect(TokensPrepion.claro.azul, isNot(ColoresPrepion.azulCielo));
  });

  test('mezcla los tokens al animar el cambio de tema', () {
    // Actuar
    final mitad = TokensPrepion.oscuro.lerp(TokensPrepion.claro, 0.5);
    final copia = TokensPrepion.oscuro.copyWith(
      azul: ColoresPrepion.naranjaSolar,
    );

    // Verificar
    expect(
      mitad.fondo,
      Color.lerp(TokensPrepion.oscuro.fondo, TokensPrepion.claro.fondo, 0.5),
    );
    expect(TokensPrepion.oscuro.lerp(null, 0.5), TokensPrepion.oscuro);
    expect(copia.azul, ColoresPrepion.naranjaSolar);
    expect(copia.fondo, TokensPrepion.oscuro.fondo);
  });
}
