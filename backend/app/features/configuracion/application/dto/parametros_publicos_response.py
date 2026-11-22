from datetime import date

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel

from app.features.configuracion.domain.parametros_publicos import ParametrosPublicos


class FechaTentativaExamenResponse(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    etiqueta: str
    fecha: date
    es_recomendada: bool


class ParametrosPublicosResponse(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    fechas_tentativas_examen: list[FechaTentativaExamenResponse]
    metas_diarias_opciones: list[int]
    meta_diaria_sugerida: int
    hora_estudio_sugerida: str
    min_preguntas_diarias: int
    max_preguntas_diarias: int

    @classmethod
    def desde_dominio(cls, parametros: ParametrosPublicos) -> "ParametrosPublicosResponse":
        return cls(
            fechas_tentativas_examen=[
                FechaTentativaExamenResponse(
                    etiqueta=item.etiqueta,
                    fecha=item.fecha,
                    es_recomendada=item.es_recomendada,
                )
                for item in parametros.fechas_tentativas_examen
            ],
            metas_diarias_opciones=list(parametros.metas_diarias_opciones),
            meta_diaria_sugerida=parametros.meta_diaria_sugerida,
            hora_estudio_sugerida=parametros.hora_estudio_sugerida,
            min_preguntas_diarias=parametros.min_preguntas_diarias,
            max_preguntas_diarias=parametros.max_preguntas_diarias,
        )
