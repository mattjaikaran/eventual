import uuid
from datetime import datetime, timedelta

import pytest
import pytest_asyncio


class TestTasks:
    @pytest_asyncio.fixture
    async def create_test_user(self, client):
        unique_email = f"taskuser-{uuid.uuid4().hex[:8]}@example.com"
        user_data = {"name": "Task User", "email": unique_email, "phone_number": "+1234567890"}
        response = await client.post("/api/users/", json=user_data)
        if response.status_code != 201:
            print(f"User creation failed: {response.status_code} - {response.text}")
        return response.json()["id"]

    @pytest.mark.asyncio
    async def test_create_task_success(self, client, create_test_user):
        """Test successful task creation"""
        user_id = create_test_user
        task_data = {
            "title": "Test Task",
            "status": "pending",
            "due_date": (datetime.now() + timedelta(days=7)).isoformat(),
            "user_id": user_id,
        }

        response = await client.post("/api/tasks/", json=task_data)
        assert response.status_code == 201
        data = response.json()
        assert data["title"] == task_data["title"]
        assert data["status"] == task_data["status"]
        assert data["user_id"] == user_id
        assert "id" in data

    @pytest.mark.asyncio
    async def test_create_task_idempotency(self, client, create_test_user):
        """Test task creation idempotency"""
        user_id = create_test_user
        task_data = {
            "title": "Idempotent Task",
            "status": "pending",
            "due_date": (datetime.now() + timedelta(days=7)).isoformat(),
            "user_id": user_id,
            "idempotency_key": "test-key-123",
        }

        # First request
        response1 = await client.post("/api/tasks/", json=task_data)
        assert response1.status_code == 201
        task_id = response1.json()["id"]

        # Second request with same idempotency key
        response2 = await client.post("/api/tasks/", json=task_data)
        assert response2.status_code == 201
        assert response2.json()["id"] == task_id  # Should return same task

    @pytest.mark.asyncio
    async def test_get_task_summary(self, client, create_test_user):
        """Test task summary endpoint"""
        user_id = create_test_user
        # Create tasks with different statuses
        for status in ["pending", "in_progress", "done"]:
            task_data = {
                "title": f"Task {status}",
                "status": status,
                "due_date": (datetime.now() + timedelta(days=7)).isoformat(),
                "user_id": user_id,
            }
            await client.post("/api/tasks/", json=task_data)

        response = await client.get("/api/tasks/summary/")
        assert response.status_code == 200
        data = response.json()
        assert "pending" in data
        assert "in_progress" in data
        assert "done" in data

    @pytest.mark.asyncio
    async def test_filter_tasks_by_status_pending(self, client, create_test_user):
        """Test filtering tasks by pending status"""
        user_id = create_test_user

        # Create tasks with different statuses
        task_data_pending = {
            "title": "Pending Task",
            "status": "pending",
            "due_date": "2024-12-31T23:59:59",
            "user_id": user_id,
        }
        task_data_in_progress = {
            "title": "In Progress Task",
            "status": "in_progress",
            "due_date": "2024-12-31T23:59:59",
            "user_id": user_id,
        }
        task_data_done = {"title": "Done Task", "status": "done", "due_date": "2024-12-31T23:59:59", "user_id": user_id}

        await client.post("/api/tasks/", json=task_data_pending)
        await client.post("/api/tasks/", json=task_data_in_progress)
        await client.post("/api/tasks/", json=task_data_done)

        # Filter by pending status
        response = await client.get("/api/tasks/", params={"status": "pending"})
        assert response.status_code == 200
        tasks = response.json()
        assert isinstance(tasks, list)

        # All returned tasks should have pending status
        for task in tasks:
            assert task["status"] == "pending"

    @pytest.mark.asyncio
    async def test_filter_tasks_by_status_in_progress(self, client, create_test_user):
        """Test filtering tasks by in_progress status"""
        user_id = create_test_user

        # Create tasks with different statuses
        task_data_pending = {
            "title": "Pending Task",
            "status": "pending",
            "due_date": "2024-12-31T23:59:59",
            "user_id": user_id,
        }
        task_data_in_progress = {
            "title": "In Progress Task",
            "status": "in_progress",
            "due_date": "2024-12-31T23:59:59",
            "user_id": user_id,
        }

        await client.post("/api/tasks/", json=task_data_pending)
        await client.post("/api/tasks/", json=task_data_in_progress)

        # Filter by in_progress status
        response = await client.get("/api/tasks/", params={"status": "in_progress"})
        assert response.status_code == 200
        tasks = response.json()
        assert isinstance(tasks, list)

        # All returned tasks should have in_progress status
        for task in tasks:
            assert task["status"] == "in_progress"

    @pytest.mark.asyncio
    async def test_filter_tasks_by_status_done(self, client, create_test_user):
        """Test filtering tasks by done status"""
        user_id = create_test_user

        # Create tasks with different statuses
        task_data_done = {"title": "Done Task", "status": "done", "due_date": "2024-12-31T23:59:59", "user_id": user_id}
        task_data_pending = {
            "title": "Pending Task",
            "status": "pending",
            "due_date": "2024-12-31T23:59:59",
            "user_id": user_id,
        }

        await client.post("/api/tasks/", json=task_data_done)
        await client.post("/api/tasks/", json=task_data_pending)

        # Filter by done status
        response = await client.get("/api/tasks/", params={"status": "done"})
        assert response.status_code == 200
        tasks = response.json()
        assert isinstance(tasks, list)

        # All returned tasks should have done status
        for task in tasks:
            assert task["status"] == "done"

    @pytest.mark.asyncio
    async def test_filter_tasks_by_user_id(self, client):
        """Test filtering tasks by user_id"""
        # Create two different users
        user1_data = {
            "name": "User One",
            "email": f"user1-{uuid.uuid4().hex[:8]}@example.com",
            "phone_number": "+1111111111",
        }
        user2_data = {
            "name": "User Two",
            "email": f"user2-{uuid.uuid4().hex[:8]}@example.com",
            "phone_number": "+2222222222",
        }

        user1_response = await client.post("/api/users/", json=user1_data)
        user2_response = await client.post("/api/users/", json=user2_data)

        user1_id = user1_response.json()["id"]
        user2_id = user2_response.json()["id"]

        # Create tasks for both users
        task_data_user1 = {
            "title": "Task for User 1",
            "status": "pending",
            "due_date": "2024-12-31T23:59:59",
            "user_id": user1_id,
        }
        task_data_user2 = {
            "title": "Task for User 2",
            "status": "pending",
            "due_date": "2024-12-31T23:59:59",
            "user_id": user2_id,
        }

        await client.post("/api/tasks/", json=task_data_user1)
        await client.post("/api/tasks/", json=task_data_user2)

        # Filter by user1_id
        response = await client.get("/api/tasks/", params={"user_id": user1_id})
        assert response.status_code == 200
        tasks = response.json()
        assert isinstance(tasks, list)

        # All returned tasks should belong to user1
        for task in tasks:
            assert task["user_id"] == user1_id

    @pytest.mark.asyncio
    async def test_filter_tasks_order_by_due_date_asc(self, client, create_test_user):
        """Test ordering tasks by due date ascending"""
        user_id = create_test_user

        # Create tasks with different due dates
        task_data_1 = {
            "title": "Task Due Later",
            "status": "pending",
            "due_date": "2024-12-31T23:59:59",
            "user_id": user_id,
        }
        task_data_2 = {
            "title": "Task Due Earlier",
            "status": "pending",
            "due_date": "2024-06-15T12:00:00",
            "user_id": user_id,
        }
        task_data_3 = {
            "title": "Task Due Middle",
            "status": "pending",
            "due_date": "2024-09-30T18:00:00",
            "user_id": user_id,
        }

        await client.post("/api/tasks/", json=task_data_1)
        await client.post("/api/tasks/", json=task_data_2)
        await client.post("/api/tasks/", json=task_data_3)

        # Get tasks ordered by due date ascending (default)
        response = await client.get("/api/tasks/", params={"user_id": user_id, "order_by": "due_date_asc"})
        assert response.status_code == 200
        tasks = response.json()
        assert len(tasks) >= 3

        # Check that tasks are ordered by due date ascending
        for i in range(len(tasks) - 1):
            current_due_date = tasks[i]["due_date"]
            next_due_date = tasks[i + 1]["due_date"]
            assert current_due_date <= next_due_date

    @pytest.mark.asyncio
    async def test_filter_tasks_order_by_due_date_desc(self, client, create_test_user):
        """Test ordering tasks by due date descending"""
        user_id = create_test_user

        # Create tasks with different due dates
        task_data_1 = {
            "title": "Task Due Earlier",
            "status": "pending",
            "due_date": "2024-06-15T12:00:00",
            "user_id": user_id,
        }
        task_data_2 = {
            "title": "Task Due Later",
            "status": "pending",
            "due_date": "2024-12-31T23:59:59",
            "user_id": user_id,
        }
        task_data_3 = {
            "title": "Task Due Middle",
            "status": "pending",
            "due_date": "2024-09-30T18:00:00",
            "user_id": user_id,
        }

        await client.post("/api/tasks/", json=task_data_1)
        await client.post("/api/tasks/", json=task_data_2)
        await client.post("/api/tasks/", json=task_data_3)

        # Get tasks ordered by due date descending
        response = await client.get("/api/tasks/", params={"user_id": user_id, "order_by": "due_date_desc"})
        assert response.status_code == 200
        tasks = response.json()
        assert len(tasks) >= 3

        # Check that tasks are ordered by due date descending
        for i in range(len(tasks) - 1):
            current_due_date = tasks[i]["due_date"]
            next_due_date = tasks[i + 1]["due_date"]
            assert current_due_date >= next_due_date

    @pytest.mark.asyncio
    async def test_filter_tasks_pagination(self, client, create_test_user):
        """Test task pagination with skip and limit"""
        user_id = create_test_user

        # Create multiple tasks
        for i in range(5):
            task_data = {
                "title": f"Task {i + 1}",
                "status": "pending",
                "due_date": f"2024-{6 + i:02d}-15T12:00:00",
                "user_id": user_id,
            }
            await client.post("/api/tasks/", json=task_data)

        # Test first page (limit=2, skip=0)
        response = await client.get("/api/tasks/", params={"user_id": user_id, "limit": 2, "skip": 0})
        assert response.status_code == 200
        tasks_page1 = response.json()
        assert len(tasks_page1) == 2

        # Test second page (limit=2, skip=2)
        response = await client.get("/api/tasks/", params={"user_id": user_id, "limit": 2, "skip": 2})
        assert response.status_code == 200
        tasks_page2 = response.json()
        assert len(tasks_page2) == 2

        # Ensure different tasks on different pages
        page1_ids = {task["id"] for task in tasks_page1}
        page2_ids = {task["id"] for task in tasks_page2}
        assert page1_ids.isdisjoint(page2_ids)

    @pytest.mark.asyncio
    async def test_filter_tasks_combined_filters(self, client):
        """Test combining multiple filters"""
        # Create two users
        user1_data = {
            "name": "User One",
            "email": f"user1-{uuid.uuid4().hex[:8]}@example.com",
            "phone_number": "+1111111111",
        }
        user2_data = {
            "name": "User Two",
            "email": f"user2-{uuid.uuid4().hex[:8]}@example.com",
            "phone_number": "+2222222222",
        }

        user1_response = await client.post("/api/users/", json=user1_data)
        user2_response = await client.post("/api/users/", json=user2_data)

        user1_id = user1_response.json()["id"]
        user2_id = user2_response.json()["id"]

        # Create tasks with different combinations
        tasks_data = [
            {"title": "User1 Pending 1", "status": "pending", "due_date": "2024-06-15T12:00:00", "user_id": user1_id},
            {"title": "User1 Pending 2", "status": "pending", "due_date": "2024-12-31T23:59:59", "user_id": user1_id},
            {"title": "User1 Done", "status": "done", "due_date": "2024-09-30T18:00:00", "user_id": user1_id},
            {"title": "User2 Pending", "status": "pending", "due_date": "2024-08-15T12:00:00", "user_id": user2_id},
        ]

        for task_data in tasks_data:
            await client.post("/api/tasks/", json=task_data)

        # Filter by user1_id AND pending status AND order by due_date_desc
        response = await client.get(
            "/api/tasks/", params={"user_id": user1_id, "status": "pending", "order_by": "due_date_desc", "limit": 10}
        )
        assert response.status_code == 200
        tasks = response.json()

        # Should only return user1's pending tasks, ordered by due date desc
        assert len(tasks) == 2
        for task in tasks:
            assert task["user_id"] == user1_id
            assert task["status"] == "pending"

        # Check ordering (later dates first)
        assert tasks[0]["due_date"] >= tasks[1]["due_date"]

    @pytest.mark.asyncio
    async def test_filter_tasks_invalid_status(self, client):
        """Test filtering with invalid status"""
        response = await client.get("/api/tasks/", params={"status": "invalid_status"})
        assert response.status_code == 422  # Validation error

    @pytest.mark.asyncio
    async def test_filter_tasks_invalid_order_by(self, client):
        """Test filtering with invalid order_by"""
        response = await client.get("/api/tasks/", params={"order_by": "invalid_order"})
        assert response.status_code == 422  # Validation error

    @pytest.mark.asyncio
    async def test_filter_tasks_nonexistent_user_id(self, client):
        """Test filtering by non-existent user_id"""
        fake_user_id = uuid.uuid4()
        response = await client.get("/api/tasks/", params={"user_id": fake_user_id})
        assert response.status_code == 200
        tasks = response.json()
        assert tasks == []  # Should return empty list

    @pytest.mark.asyncio
    async def test_list_tasks_with_filters(self, client, create_test_user):
        """Test listing tasks with filters (legacy test)"""
        user_id = create_test_user
        response = await client.get(
            "/api/tasks/",
            params={"status": "pending", "user_id": user_id, "order_by": "due_date_desc", "limit": 10},
        )
        assert response.status_code == 200
        assert isinstance(response.json(), list)

    @pytest.mark.asyncio
    async def test_get_user_tasks(self, client, create_test_user):
        """Test getting tasks for specific user"""
        user_id = create_test_user
        response = await client.get(f"/api/tasks/user/{user_id}")
        assert response.status_code == 200
        assert isinstance(response.json(), list)
