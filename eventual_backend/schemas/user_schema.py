from pydantic import BaseModel, EmailStr, ConfigDict
from typing import Optional
import uuid


class UserBase(BaseModel):
    name: str
    email: EmailStr
    phone_number: Optional[str] = None


class UserCreate(UserBase):
    pass


class UserUpdate(UserBase):
    pass


class UserInDB(UserBase):
    model_config = ConfigDict(from_attributes=True)
    
    id: uuid.UUID


class UserResponse(UserInDB):
    pass
