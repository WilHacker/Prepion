from dataclasses import dataclass


@dataclass(frozen=True)
class RespuestaObservada:
    usuario_id: str
    pregunta_id: str
    es_correcta: bool
