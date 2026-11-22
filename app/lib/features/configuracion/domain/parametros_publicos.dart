import 'package:prepion/features/configuracion/domain/preferencias_estudio.dart';

/// Fecha tentativa de convocatoria de ingreso a la FCyT.
class FechaTentativaExamen {
  const FechaTentativaExamen({
    required this.etiqueta,
    required this.fecha,
    required this.esRecomendada,
  });

  final String etiqueta;
  final DateTime fecha;
  final bool esRecomendada;
}

/// Parámetros públicos sugeridos para inicializar el plan de estudio.
class ParametrosPublicos {
  const ParametrosPublicos({
    required this.fechasTentativasExamen,
    required this.metasDiariasOpciones,
    required this.metaDiariaSugerida,
    required this.horaEstudioSugerida,
    required this.minPreguntasDiarias,
    required this.maxPreguntasDiarias,
  });

  /// Valores por defecto para operar 100 % offline sin depender de la API.
  factory ParametrosPublicos.porDefecto({DateTime? hoy}) {
    final referencia = hoy ?? DateTime.now();
    final soloFecha = DateTime(
      referencia.year,
      referencia.month,
      referencia.day,
    );
    final candidatas = <(String, DateTime)>[
      for (final anio in <int>[
        soloFecha.year,
        soloFecha.year + 1,
        soloFecha.year + 2,
      ]) ...<(String, DateTime)>[
        ('1.ª opción · Gestión 1-$anio', DateTime(anio, 1, 25)),
        ('2.ª opción · Gestión 1-$anio', DateTime(anio, 2, 15)),
        ('1.ª opción · Gestión 2-$anio', DateTime(anio, 7, 20)),
        ('2.ª opción · Gestión 2-$anio', DateTime(anio, 8, 10)),
      ],
    ].where((par) => par.$2.isAfter(soloFecha)).take(3).toList();

    final fechas = <FechaTentativaExamen>[
      for (var i = 0; i < candidatas.length; i++)
        FechaTentativaExamen(
          etiqueta: candidatas[i].$1,
          fecha: candidatas[i].$2,
          esRecomendada: i == 0,
        ),
    ];

    return ParametrosPublicos(
      fechasTentativasExamen: fechas,
      metasDiariasOpciones: metasDiariasDisponibles,
      metaDiariaSugerida: metaDiariaPorDefecto,
      horaEstudioSugerida: formatearHoraEstudio(
        horaEstudioPorDefecto,
        minutoEstudioPorDefecto,
      ),
      minPreguntasDiarias: 5,
      maxPreguntasDiarias: 50,
    );
  }

  /// Construye parámetros públicos desde el JSON en camelCase de FastAPI.
  factory ParametrosPublicos.desdeJson(Map<String, Object?> json) {
    final respaldo = ParametrosPublicos.porDefecto();
    final fechasRaw = json['fechasTentativasExamen'];
    final fechas = <FechaTentativaExamen>[];

    if (fechasRaw is List<Object?>) {
      for (final elemento in fechasRaw) {
        if (elemento is Map<String, Object?>) {
          final etiqueta = elemento['etiqueta'];
          final fechaTexto = elemento['fecha'];
          final esRecomendada = elemento['esRecomendada'];
          if (etiqueta is String && fechaTexto is String) {
            final fecha = DateTime.tryParse(fechaTexto);
            if (fecha != null) {
              fechas.add(
                FechaTentativaExamen(
                  etiqueta: etiqueta,
                  fecha: fecha,
                  esRecomendada: esRecomendada is bool && esRecomendada,
                ),
              );
            }
          }
        }
      }
    }

    final metasRaw = json['metasDiariasOpciones'];
    final metas = <int>[];
    if (metasRaw is List<Object?>) {
      for (final item in metasRaw) {
        if (item is int && item > 0) {
          metas.add(item);
        }
      }
    }

    final metaSugerida = json['metaDiariaSugerida'];
    final horaSugerida = json['horaEstudioSugerida'];
    final minPreguntas = json['minPreguntasDiarias'];
    final maxPreguntas = json['maxPreguntasDiarias'];

    return ParametrosPublicos(
      fechasTentativasExamen: fechas.isEmpty
          ? respaldo.fechasTentativasExamen
          : fechas,
      metasDiariasOpciones: metas.isEmpty
          ? respaldo.metasDiariasOpciones
          : metas,
      metaDiariaSugerida: metaSugerida is int
          ? metaSugerida
          : respaldo.metaDiariaSugerida,
      horaEstudioSugerida: horaSugerida is String
          ? horaSugerida
          : respaldo.horaEstudioSugerida,
      minPreguntasDiarias: minPreguntas is int
          ? minPreguntas
          : respaldo.minPreguntasDiarias,
      maxPreguntasDiarias: maxPreguntas is int
          ? maxPreguntas
          : respaldo.maxPreguntasDiarias,
    );
  }

  final List<FechaTentativaExamen> fechasTentativasExamen;
  final List<int> metasDiariasOpciones;
  final int metaDiariaSugerida;
  final String horaEstudioSugerida;
  final int minPreguntasDiarias;
  final int maxPreguntasDiarias;

  DateTime get fechaExamenRecomendada {
    for (final item in fechasTentativasExamen) {
      if (item.esRecomendada) {
        return item.fecha;
      }
    }
    if (fechasTentativasExamen.isNotEmpty) {
      return fechasTentativasExamen.first.fecha;
    }
    return DateTime.now().add(const Duration(days: 60));
  }

  (int, int) get horaEstudioRecomendada {
    final partes = horaEstudioSugerida.split(':');
    if (partes.length == 2) {
      final hora = int.tryParse(partes[0]);
      final minuto = int.tryParse(partes[1]);
      if (hora != null && minuto != null) {
        return (hora.clamp(0, 23), minuto.clamp(0, 59));
      }
    }
    return (horaEstudioPorDefecto, minutoEstudioPorDefecto);
  }
}
