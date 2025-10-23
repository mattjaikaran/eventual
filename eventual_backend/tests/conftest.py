import asyncio
import os
from collections.abc import AsyncGenerator

import pytest
import pytest_asyncio
from httpx import AsyncClient
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from eventual_backend.core.database import Base, get_db
from eventual_backend.main import app

# Test database - PostgreSQL
TEST_DATABASE_URL = os.getenv("TEST_DATABASE_URL", "postgresql+asyncpg://mattjaikaran@localhost/test_taskdb")

engine = create_async_engine(TEST_DATABASE_URL, echo=False, pool_pre_ping=True, pool_recycle=300)
TestingSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


async def override_get_db() -> AsyncGenerator[AsyncSession, None]:
    async with TestingSessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()


@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    try:
        loop = asyncio.get_running_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="session", autouse=True)
async def setup_database():
    """Set up test database tables."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
        await conn.run_sync(Base.metadata.create_all)
    yield
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


@pytest.fixture(autouse=True)
async def clean_database():
    """Clean database before and after each test."""
    # Clean before test
    async with TestingSessionLocal() as session:
        await session.execute(text("DELETE FROM tasks"))
        await session.execute(text("DELETE FROM users"))
        await session.commit()

    yield

    # Clean after test
    async with TestingSessionLocal() as session:
        await session.execute(text("DELETE FROM tasks"))
        await session.execute(text("DELETE FROM users"))
        await session.commit()


@pytest_asyncio.fixture
async def client():
    app.dependency_overrides[get_db] = override_get_db
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()
