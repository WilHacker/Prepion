"""Parámetros calibrados de Bayesian Knowledge Tracing (BKT) por tema."""

from dataclasses import dataclass


@dataclass(frozen=True)
class ParametrosBkt:
    tema_id: str
    p_inicial: float = 0.3
    p_aprendizaje: float = 0.1
    p_adivinar: float = 0.2
    p_error: float = 0.1
