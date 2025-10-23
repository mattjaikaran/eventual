from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime
import uuid
from enum import Enum

from eventual_backend.models.task import TaskStatus


class TaskStatusEnum(str, Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    DONE = "done"


class TaskBase(BaseModel):
    title: str
    status: TaskStatusEnum = TaskStatusEnum.PENDING
    due_date: datetime
    idempotency_key: Optional[str] = None
    user_id: uuid.UUID


class TaskCreate(TaskBase):
    pass


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    status: Optional[TaskStatusEnum] = None
    due_date: Optional[datetime] = None
    idempotency_key: Optional[str] = None


class TaskInDB(TaskBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID
    created_at: datetime
    updated_at: datetime


class TaskResponse(TaskInDB):
    pass


class TaskSummary(BaseModel):
    pending: int
    in_progress: int
    done: int
