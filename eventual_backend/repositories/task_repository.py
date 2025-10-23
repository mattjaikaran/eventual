from typing import List, Optional
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import desc, asc

from eventual_backend.models.task import Task, TaskStatus
from eventual_backend.repositories.base import BaseRepository


class TaskRepository(BaseRepository[Task]):
    def __init__(self, db: AsyncSession):
        super().__init__(Task, db)

    async def get_by_idempotency_key(self, key: str) -> Optional[Task]:
        result = await self.db.execute(select(Task).where(Task.idempotency_key == key))
        return result.scalar_one_or_none()

    async def get_by_user_id(self, user_id: UUID, skip: int = 0, limit: int = 100) -> List[Task]:
        result = await self.db.execute(select(Task).where(Task.user_id == user_id).offset(skip).limit(limit))
        return result.scalars().all()

    async def get_with_filters(
        self,
        status: Optional[TaskStatus] = None,
        user_id: Optional[UUID] = None,
        order_by: str = "due_date_asc",
        skip: int = 0,
        limit: int = 100,
    ) -> List[Task]:
        query = select(Task)

        if status:
            query = query.where(Task.status == status)
        if user_id:
            query = query.where(Task.user_id == user_id)

        # Ordering
        if order_by == "due_date_desc":
            query = query.order_by(desc(Task.due_date))
        else:  # due_date_asc default
            query = query.order_by(asc(Task.due_date))

        query = query.offset(skip).limit(limit)
        result = await self.db.execute(query)
        return result.scalars().all()

    async def get_task_summary(self) -> dict:
        from sqlalchemy import func

        result = await self.db.execute(select(Task.status, func.count(Task.id)).group_by(Task.status))
        summary = {status.value: 0 for status in TaskStatus}
        for status, count in result.all():
            summary[status.value] = count
        return summary
