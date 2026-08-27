from fastapi import Header, HTTPException

from app.config import settings


def require_api_key(x_api_key: str = Header(default="")):
    if settings.api_key == "":
        return
    if x_api_key != settings.api_key:
        raise HTTPException(status_code=401, detail="API key invalida o faltante")
