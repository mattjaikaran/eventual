from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from eventual_backend.models.task import Task, TaskStatus
from eventual_backend.repositories.task_repository import TaskRepository
from eventual_backend.schemas.task_schema import TaskCreate, TaskStatusEnum, TaskSummary, TaskUpdate


class TaskService:
    def __init__(self, db: AsyncSession):
        self.repository = TaskRepository(db)

    def _prepare_task_data(self, data: dict) -> dict:
        """Prepare task data for database operations by converting enums and datetimes"""
        # Convert TaskStatusEnum to TaskStatus
        if "status" in data and data["status"] is not None:
            data["status"] = TaskStatus(data["status"])

        # Convert timezone-aware datetime to naive datetime (UTC)
        if (
            "due_date" in data
            and data["due_date"] is not None
            and hasattr(data["due_date"], "tzinfo")
            and data["due_date"].tzinfo is not None
        ):
            data["due_date"] = data["due_date"].replace(tzinfo=None)

        return data

    async def get_task(self, task_id: UUID) -> Task | None:
        return await self.repository.get(task_id)

    async def get_tasks(
        self,
        status: TaskStatusEnum | None = None,
        user_id: UUID | None = None,
        order_by: str = "due_date_asc",
        skip: int = 0,
        limit: int = 100,
    ) -> list[Task]:
        # Convert TaskStatusEnum to TaskStatus if provided
        db_status = None
        if status is not None:
            db_status = TaskStatus(status.value)

        return await self.repository.get_with_filters(
            status=db_status, user_id=user_id, order_by=order_by, skip=skip, limit=limit
        )

    async def create_task(self, task_create: TaskCreate) -> Task:
        # Check for idempotency key
        if task_create.idempotency_key:
            existing_task = await self.repository.get_by_idempotency_key(task_create.idempotency_key)
            if existing_task:
                return existing_task

        task_data = task_create.model_dump()
        task_data = self._prepare_task_data(task_data)
        return await self.repository.create(task_data)

    async def update_task(self, task_id: UUID, task_update: TaskUpdate) -> Task | None:
        task = await self.repository.get(task_id)
        if not task:
            return None
        update_data = task_update.model_dump(exclude_unset=True)
        update_data = self._prepare_task_data(update_data)
        return await self.repository.update(task, update_data)

    async def delete_task(self, task_id: UUID) -> bool:
        return await self.repository.delete(task_id)

    async def get_user_tasks(self, user_id: UUID, skip: int = 0, limit: int = 100) -> list[Task]:
        return await self.repository.get_by_user_id(user_id, skip, limit)

    async def get_task_summary(self) -> TaskSummary:
        summary_data = await self.repository.get_task_summary()
        return TaskSummary(**summary_data)
