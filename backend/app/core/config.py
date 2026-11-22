from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Configuración leída de variables de entorno o de `.env`."""

    model_config = SettingsConfigDict(env_file=(".env", "../.env"), extra="ignore")

    database_url: str  # obligatoria: falla al arrancar si no está definida


# Los valores llegan del entorno; mypy no puede saberlo.
settings = Settings()  # type: ignore[call-arg]
