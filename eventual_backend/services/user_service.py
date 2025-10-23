from typing import List, Optional
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession

from eventual_backend.models.user import User
from eventual_backend.schemas.user_schema import UserCreate, UserUpdate
from eventual_backend.repositories.user_repository import UserRepository


class UserService:
    def __init__(self, db: AsyncSession):
        self.repository = UserRepository(db)

    async def get_user(self, user_id: UUID) -> Optional[User]:
        return await self.repository.get(user_id)

    async def get_user_by_email(self, email: str) -> Optional[User]:
        return await self.repository.get_by_email(email)

    async def get_users(self, skip: int = 0, limit: int = 100) -> List[User]:
        return await self.repository.get_all(skip, limit)

    async def create_user(self, user_create: UserCreate) -> User:
        user_data = user_create.model_dump()
        return await self.repository.create(user_data)

    async def update_user(self, user_id: UUID, user_update: UserUpdate) -> Optional[User]:
        user = await self.repository.get(user_id)
        if not user:
            return None
        update_data = user_update.model_dump(exclude_unset=True)
        return await self.repository.update(user, update_data)

    async def delete_user(self, user_id: UUID) -> bool:
        return await self.repository.delete(user_id)
