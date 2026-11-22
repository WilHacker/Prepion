"""agregar comentario a tabla reportes

Revision ID: b6cd9d4a1c4f
Revises: 6e6e0e19102d
Create Date: 2026-11-22 15:40:21.358591

"""

from collections.abc import Sequence

import sqlalchemy as sa
import sqlmodel  # noqa: F401  tipos de SQLModel usados en migraciones autogeneradas
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "b6cd9d4a1c4f"
down_revision: str | Sequence[str] | None = "6e6e0e19102d"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    """Upgrade schema."""
    op.add_column("reportes", sa.Column("comentario", sa.String(length=1000), nullable=True))


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_column("reportes", "comentario")
