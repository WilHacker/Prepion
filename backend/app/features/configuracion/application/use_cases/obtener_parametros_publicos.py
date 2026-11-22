from datetime import date

from app.features.configuracion.domain.parametros_publicos import (
    FechaTentativaExamen,
    ParametrosPublicos,
)

METAS_DIARIAS_OPCIONES: tuple[int, ...] = (5, 10, 20)
META_DIARIA_SUGERIDA = 10
HORA_ESTUDIO_SUGERIDA = "19:00"
MIN_PREGUNTAS_DIARIAS = 5
MAX_PREGUNTAS_DIARIAS = 50
CANTIDAD_FECHAS_TENTATIVAS = 3


def _generar_calendario_fcyt(anio_inicio: int) -> list[tuple[str, date]]:
    """Genera convocatorias tentativas semestrales de admisión FCyT (UMSS)."""
    convocatorias: list[tuple[str, date]] = []
    for anio in (anio_inicio, anio_inicio + 1, anio_inicio + 2):
        convocatorias.extend(
            [
                (f"1.ª opción · Gestión 1-{anio}", date(anio, 1, 25)),
                (f"2.ª opción · Gestión 1-{anio}", date(anio, 2, 15)),
                (f"1.ª opción · Gestión 2-{anio}", date(anio, 7, 20)),
                (f"2.ª opción · Gestión 2-{anio}", date(anio, 8, 10)),
            ]
        )
    return convocatorias


class ObtenerParametrosPublicos:
    """Devuelve fechas tentativas de admisión y metas sugeridas para el onboarding."""

    def ejecutar(self, hoy: date | None = None) -> ParametrosPublicos:
        referencia = hoy or date.today()
        candidatas = [
            (etiqueta, fecha)
            for etiqueta, fecha in _generar_calendario_fcyt(referencia.year)
            if fecha > referencia
        ][:CANTIDAD_FECHAS_TENTATIVAS]

        fechas = tuple(
            FechaTentativaExamen(
                etiqueta=etiqueta,
                fecha=fecha,
                es_recomendada=(indice == 0),
            )
            for indice, (etiqueta, fecha) in enumerate(candidatas)
        )

        return ParametrosPublicos(
            fechas_tentativas_examen=fechas,
            metas_diarias_opciones=METAS_DIARIAS_OPCIONES,
            meta_diaria_sugerida=META_DIARIA_SUGERIDA,
            hora_estudio_sugerida=HORA_ESTUDIO_SUGERIDA,
            min_preguntas_diarias=MIN_PREGUNTAS_DIARIAS,
            max_preguntas_diarias=MAX_PREGUNTAS_DIARIAS,
        )
