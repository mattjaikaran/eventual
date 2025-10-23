from typing import List
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, status

from eventual_backend.services.user_service import UserService
from eventual_backend.schemas.user_schema import UserCreate, UserUpdate, UserResponse
from eventual_backend.api.dependencies import get_user_service

router = APIRouter()


@router.get("/", response_model=List[UserResponse])
async def list_users(skip: int = 0, limit: int = 100, user_service: UserService = Depends(get_user_service)):
    return await user_service.get_users(skip=skip, limit=limit)


@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(user_create: UserCreate, user_service: UserService = Depends(get_user_service)):
    # Check if email already exists
    existing_user = await user_service.get_user_by_email(user_create.email)
    if existing_user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

    return await user_service.create_user(user_create)


@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: UUID, user_service: UserService = Depends(get_user_service)):
    user = await user_service.get_user(user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user


@router.put("/{user_id}", response_model=UserResponse)
async def update_user(user_id: UUID, user_update: UserUpdate, user_service: UserService = Depends(get_user_service)):
    user = await user_service.update_user(user_id, user_update)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(user_id: UUID, user_service: UserService = Depends(get_user_service)):
    success = await user_service.delete_user(user_id)
    if not success:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
