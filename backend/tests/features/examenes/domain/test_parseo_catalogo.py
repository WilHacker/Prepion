from app.features.examenes.domain.parseo_catalogo import (
    extraer_tamano_kb,
    extraer_url_de_onclick,
    inferir_gestion_y_tipo,
)


def test_extrae_url_cuando_onclick_usa_window_location() -> None:
    onclick = "window.location='https://sagaa.fcyt.umss.edu.bo/admision/archivos/2026-2-2op.pdf'"

    assert (
        extraer_url_de_onclick(onclick)
        == "https://sagaa.fcyt.umss.edu.bo/admision/archivos/2026-2-2op.pdf"
    )


def test_devuelve_none_cuando_onclick_no_tiene_url() -> None:
    assert extraer_url_de_onclick("retornar()") is None


def test_infiere_gestion_y_tipo_para_nombres_modernos_y_antiguos() -> None:
    assert inferir_gestion_y_tipo("2026-2-2op.pdf", "Segundo Examen") == ("2-2026", "2op")
    assert inferir_gestion_y_tipo("2025-1-preu.pdf", "PREU FCyT 1-2025") == ("1-2025", "preu")
    assert inferir_gestion_y_tipo("2024-2-Uop.pdf", "Examen de Ingreso FCyT 2-2024") == (
        "2-2024",
        "unica",
    )
    assert inferir_gestion_y_tipo(
        "050_ExamenAdmisionPrimerOpcion1-2005.pdf", "Primer Examen de Ingreso FCyT 1-2005"
    ) == ("1-2005", "1op")
    assert inferir_gestion_y_tipo("056_PrimerParcialCursoPropedeutico1-2006.pdf", "") == (
        "1-2006",
        "propedeutico",
    )


def test_extrae_tamano_en_kb_cuando_esta_presente() -> None:
    assert extraer_tamano_kb("408 KB") == 408
    assert extraer_tamano_kb("sin dato") is None
