from fastapi import FastAPI
from contextlib import asynccontextmanager

from eventual_backend.core.config import settings
from eventual_backend.routers.api import api_router
from eventual_backend.core.database import engine, Base


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Create tables
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    # Shutdown: Close connections
    await engine.dispose()


app = FastAPI(title=settings.PROJECT_NAME, openapi_url=f"{settings.API_V1_STR}/openapi.json", lifespan=lifespan)

app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/")
async def root():
    return {"message": "Task Management API"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
