from datetime import datetime

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel


class BancoActualResponse(BaseModel):
    """JSON en camelCase: { version, cantidad, publicadaEn }."""

    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)

    version: int
    cantidad: int
    publicada_en: datetime
