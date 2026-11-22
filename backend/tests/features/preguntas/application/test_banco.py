from datetime import UTC, datetime
from typing import Any

import pytest

from app.features.preguntas.application.consultar_banco import (
    descargar_banco,
    obtener_banco_actual,
)
from app.features.preguntas.application.publicar_banco import publicar_banco
from app.features.preguntas.domain.banco import BancoVersion
from app.features.preguntas.domain.errores import (
    BancoNoEncontradoError,
    BancoPublicadoInvalidoError,
    BancoYaPublicadoError,
)

AHORA = datetime(2026, 11, 22, 12, 0, tzinfo=UTC)


class RepositorioEnMemoria:
    def __init__(self) -> None:
        self.versiones: dict[int, tuple[BancoVersion, dict[str, Any]]] = {}

    def obtener_actual(self) -> BancoVersion | None:
        if not self.versiones:
            return None
        return self.versiones[max(self.versiones)][0]

    def obtener_contenido(self, version: int) -> dict[str, Any] | None:
        entrada = self.versiones.get(version)
        return entrada[1] if entrada else None

    def existe_version(self, version: int) -> bool:
        return version in self.versiones

    def guardar(self, version: int, cantidad: int, contenido: dict[str, Any]) -> None:
        self.versiones[version] = (BancoVersion(version, cantidad, AHORA), contenido)


def _banco(version: int = 1, preguntas: int = 2) -> dict[str, Any]:
    return {"version": version, "preguntas": [{"id": str(i)} for i in range(preguntas)]}


def test_publica_un_banco_y_lo_deja_como_el_actual():
    repo = RepositorioEnMemoria()

    publicar_banco(repo, _banco(version=3, preguntas=2))

    assert obtener_banco_actual(repo) == BancoVersion(3, 2, AHORA)


def test_el_actual_es_la_version_mas_alta():
    repo = RepositorioEnMemoria()
    publicar_banco(repo, _banco(version=1))
    publicar_banco(repo, _banco(version=2, preguntas=5))

    assert obtener_banco_actual(repo).version == 2


def test_descarga_el_contenido_exacto_de_una_version():
    repo = RepositorioEnMemoria()
    banco = _banco(version=2)
    publicar_banco(repo, banco)

    assert descargar_banco(repo, 2) == banco


def test_falla_cuando_todavia_no_hay_ningun_banco():
    with pytest.raises(BancoNoEncontradoError, match="Todavía no hay"):
        obtener_banco_actual(RepositorioEnMemoria())


def test_falla_cuando_la_version_pedida_no_existe():
    with pytest.raises(BancoNoEncontradoError, match="versión 9"):
        descargar_banco(RepositorioEnMemoria(), 9)


def test_no_pisa_una_version_ya_publicada():
    repo = RepositorioEnMemoria()
    publicar_banco(repo, _banco(version=1))

    with pytest.raises(BancoYaPublicadoError):
        publicar_banco(repo, _banco(version=1))


@pytest.mark.parametrize(
    "contenido",
    [
        {"preguntas": [{"id": "1"}]},
        {"version": "uno", "preguntas": [{"id": "1"}]},
        {"version": 0, "preguntas": [{"id": "1"}]},
        {"version": 1},
        {"version": 1, "preguntas": []},
    ],
)
def test_rechaza_un_banco_sin_version_valida_o_sin_preguntas(contenido: dict[str, Any]):
    with pytest.raises(BancoPublicadoInvalidoError):
        publicar_banco(RepositorioEnMemoria(), contenido)
