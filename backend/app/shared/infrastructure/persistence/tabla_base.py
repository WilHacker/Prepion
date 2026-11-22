import uuid
from datetime import datetime

from sqlalchemy import DateTime, func
from sqlmodel import Field, SQLModel

# Nombres estables para llaves e índices: Alembic genera migraciones predecibles.
# Debe fijarse antes de declarar cualquier tabla; por eso vive aquí.
SQLModel.metadata.naming_convention = {
    "ix": "ix_%(table_name)s_%(column_0_N_name)s",
    "uq": "uq_%(table_name)s_%(column_0_N_name)s",
    "ck": "ck_%(table_name)s_%(constraint_name)s",
    "fk": "fk_%(table_name)s_%(column_0_name)s_%(referred_table_name)s",
    "pk": "pk_%(table_name)s",
}


def marca_de_tiempo(*, al_actualizar: bool = False) -> datetime:
    kwargs: dict[str, object] = {"server_default": func.now(), "nullable": False}
    if al_actualizar:
        kwargs["onupdate"] = func.now()
    return Field(default=None, sa_type=DateTime(timezone=True), sa_column_kwargs=kwargs)  # type: ignore[no-any-return]


class ConMarcasDeTiempo(SQLModel):
    """Toda tabla lleva `creado_en` y `actualizado_en` (estándar del proyecto)."""

    creado_en: datetime = marca_de_tiempo()
    actualizado_en: datetime = marca_de_tiempo(al_actualizar=True)


class TablaBase(ConMarcasDeTiempo):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
