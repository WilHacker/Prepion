import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:prepion/app/integracion_conocimiento.dart';
import 'package:prepion/app/integracion_preferencias.dart';
import 'package:prepion/app/prepion_app.dart';
import 'package:prepion/app/router.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:prepion/features/practica/data/banco_local_service.dart';
import 'package:prepion/features/practica/data/practica_repositorio.dart';
import 'package:prepion/features/sincronizacion/presentation/providers/sincronizacion_provider.dart';
import 'package:prepion/shared/notifications/notificaciones_servicio.dart';
import 'package:prepion/shared/notifications/planificacion_recordatorio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final contenedor = ProviderContainer(
    overrides: [
      ...sobrescriturasDePreferencias,
      ...sobrescriturasDeConocimiento,
    ],
  );
  // Descarga el paquete de conocimiento sin esperar: la app ya usa el de caché.
  unawaited(iniciarSincronizacionConocimiento(contenedor));
  // Carga el banco inicial antes de la primera pantalla (< 500 ms, sin red).
  await contenedor.read(bancoLocalServiceProvider).importarSemillaSiHaceFalta();
  // Inicia la escucha de conectividad y sincronización en segundo plano.
  contenedor.read(gestorSincronizacionAutoProvider);

  late final GoRouter appRouter;
  final notificaciones = contenedor.read(notificacionesServicioProvider);
  final rutaInicial = await notificaciones.inicializar(
    alAbrirRuta: (ruta) => appRouter.go(ruta),
  );
  appRouter = crearRouter(initialLocation: rutaInicial ?? '/');

  // Reconcilia el recordatorio diario según preferencias y si ya practicó hoy.
  try {
    final preferencias = await contenedor.read(
      preferenciasEstudioProvider.future,
    );
    if (preferencias != null && preferencias.onboardingCompletado) {
      final fechas = await contenedor
          .read(practicaRepositorioProvider)
          .fechasDeRespuestas();
      await notificaciones.sincronizarRecordatorioDiario(
        activo: preferencias.recordatorioActivo,
        hora: preferencias.horaEstudio,
        minuto: preferencias.minutoEstudio,
        metaDiaria: preferencias.metaDiaria,
        yaPracticoHoy: practicoHoy(fechas, ahoraLocal: DateTime.now()),
      );
    }
  } catch (_) {
    // Si falla o la base está migrando, la app abre normalmente.
  }

  runApp(
    UncontrolledProviderScope(
      container: contenedor,
      child: PrepionApp(routerConfig: appRouter),
    ),
  );
}
