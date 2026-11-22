from dataclasses import dataclass
from enum import StrEnum

TEXTO_MINIMO = 200  # menos que esto por documento = escaneado (sin texto que extraer)
PROPORCION_MINIMA = 0.8  # preguntas con 5 opciones para curar sin mucho trabajo


class Veredicto(StrEnum):
    CURABLE = "curable"
    REVISAR = "revisar"
    NO_CURABLE = "no_curable"


@dataclass(frozen=True)
class Curabilidad:
    paginas: int
    preguntas: int
    con_cinco_opciones: int
    veredicto: Veredicto
    motivo: str


def evaluar(paginas: int, caracteres: int, preguntas: int, con_cinco: int) -> Curabilidad:
    """Dice si el extractor lee bien este examen (las respuestas igual se curan a mano)."""
    if caracteres < TEXTO_MINIMO:
        veredicto, motivo = Veredicto.NO_CURABLE, "PDF escaneado: no trae texto que extraer"
    elif preguntas == 0:
        veredicto, motivo = Veredicto.NO_CURABLE, "No detecta preguntas (formato distinto)"
    elif con_cinco / preguntas < PROPORCION_MINIMA:
        veredicto = Veredicto.REVISAR
        motivo = f"Solo {con_cinco}/{preguntas} preguntas con 5 opciones: revisar a mano"
    else:
        veredicto = Veredicto.CURABLE
        motivo = f"{con_cinco}/{preguntas} preguntas con 5 opciones"
    return Curabilidad(paginas, preguntas, con_cinco, veredicto, motivo)
