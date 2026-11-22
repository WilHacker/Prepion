import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';

/// Vista principal de estudio tras completar el onboarding.
class InicioPage extends ConsumerWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencias = ref.watch(preferenciasEstudioProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Prepion',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: <Widget>[
          IconButton(
            key: const Key('boton_ir_ajustes'),
            tooltip: 'Ajustes',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => context.push('/ajustes'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    ColoresPrepion.azulMarino,
                    ColoresPrepion.azulMedio,
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    preferencias != null
                        ? 'Faltan ${preferencias.diasRestantes()} días para tu examen'
                        : 'Listo para practicar',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ColoresPrepion.ambarSuave,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    preferencias != null
                        ? 'Meta de hoy: ${preferencias.metaDiaria} preguntas'
                        : 'Empieza tu sesión diaria',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (preferencias != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      preferencias.recordatorioActivo
                          ? 'Examen: ${preferencias.fechaExamenFormateada} · Recordatorio: ${preferencias.horaEstudioFormateada}'
                          : 'Examen: ${preferencias.fechaExamenFormateada} · Recordatorio: desactivado',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('boton_practicar_hoy'),
              onPressed: () => context.push('/practica'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Practicar hoy'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key('boton_ver_banco'),
              onPressed: () => context.push('/banco'),
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('Ver banco de preguntas'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              key: const Key('boton_ver_progreso'),
              onPressed: () => context.push('/progreso'),
              icon: const Icon(Icons.insights_rounded),
              label: const Text('Mi progreso'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ColoresPrepion.superficie,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ColoresPrepion.borde),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.offline_pin_rounded,
                    color: ColoresPrepion.exito,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Tu sesión, tal como la dejaste',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ColoresPrepion.textoPrincipal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          preferencias != null
                              ? 'Tus preferencias y tu avance se guardan en tu dispositivo.'
                              : 'Configura tu meta diaria en Ajustes.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: ColoresPrepion.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
