import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/app/integracion_conocimiento.dart';
import 'package:prepion/features/conocimiento/data/repositorio_conocimiento.dart';
import 'package:prepion/features/conocimiento/domain/parametros_conocimiento.dart';
import 'package:prepion/features/conocimiento/presentation/providers/conocimiento_provider.dart';
import 'package:prepion/features/practica/presentation/providers/sesion_practica.dart';
import 'package:prepion/features/progreso/presentation/providers/progreso_provider.dart';

ParametrosConocimiento _paquete(int version, {String? origen = 'simulado'}) =>
    ParametrosConocimiento(
      version: version,
      origen: origen,
      dificultadPorPregunta: const {'p1': 1.5},
      bktPorTema: const {
        't1': ParametrosBktTema(
          pInicial: 0.4,
          pAprendizaje: 0.2,
          pAdivinar: 0.15,
          pError: 0.05,
        ),
      },
    );

class _Repo implements RepositorioConocimiento {
  _Repo(this.actual, {this.remoto, this.falla = false});

  ParametrosConocimiento? actual;
  final ParametrosConocimiento? remoto;
  final bool falla;

  @override
  Future<ParametrosConocimiento?> cargar() async => actual;

  @override
  Future<ParametrosConocimiento?> sincronizar() async {
    if (falla) throw Exception('disco');
    if (remoto != null) actual = remoto;
    return actual;
  }
}

void main() {
  ProviderContainer crear(_Repo repo) {
    final c = ProviderContainer(
      overrides: [
        ...sobrescriturasDeConocimiento,
        repositorioConocimientoProvider.overrideWith((ref) async => repo),
      ],
    );
    addTearDown(c.dispose);
    c
      ..listen(parametrosConocimientoProvider, (a, b) {})
      ..listen(dificultadPorPreguntaProvider, (a, b) {})
      ..listen(parametrosBktPorTemaProvider, (a, b) {})
      ..listen(etiquetaModeloConocimientoProvider, (a, b) {});
    return c;
  }

  test('entrega los mapas y la etiqueta del paquete', () async {
    // Preparar
    final c = crear(_Repo(_paquete(2)));

    // Actuar
    await c.read(parametrosConocimientoProvider.future);

    // Verificar
    expect(c.read(dificultadPorPreguntaProvider), {'p1': 1.5});
    final bkt = c.read(parametrosBktPorTemaProvider)['t1']!;
    expect(bkt.inicial, 0.4);
    expect(bkt.aprendizaje, 0.2);
    expect(bkt.adivinar, 0.15);
    expect(bkt.error, 0.05);
    expect(
      c.read(etiquetaModeloConocimientoProvider),
      'Modelo de conocimiento v2 · datos simulados',
    );
  });

  test('indica datos reales cuando el origen es real', () async {
    // Preparar
    final c = crear(_Repo(_paquete(3, origen: 'real')));

    // Actuar
    await c.read(parametrosConocimientoProvider.future);

    // Verificar
    expect(
      c.read(etiquetaModeloConocimientoProvider),
      'Modelo de conocimiento v3 · datos reales',
    );
  });

  test('sin paquete deja los valores por defecto', () async {
    // Preparar
    final c = crear(_Repo(null));

    // Actuar
    await c.read(parametrosConocimientoProvider.future);

    // Verificar
    expect(c.read(dificultadPorPreguntaProvider), isEmpty);
    expect(c.read(parametrosBktPorTemaProvider), isEmpty);
    expect(c.read(etiquetaModeloConocimientoProvider), isNull);
  });

  test('la sincronización actualiza lo que ven práctica y progreso', () async {
    // Preparar
    final c = crear(_Repo(_paquete(1), remoto: _paquete(2)));
    await c.read(parametrosConocimientoProvider.future);

    // Actuar
    await iniciarSincronizacionConocimiento(c);
    await c.read(parametrosConocimientoProvider.future);

    // Verificar
    expect(
      c.read(etiquetaModeloConocimientoProvider),
      'Modelo de conocimiento v2 · datos simulados',
    );
  });

  test(
    'iniciarSincronizacionConocimiento no lanza si el repositorio falla',
    () {
      // Preparar
      final c = crear(_Repo(_paquete(1), falla: true));

      // Actuar y verificar
      expect(iniciarSincronizacionConocimiento(c), completes);
    },
  );
}
