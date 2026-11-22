from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Configuración leída de variables de entorno o de `.env`."""

    model_config = SettingsConfigDict(env_file=(".env", "../.env"), extra="ignore")

    database_url: str  # obligatoria: falla al arrancar si no está definida
    recoleccion_token: str | None = None  # sin token, la recolección HTTP queda apagada
    # Sin secreto JWT el login queda apagado (503). Mínimo 32 caracteres.
    jwt_secreto: str | None = None
    # Cuenta de administrador que crea `cuentas ... crear-admin` (opcionales).
    admin_correo: str | None = None
    admin_contrasena: str | None = None
    examenes_pdf_dir: Path = Path("../data/examenes_pdf")


# Los valores llegan del entorno; mypy no puede saberlo.
settings = Settings()  # type: ignore[call-arg]
