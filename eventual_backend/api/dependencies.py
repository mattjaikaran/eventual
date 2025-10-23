from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from eventual_backend.core.database import get_db
from eventual_backend.services.user_service import UserService
from eventual_backend.services.task_service import TaskService


def get_user_service(db: AsyncSession = Depends(get_db)) -> UserService:
    return UserService(db)


def get_task_service(db: AsyncSession = Depends(get_db)) -> TaskService:
    return TaskService(db)
