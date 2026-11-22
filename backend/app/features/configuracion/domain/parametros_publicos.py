from dataclasses import dataclass
from datetime import date


@dataclass(frozen=True)
class FechaTentativaExamen:
    """Fecha tentativa de examen de ingreso a la FCyT."""

    etiqueta: str
    fecha: date
    es_recomendada: bool = False


@dataclass(frozen=True)
class ParametrosPublicos:
    """Parámetros sugeridos para configurar el plan de estudio desde el onboarding."""

    fechas_tentativas_examen: tuple[FechaTentativaExamen, ...]
    metas_diarias_opciones: tuple[int, ...]
    meta_diaria_sugerida: int
    hora_estudio_sugerida: str
    min_preguntas_diarias: int
    max_preguntas_diarias: int
