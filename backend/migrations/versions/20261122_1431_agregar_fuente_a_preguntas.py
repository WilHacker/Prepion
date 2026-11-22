"""agregar fuente a preguntas

Revision ID: 6e6e0e19102d
Revises: ae50832f4aa7
Create Date: 2026-11-22 14:31:16

"""

from collections.abc import Sequence

import sqlalchemy as sa
import sqlmodel  # noqa: F401  tipos de SQLModel usados en migraciones autogeneradas
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "6e6e0e19102d"
down_revision: str | Sequence[str] | None = "ae50832f4aa7"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Upgrade schema."""
    # Nullable: las preguntas publicadas antes de esta versión no traen la cita.
    op.add_column("preguntas", sa.Column("fuente", sa.Text(), nullable=True))


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column("preguntas", "fuente")
