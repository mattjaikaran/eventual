import os
from typing import Optional
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    model_config = {"case_sensitive": True}
    
    PROJECT_NAME: str = "Task Management API"
    API_V1_STR: str = "/api"
    
    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql+asyncpg://postgres@localhost/taskdb")
    
    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-here")


settings = Settings()
