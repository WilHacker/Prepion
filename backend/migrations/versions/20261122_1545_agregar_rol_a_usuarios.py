"""agregar rol a usuarios

Revision ID: 3b7c1d9e4a52
Revises: b6cd9d4a1c4f
Create Date: 2026-11-22 15:45:00

"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "3b7c1d9e4a52"
down_revision: str | Sequence[str] | None = "b6cd9d4a1c4f"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Upgrade schema."""
    # Los usuarios existentes (anónimos) quedan como postulantes.
    op.add_column(
        "usuarios",
        sa.Column("rol", sa.String(length=10), nullable=False, server_default="usuario"),
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column("usuarios", "rol")
