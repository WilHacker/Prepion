import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prepion/features/conocimiento/data/repositorio_conocimiento.dart';
import 'package:prepion/features/conocimiento/domain/parametros_conocimiento.dart';
import 'package:prepion/features/conocimiento/presentation/providers/conocimiento_provider.dart';

ParametrosConocimiento _paquete(int version) => ParametrosConocimiento(
  version: version,
  dificultadPorPregunta: const {},
  bktPorTema: const {},
);

class RepositorioFalso implements RepositorioConocimiento {
  RepositorioFalso(this.actual, {this.remoto});

  ParametrosConocimiento? actual;
  final ParametrosConocimiento? remoto;
  int sincronizaciones = 0;

  @override
  Future<ParametrosConocimiento?> cargar() async => actual;

  @override
  Future<ParametrosConocimiento?> sincronizar() async {
    sincronizaciones++;
    if (remoto != null) actual = remoto;
    return actual;
  }
}

void main() {
  ProviderContainer crear(RepositorioFalso repo) {
    final c = ProviderContainer(
      overrides: [
        repositorioConocimientoProvider.overrideWith((ref) async => repo),
      ],
    );
    addTearDown(c.dispose);
    c.listen(parametrosConocimientoProvider, (a, b) {});
    return c;
  }

  test('entrega el paquete vigente del repositorio', () async {
    // Preparar
    final c = crear(RepositorioFalso(_paquete(1)));

    // Actuar
    final p = await c.read(parametrosConocimientoProvider.future);

    // Verificar
    expect(p!.version, 1);
  });

  test('se refresca cuando la sincronización trae un paquete nuevo', () async {
    // Preparar
    final repo = RepositorioFalso(_paquete(1), remoto: _paquete(2));
    final c = crear(repo);
    await c.read(parametrosConocimientoProvider.future);

    // Actuar
    await sincronizarConocimiento(c);

    // Verificar
    expect((await c.read(parametrosConocimientoProvider.future))!.version, 2);
    expect(repo.sincronizaciones, 1);
  });

  test('conserva el valor cuando no hay paquete nuevo', () async {
    // Preparar
    final c = crear(RepositorioFalso(_paquete(1)));
    final antes = await c.read(parametrosConocimientoProvider.future);

    // Actuar
    await sincronizarConocimiento(c);

    // Verificar
    expect(await c.read(parametrosConocimientoProvider.future), same(antes));
  });
}
