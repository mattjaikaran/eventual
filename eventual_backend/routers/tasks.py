from typing import List, Optional
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status, Query

from eventual_backend.services.task_service import TaskService
from eventual_backend.services.user_service import UserService
from eventual_backend.schemas.task_schema import TaskCreate, TaskUpdate, TaskResponse, TaskSummary, TaskStatusEnum
from eventual_backend.api.dependencies import get_task_service, get_user_service

router = APIRouter()


@router.get("/", response_model=List[TaskResponse])
async def list_tasks(
    status: Optional[TaskStatusEnum] = Query(None),
    user_id: Optional[UUID] = Query(None),
    order_by: str = Query("due_date_asc", pattern="^(due_date_asc|due_date_desc)$"),
    skip: int = 0,
    limit: int = 100,
    task_service: TaskService = Depends(get_task_service),
):
    return await task_service.get_tasks(status=status, user_id=user_id, order_by=order_by, skip=skip, limit=limit)


@router.post("/", response_model=TaskResponse, status_code=status.HTTP_201_CREATED)
async def create_task(
    task_create: TaskCreate,
    task_service: TaskService = Depends(get_task_service),
    user_service: UserService = Depends(get_user_service),
):
    # Verify user exists
    user = await user_service.get_user(task_create.user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    return await task_service.create_task(task_create)


@router.get("/{task_id}", response_model=TaskResponse)
async def get_task(task_id: UUID, task_service: TaskService = Depends(get_task_service)):
    task = await task_service.get_task(task_id)
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    return task


@router.put("/{task_id}", response_model=TaskResponse)
async def update_task(task_id: UUID, task_update: TaskUpdate, task_service: TaskService = Depends(get_task_service)):
    task = await task_service.update_task(task_id, task_update)
    if not task:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")
    return task


@router.delete("/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_task(task_id: UUID, task_service: TaskService = Depends(get_task_service)):
    success = await task_service.delete_task(task_id)
    if not success:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Task not found")


@router.get("/user/{user_id}", response_model=List[TaskResponse])
async def get_user_tasks(
    user_id: UUID,
    skip: int = 0,
    limit: int = 100,
    task_service: TaskService = Depends(get_task_service),
    user_service: UserService = Depends(get_user_service),
):
    # Verify user exists
    user = await user_service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    return await task_service.get_user_tasks(user_id, skip=skip, limit=limit)


@router.get("/summary/", response_model=TaskSummary)
async def get_task_summary(task_service: TaskService = Depends(get_task_service)):
    return await task_service.get_task_summary()
