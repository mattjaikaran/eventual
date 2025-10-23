#!/usr/bin/env python3
"""
Seed script to populate the database with sample data
"""
import asyncio
import uuid
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

from eventual_backend.core.config import settings
from eventual_backend.core.database import Base
from eventual_backend.models.user import User
from eventual_backend.models.task import Task, TaskStatus


async def create_seed_data():
    """Create sample users and tasks for demonstration"""
    
    # Create async engine
    engine = create_async_engine(settings.DATABASE_URL, echo=True)
    AsyncSessionLocal = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
    
    try:
        # Create tables if they don't exist
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        
        async with AsyncSessionLocal() as session:
            # Clear existing data
            print("🧹 Clearing existing data...")
            await session.execute(Task.__table__.delete())
            await session.execute(User.__table__.delete())
            await session.commit()
            
            # Create sample users
            print("👥 Creating sample users...")
            users = [
                User(
                    id=uuid.uuid4(),
                    name="Alice Johnson",
                    email="alice@example.com",
                    phone_number="+1-555-0101"
                ),
                User(
                    id=uuid.uuid4(),
                    name="Bob Smith",
                    email="bob@example.com",
                    phone_number="+1-555-0102"
                ),
                User(
                    id=uuid.uuid4(),
                    name="Carol Davis",
                    email="carol@example.com",
                    phone_number="+1-555-0103"
                ),
                User(
                    id=uuid.uuid4(),
                    name="David Wilson",
                    email="david@example.com",
                    phone_number="+1-555-0104"
                ),
                User(
                    id=uuid.uuid4(),
                    name="Eva Martinez",
                    email="eva@example.com",
                    phone_number="+1-555-0105"
                )
            ]
            
            for user in users:
                session.add(user)
            await session.commit()
            
            # Refresh to get the created users with their IDs
            for user in users:
                await session.refresh(user)
            
            print(f"✅ Created {len(users)} users")
            
            # Create sample tasks
            print("📋 Creating sample tasks...")
            now = datetime.now()
            
            tasks = [
                # Alice's tasks
                Task(
                    id=uuid.uuid4(),
                    title="Review Q4 budget proposal",
                    status=TaskStatus.PENDING,
                    due_date=now + timedelta(days=3),
                    user_id=users[0].id,
                    idempotency_key="task-alice-1"
                ),
                Task(
                    id=uuid.uuid4(),
                    title="Prepare presentation for board meeting",
                    status=TaskStatus.IN_PROGRESS,
                    due_date=now + timedelta(days=7),
                    user_id=users[0].id,
                    idempotency_key="task-alice-2"
                ),
                Task(
                    id=uuid.uuid4(),
                    title="Update employee handbook",
                    status=TaskStatus.DONE,
                    due_date=now - timedelta(days=2),
                    user_id=users[0].id,
                    idempotency_key="task-alice-3"
                ),
                
                # Bob's tasks
                Task(
                    id=uuid.uuid4(),
                    title="Fix authentication bug in login system",
                    status=TaskStatus.IN_PROGRESS,
                    due_date=now + timedelta(days=1),
                    user_id=users[1].id,
                    idempotency_key="task-bob-1"
                ),
                Task(
                    id=uuid.uuid4(),
                    title="Implement new API endpoints",
                    status=TaskStatus.PENDING,
                    due_date=now + timedelta(days=5),
                    user_id=users[1].id,
                    idempotency_key="task-bob-2"
                ),
                Task(
                    id=uuid.uuid4(),
                    title="Code review for feature branch",
                    status=TaskStatus.DONE,
                    due_date=now - timedelta(days=1),
                    user_id=users[1].id,
                    idempotency_key="task-bob-3"
                ),
                
                # Carol's tasks
                Task(
                    id=uuid.uuid4(),
                    title="Design new user interface mockups",
                    status=TaskStatus.PENDING,
                    due_date=now + timedelta(days=4),
                    user_id=users[2].id,
                    idempotency_key="task-carol-1"
                ),
                Task(
                    id=uuid.uuid4(),
                    title="Conduct user research interviews",
                    status=TaskStatus.IN_PROGRESS,
                    due_date=now + timedelta(days=6),
                    user_id=users[2].id,
                    idempotency_key="task-carol-2"
                ),
                
                # David's tasks
                Task(
                    id=uuid.uuid4(),
                    title="Set up CI/CD pipeline",
                    status=TaskStatus.DONE,
                    due_date=now - timedelta(days=3),
                    user_id=users[3].id,
                    idempotency_key="task-david-1"
                ),
                Task(
                    id=uuid.uuid4(),
                    title="Monitor server performance",
                    status=TaskStatus.PENDING,
                    due_date=now + timedelta(days=2),
                    user_id=users[3].id,
                    idempotency_key="task-david-2"
                ),
                
                # Eva's tasks
                Task(
                    id=uuid.uuid4(),
                    title="Plan marketing campaign for Q1",
                    status=TaskStatus.PENDING,
                    due_date=now + timedelta(days=10),
                    user_id=users[4].id,
                    idempotency_key="task-eva-1"
                ),
                Task(
                    id=uuid.uuid4(),
                    title="Analyze customer feedback data",
                    status=TaskStatus.IN_PROGRESS,
                    due_date=now + timedelta(days=8),
                    user_id=users[4].id,
                    idempotency_key="task-eva-2"
                )
            ]
            
            for task in tasks:
                session.add(task)
            await session.commit()
            
            print(f"✅ Created {len(tasks)} tasks")
            
            # Print summary
            print("\n📊 Summary of created data:")
            print(f"   👥 Users: {len(users)}")
            print(f"   📋 Tasks: {len(tasks)}")
            
            # Print task status breakdown
            pending_count = len([t for t in tasks if t.status == TaskStatus.PENDING])
            in_progress_count = len([t for t in tasks if t.status == TaskStatus.IN_PROGRESS])
            done_count = len([t for t in tasks if t.status == TaskStatus.DONE])
            
            print(f"   📈 Task Status Breakdown:")
            print(f"      ⏳ Pending: {pending_count}")
            print(f"      🔄 In Progress: {in_progress_count}")
            print(f"      ✅ Done: {done_count}")
            
            print("\n🎉 Seed data created successfully!")
            print("\n💡 You can now:")
            print("   • Start the API server: ./start_server.sh")
            print("   • Run tests: ./run_tests.sh")
            print("   • Visit http://localhost:8000/docs for API documentation")
            
    except Exception as e:
        print(f"❌ Error creating seed data: {e}")
        raise
    finally:
        await engine.dispose()


if __name__ == "__main__":
    asyncio.run(create_seed_data())
