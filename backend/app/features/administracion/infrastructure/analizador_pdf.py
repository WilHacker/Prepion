import tempfile
from pathlib import Path

import pymupdf

from app.features.administracion.domain.curabilidad import Curabilidad, Veredicto, evaluar
from app.features.examenes.infrastructure.adapters.extractor_pdf import extraer_preguntas

OPCIONES_POR_PREGUNTA = 5
_cache: dict[tuple[str, int], Curabilidad] = {}


def analizar_pdf(ruta: Path) -> Curabilidad:
    """Pasa el extractor por el PDF (sin guardar nada) y evalúa si se puede curar."""
    clave = (ruta.name, ruta.stat().st_mtime_ns)
    if clave in _cache:
        return _cache[clave]
    try:
        with pymupdf.open(ruta) as documento:  # type: ignore[no-untyped-call]
            paginas = len(documento)
            caracteres = sum(len(p.get_text()) for p in documento)
        with tempfile.TemporaryDirectory() as temporal:
            preguntas = extraer_preguntas(ruta, Path(temporal))
        con_cinco = sum(1 for p in preguntas if len(p.opciones) == OPCIONES_POR_PREGUNTA)
        resultado = evaluar(paginas, caracteres, len(preguntas), con_cinco)
    except Exception:  # noqa: BLE001 - un PDF dañado no debe tumbar el listado
        resultado = Curabilidad(0, 0, 0, Veredicto.NO_CURABLE, "No se pudo leer el PDF")
    _cache[clave] = resultado
    return resultado
