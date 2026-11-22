import 'package:flutter_test/flutter_test.dart';

import 'package:prepion/features/progreso/domain/bkt.dart';

void main() {
  test('un acierto desde el dominio inicial da 0.6927', () {
    // Actuar
    final dominio = actualizarDominio(0.3, acerto: true);

    // Verificar
    expect(dominio, closeTo(0.692683, 1e-5));
  });

  test('un fallo desde el dominio inicial da 0.1458', () {
    // Actuar
    final dominio = actualizarDominio(0.3, acerto: false);

    // Verificar
    expect(dominio, closeTo(0.145763, 1e-5));
  });

  test('acertar sube el dominio y fallar lo baja respecto de acertar', () {
    // Actuar
    final sube = actualizarDominio(0.5, acerto: true);
    final baja = actualizarDominio(0.5, acerto: false);

    // Verificar
    expect(sube, greaterThan(0.5));
    expect(baja, lessThan(sube));
  });

  test('una secuencia acierto, acierto, fallo da el valor calculado', () {
    // Preparar
    // 0.3 -> 0.692683 -> acierto: 0.692683*0.9=0.623415;
    // den=0.623415+0.307317*0.2=0.684878; post=0.910244; sig=0.919220
    // fallo: num=0.091922; den=0.091922+0.08078*0.8=0.156546;
    // post=0.587207; sig=0.587207+0.412793*0.1=0.628486
    var dominio = 0.3;

    // Actuar
    for (final acerto in [true, true, false]) {
      dominio = actualizarDominio(dominio, acerto: acerto);
    }

    // Verificar
    expect(dominio, closeTo(0.628486, 1e-4));
  });

  test('con dominio 0 un acierto solo aporta el aprendizaje', () {
    // Actuar
    final dominio = actualizarDominio(0, acerto: true);

    // Verificar
    expect(dominio, closeTo(0.1, 1e-9));
  });

  test('con dominio 1 un acierto lo deja en 1', () {
    // Actuar
    final dominio = actualizarDominio(1, acerto: true);

    // Verificar
    expect(dominio, closeTo(1, 1e-9));
  });

  test('nunca se sale de 0 a 1 ni divide por cero con parámetros extremos', () {
    // Preparar
    const extremos = ParametrosBkt(adivinar: 0, error: 1, aprendizaje: 0);

    // Actuar
    final a = actualizarDominio(0, acerto: true, parametros: extremos);
    final b = actualizarDominio(1, acerto: false, parametros: extremos);

    // Verificar
    expect(a, inInclusiveRange(0, 1));
    expect(b, inInclusiveRange(0, 1));
    expect(a.isNaN, isFalse);
    expect(b.isNaN, isFalse);
  });

  test('los parámetros por defecto son los del contrato', () {
    // Preparar
    const p = ParametrosBkt();

    // Verificar
    expect(p.inicial, 0.3);
    expect(p.aprendizaje, 0.1);
    expect(p.adivinar, 0.2);
    expect(p.error, 0.1);
  });
}
