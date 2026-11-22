from typing import Any

import pytest

from app.features.conocimiento.application.recalibrar_conocimiento import recalibrar_conocimiento
from app.features.conocimiento.domain.errores import SinBancoPublicadoError
from app.features.conocimiento.domain.respuesta_observada import RespuestaObservada

PREGUNTAS = [f"p{i}" for i in range(6)]
BANCO = {"preguntas": [{"id": p, "temaId": f"t{i % 2}"} for i, p in enumerate(PREGUNTAS)]}


class _Banco:
    def __init__(self, contenido: dict[str, Any] | None) -> None:
        self._contenido = contenido

    def obtener_ultimo(self) -> dict[str, Any] | None:
        return self._contenido


class _Reales:
    def __init__(self, respuestas: list[RespuestaObservada]) -> None:
        self._respuestas = respuestas

    def listar(self) -> list[RespuestaObservada]:
        return self._respuestas


class _Paquetes:
    def __init__(self, ultima: int = 0) -> None:
        self.ultima = ultima
        self.guardados: list[tuple[int, dict[str, Any]]] = []

    def obtener_actual(self) -> dict[str, Any] | None:
        return None

    def ultima_version(self) -> int:
        return self.ultima

    def guardar(self, version: int, contenido: dict[str, Any]) -> None:
        self.guardados.append((version, contenido))


def _reales(usuarios: int) -> list[RespuestaObservada]:
    # Cada pregunta p_i la aciertan los usuarios con (índice mod 8) > i: dificultades distintas.
    return [
        RespuestaObservada(f"u{j}", p, j % 8 > i)
        for j in range(usuarios)
        for i, p in enumerate(PREGUNTAS)
    ]


def test_con_20_usuarios_reales_el_origen_es_real() -> None:
    paquetes = _Paquetes()

    resumen = recalibrar_conocimiento(_Banco(BANCO), _Reales(_reales(20)), paquetes)

    assert (resumen.origen, resumen.usuarios, resumen.preguntas, resumen.temas) == (
        "real",
        20,
        6,
        2,
    )
    assert paquetes.guardados[0][1]["origen"] == "real"


def test_con_19_usuarios_reales_simula() -> None:
    resumen = recalibrar_conocimiento(_Banco(BANCO), _Reales(_reales(19)), _Paquetes())

    assert (resumen.origen, resumen.usuarios) == ("simulado", 60)


def test_si_la_calibracion_real_falla_cae_a_simulado() -> None:
    todos_aciertan = [RespuestaObservada(f"u{j}", p, True) for j in range(25) for p in PREGUNTAS]

    resumen = recalibrar_conocimiento(_Banco(BANCO), _Reales(todos_aciertan), _Paquetes())

    assert resumen.origen == "simulado"


def test_ignora_respuestas_de_preguntas_fuera_del_banco() -> None:
    ajenas = [RespuestaObservada(f"u{j}", "otra", j % 2 == 0) for j in range(30)]

    resumen = recalibrar_conocimiento(_Banco(BANCO), _Reales(ajenas), _Paquetes())

    assert resumen.origen == "simulado"


def test_guarda_como_version_ultima_mas_uno() -> None:
    paquetes = _Paquetes(ultima=4)

    resumen = recalibrar_conocimiento(_Banco(BANCO), _Reales([]), paquetes)

    assert resumen.version == 5
    assert paquetes.guardados[0][0] == 5


def test_sin_banco_publicado_falla_con_conflicto() -> None:
    paquetes = _Paquetes()

    with pytest.raises(SinBancoPublicadoError, match="banco de preguntas publicado"):
        recalibrar_conocimiento(_Banco(None), _Reales([]), paquetes)

    assert paquetes.guardados == []
