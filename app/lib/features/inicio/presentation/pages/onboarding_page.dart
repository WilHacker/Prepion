import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';
import 'package:prepion/features/configuracion/domain/parametros_publicos.dart';
import 'package:prepion/features/configuracion/presentation/providers/preferencias_provider.dart';
import 'package:prepion/features/configuracion/presentation/widgets/selector_metas_card.dart';

class _DiapositivaOnboarding {
  const _DiapositivaOnboarding({
    required this.etiqueta,
    required this.titulo,
    required this.descripcion,
    required this.icono,
  });

  final String etiqueta;
  final String titulo;
  final String descripcion;
  final IconData icono;
}

const List<_DiapositivaOnboarding> _diapositivas = <_DiapositivaOnboarding>[
  _DiapositivaOnboarding(
    etiqueta: 'ENFOQUE FCyT',
    titulo: 'Exámenes reales de admisión',
    descripcion: 'Practica con preguntas oficiales de la FCyT verificadas y con explicación paso a paso.',
    icono: Icons.school_rounded,
  ),
  _DiapositivaOnboarding(
    etiqueta: 'PRÁCTICA INTELIGENTE',
    titulo: 'Refuerza lo que más importa',
    descripcion: 'Sesiones breves con repetición espaciada para retener fórmulas y conceptos clave hasta el examen.',
    icono: Icons.auto_graph_rounded,
  ),
  _DiapositivaOnboarding(
    etiqueta: '100 % OFFLINE',
    titulo: 'Estudia sin internet ni formularios',
    descripcion: 'Sin registros obligatorios, sin anuncios y siempre disponible aunque no tengas señal.',
    icono: Icons.offline_bolt_rounded,
  ),
];

/// Pantalla inicial de bienvenida, configuración rápida de metas y acceso anónimo.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _paginaActual = 0;
  DateTime? _fechaExamen;
  int? _metaDiaria;
  TimeOfDay? _horaEstudio;
  bool _enviando = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _aplicarValoresIniciales(ParametrosPublicos parametros) {
    if (_fechaExamen != null) {
      return;
    }
    final (hora, minuto) = parametros.horaEstudioRecomendada;
    _fechaExamen = parametros.fechaExamenRecomendada;
    _metaDiaria = parametros.metaDiariaSugerida;
    _horaEstudio = TimeOfDay(hour: hora, minute: minuto);
  }

  Future<void> _empezarAhora(ParametrosPublicos parametros) async {
    if (_enviando) {
      return;
    }
    _aplicarValoresIniciales(parametros);
    setState(() => _enviando = true);
    try {
      await ref
          .read(preferenciasEstudioProvider.notifier)
          .completarOnboarding(
            fechaExamen: _fechaExamen!,
            metaDiaria: _metaDiaria!,
            horaEstudio: _horaEstudio!.hour,
            minutoEstudio: _horaEstudio!.minute,
          );
      if (mounted) {
        context.go('/inicio');
      }
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parametros =
        ref.watch(parametrosPublicosProvider).asData?.value ??
        ParametrosPublicos.porDefecto();
    _aplicarValoresIniciales(parametros);

    final fecha = _fechaExamen ?? parametros.fechaExamenRecomendada;
    final meta = _metaDiaria ?? parametros.metaDiariaSugerida;
    final (horaDef, minDef) = parametros.horaEstudioRecomendada;
    final hora = _horaEstudio ?? TimeOfDay(hour: horaDef, minute: minDef);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Row(
                    children: <Widget>[
                      Icon(
                        Icons.bolt_rounded,
                        color: ColoresPrepion.ambar,
                        size: 26,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Prepion',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: ColoresPrepion.azulMarino,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColoresPrepion.ambarSuave,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'FCyT · UMSS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ColoresPrepion.ambar,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 216,
                child: PageView.builder(
                  key: const Key('carrusel_onboarding'),
                  controller: _pageController,
                  padEnds: false,
                  itemCount: _diapositivas.length,
                  onPageChanged: (indice) {
                    setState(() => _paginaActual = indice);
                  },
                  itemBuilder: (context, indice) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _TarjetaCarrusel(
                        diapositiva: _diapositivas[indice],
                        paso: indice + 1,
                        total: _diapositivas.length,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        key: const Key('boton_slide_anterior'),
                        tooltip: 'Diapositiva anterior',
                        visualDensity: VisualDensity.compact,
                        onPressed: _paginaActual > 0
                            ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOut,
                              )
                            : null,
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      for (var i = 0; i < _diapositivas.length; i++)
                        GestureDetector(
                          key: Key('indicador_slide_$i'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _pageController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOut,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _paginaActual == i ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _paginaActual == i
                                    ? ColoresPrepion.azulMarino
                                    : ColoresPrepion.borde,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      IconButton(
                        key: const Key('boton_slide_siguiente'),
                        tooltip: 'Siguiente diapositiva',
                        visualDensity: VisualDensity.compact,
                        onPressed: _paginaActual < _diapositivas.length - 1
                            ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 240),
                                curve: Curves.easeOut,
                              )
                            : null,
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SelectorMetasCard(
                fechaExamen: fecha,
                metaDiaria: meta,
                horaEstudio: hora,
                opcionesMeta: parametros.metasDiariasOpciones,
                fechasSugeridas: parametros.fechasTentativasExamen,
                onCambiarFecha: (nueva) => setState(() => _fechaExamen = nueva),
                onCambiarMeta: (nueva) => setState(() => _metaDiaria = nueva),
                onCambiarHora: (nueva) => setState(() => _horaEstudio = nueva),
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('boton_empezar_practicar'),
                onPressed: _enviando ? null : () => _empezarAhora(parametros),
                child: Text(
                  _enviando
                      ? 'Preparando tu plan...'
                      : 'Empezar a practicar ahora',
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  key: const Key('boton_ya_tengo_cuenta'),
                  onPressed: _enviando
                      ? null
                      : () => context.push('/iniciar-sesion'),
                  child: const Text('Ya tengo cuenta / Iniciar sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaCarrusel extends StatelessWidget {
  const _TarjetaCarrusel({
    required this.diapositiva,
    required this.paso,
    required this.total,
  });

  final _DiapositivaOnboarding diapositiva;
  final int paso;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[ColoresPrepion.azulMarino, ColoresPrepion.azulMedio],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      diapositiva.icono,
                      color: ColoresPrepion.ambarSuave,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      diapositiva.etiqueta,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: ColoresPrepion.ambarSuave,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$paso/$total',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                diapositiva.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                diapositiva.descripcion,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
