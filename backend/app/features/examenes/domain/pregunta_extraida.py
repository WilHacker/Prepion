from dataclasses import dataclass

# La letra del código dice a qué materia pertenece la pregunta (A5, G7, F11, Q16, B18).
MATERIA_POR_LETRA = {
    "A": "Aritmética-Álgebra",
    "G": "Geometría-Trigonometría",
    "F": "Física",
    "Q": "Química",
    "B": "Biología",
}


@dataclass(frozen=True)
class PreguntaExtraida:
    """Pregunta tal como sale del PDF, antes de la curación humana."""

    serie: int
    codigo: str  # A5, G7, F11… (se repite entre series del mismo examen)
    pagina: int
    enunciado: str
    opciones: tuple[str, ...]
    requiere_imagen: bool
    ruta_imagen: str | None = None
    duplicada_de: str | None = None  # código completo de la primera aparición

    @property
    def codigo_completo(self) -> str:
        """Identifica la pregunta dentro del examen: S1-A5."""
        return f"S{self.serie}-{self.codigo}"

    @property
    def materia(self) -> str:
        return MATERIA_POR_LETRA.get(self.codigo[0], "Sin materia")
