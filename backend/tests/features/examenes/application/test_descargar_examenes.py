from pathlib import Path

from app.features.examenes.application.descargar_examenes import (
    descargar_examenes,
    filtrar_examenes,
)
from app.features.examenes.domain.examen_remoto import ExamenRemoto


class _CatalogoFalso:
    def __init__(self, examenes: list[ExamenRemoto]) -> None:
        self._examenes = examenes
        self.descargados: list[str] = []

    def listar_examenes(self, url_catalogo: str) -> list[ExamenRemoto]:
        return list(self._examenes)

    def descargar_pdf(self, examen: ExamenRemoto, destino: Path) -> Path:
        destino.write_bytes(b"%PDF-1.4\nprueba")
        self.descargados.append(examen.archivo)
        return destino


_EXAMENES = [
    ExamenRemoto("2025-2-1op.pdf", "Primer 2-2025", "2-2025", "1op", "https://ex/1.pdf", 200),
    ExamenRemoto("2026-2-1op.pdf", "Primer 2-2026", "2-2026", "1op", "https://ex/2.pdf", 300),
    ExamenRemoto("2026-2-2op.pdf", "Segundo 2-2026", "2-2026", "2op", "https://ex/3.pdf", 400),
]


def test_filtra_por_gestion_tipo_y_limite() -> None:
    assert [e.archivo for e in filtrar_examenes(_EXAMENES, gestion="2-2026")] == [
        "2026-2-1op.pdf",
        "2026-2-2op.pdf",
    ]
    assert [e.archivo for e in filtrar_examenes(_EXAMENES, tipo="1op")] == [
        "2025-2-1op.pdf",
        "2026-2-1op.pdf",
    ]
    assert [e.archivo for e in filtrar_examenes(_EXAMENES, limite=1)] == ["2026-2-2op.pdf"]


def test_omite_archivos_existentes_salvo_que_se_sobrescriba(tmp_path: Path) -> None:
    catalogo = _CatalogoFalso(_EXAMENES)
    (tmp_path / "2026-2-1op.pdf").write_bytes(b"%PDF-existente")

    rutas = descargar_examenes(catalogo, tmp_path, gestion="2-2026")
    assert [r.name for r in rutas] == ["2026-2-2op.pdf"]

    rutas_sobrescritas = descargar_examenes(catalogo, tmp_path, gestion="2-2026", sobrescribir=True)
    assert [r.name for r in rutas_sobrescritas] == ["2026-2-1op.pdf", "2026-2-2op.pdf"]
