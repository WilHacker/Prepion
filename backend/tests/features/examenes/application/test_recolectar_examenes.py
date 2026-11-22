from pathlib import Path

from app.features.examenes.application.recolectar_examenes import recolectar_examenes
from app.features.examenes.domain.examen_publicado import ExamenPublicado


def _ex(nombre: str) -> ExamenPublicado:
    return ExamenPublicado(titulo=nombre, archivo=nombre, url=f"u/{nombre}", tamano="1 KB")


class _PortalFalso:
    def __init__(self, nombres: list[str], fallan: set[str] | None = None) -> None:
        self.catalogo = [_ex(n) for n in nombres]
        self.fallan = fallan or set()
        self.pedidos: list[str] = []

    def descargar_catalogo(self) -> list[ExamenPublicado]:
        return self.catalogo

    def descargar_pdf(self, examen: ExamenPublicado) -> bytes:
        self.pedidos.append(examen.archivo)
        if examen.archivo in self.fallan:
            raise RuntimeError("roto")
        return b"%PDF-" + examen.archivo.encode()


def test_descarga_solo_los_nuevos_empezando_por_los_mas_recientes(tmp_path: Path):
    # Arrange
    (tmp_path / "a.pdf").write_bytes(b"%PDF-viejo")
    portal = _PortalFalso(["a.pdf", "b.pdf", "c.pdf"])

    # Act
    r = recolectar_examenes(portal, tmp_path, 10, esperar=lambda _: None)

    # Assert
    assert (r.encontrados, r.ya_descargados) == (3, 1)
    assert r.nuevos == ["c.pdf", "b.pdf"]
    assert r.descargados == ["c.pdf", "b.pdf"]
    assert r.pendientes == 0
    assert portal.pedidos == ["c.pdf", "b.pdf"]


def test_respeta_el_limite_y_deja_el_resto_pendiente(tmp_path: Path):
    portal = _PortalFalso(["a.pdf", "b.pdf", "c.pdf"])
    r = recolectar_examenes(portal, tmp_path, 1, esperar=lambda _: None)
    assert r.descargados == ["c.pdf"]
    assert r.pendientes == 2
    assert not (tmp_path / "a.pdf").exists()


def test_nunca_sobrescribe_un_archivo_existente(tmp_path: Path):
    (tmp_path / "a.pdf").write_bytes(b"%PDF-original")
    recolectar_examenes(_PortalFalso(["a.pdf"]), tmp_path, 5, esperar=lambda _: None)
    assert (tmp_path / "a.pdf").read_bytes() == b"%PDF-original"


def test_un_error_no_detiene_los_demas_ni_deja_archivos_parciales(tmp_path: Path):
    portal = _PortalFalso(["a.pdf", "b.pdf", "c.pdf"], fallan={"b.pdf"})
    r = recolectar_examenes(portal, tmp_path, 10, esperar=lambda _: None)
    assert r.descargados == ["c.pdf", "a.pdf"]
    assert r.errores == [{"archivo": "b.pdf", "motivo": "roto"}]
    assert r.pendientes == 1
    assert sorted(p.name for p in tmp_path.iterdir()) == ["a.pdf", "c.pdf"]


def test_hace_una_pausa_de_un_segundo_entre_descargas_sin_esperar_de_verdad(tmp_path: Path):
    pausas: list[float] = []
    recolectar_examenes(_PortalFalso(["a.pdf", "b.pdf", "c.pdf"]), tmp_path, 10, pausas.append)
    assert pausas == [1.0, 1.0]


def test_crea_la_carpeta_si_no_existe(tmp_path: Path):
    destino = tmp_path / "nueva" / "pdf"
    recolectar_examenes(_PortalFalso(["a.pdf"]), destino, 1, esperar=lambda _: None)
    assert (destino / "a.pdf").is_file()
