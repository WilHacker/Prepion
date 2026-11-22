from fastapi import APIRouter

router = APIRouter(prefix="/health", tags=["health"])


@router.get("")
def obtener_estado() -> dict[str, str]:
    return {"estado": "ok"}
