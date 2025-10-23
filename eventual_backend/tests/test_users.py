import uuid

import pytest


class TestUsers:
    @pytest.mark.asyncio
    async def test_create_user_success(self, client):
        """Test successful user creation"""

        unique_email = f"john-{uuid.uuid4().hex[:8]}@example.com"
        user_data = {"name": "John Doe", "email": unique_email, "phone_number": "+1234567890"}

        response = await client.post("/api/users/", json=user_data)
        if response.status_code != 201:
            print(f"Error: {response.status_code} - {response.text}")
        assert response.status_code == 201
        data = response.json()
        assert data["name"] == user_data["name"]
        assert data["email"] == user_data["email"]
        assert data["phone_number"] == user_data["phone_number"]
        assert "id" in data

    @pytest.mark.asyncio
    async def test_create_user_duplicate_email(self, client):
        """Test user creation with duplicate email"""

        unique_email = f"jane-{uuid.uuid4().hex[:8]}@example.com"
        user_data = {"name": "Jane Doe", "email": unique_email, "phone_number": "+1234567890"}

        # First request should succeed
        response1 = await client.post("/api/users/", json=user_data)
        assert response1.status_code == 201

        # Second request should fail
        response2 = await client.post("/api/users/", json=user_data)
        assert response2.status_code == 400
        assert "Email already registered" in response2.json()["detail"]

    @pytest.mark.asyncio
    async def test_get_user_not_found(self, client):
        """Test getting non-existent user"""
        non_existent_id = uuid.uuid4().hex
        response = await client.get(f"/api/users/{non_existent_id}")
        assert response.status_code == 404

    @pytest.mark.asyncio
    async def test_update_user_success(self, client):
        """Test successful user update"""
        # Create user first

        unique_email = f"original-{uuid.uuid4().hex[:8]}@example.com"
        user_data = {"name": "Original Name", "email": unique_email, "phone_number": "+1234567890"}
        create_response = await client.post("/api/users/", json=user_data)
        user_id = create_response.json()["id"]

        # Update user
        updated_email = f"updated-{uuid.uuid4().hex[:8]}@example.com"
        update_data = {"name": "Updated Name", "email": updated_email}
        update_response = await client.put(f"/api/users/{user_id}", json=update_data)
        assert update_response.status_code == 200
        data = update_response.json()
        assert data["name"] == update_data["name"]
        assert data["email"] == update_data["email"]

    @pytest.mark.asyncio
    async def test_delete_user_success(self, client):
        """Test successful user deletion"""
        # Create user first

        unique_email = f"delete-{uuid.uuid4().hex[:8]}@example.com"
        user_data = {"name": "To Delete", "email": unique_email, "phone_number": "+1234567890"}
        create_response = await client.post("/api/users/", json=user_data)
        user_id = create_response.json()["id"]

        # Delete user
        delete_response = await client.delete(f"/api/users/{user_id}")
        assert delete_response.status_code == 204

        # Verify user is deleted
        get_response = await client.get(f"/api/users/{user_id}")
        assert get_response.status_code == 404

    @pytest.mark.asyncio
    async def test_list_users_pagination(self, client):
        """Test user listing with pagination"""
        # Create multiple users
        created_users = []
        for i in range(5):
            user_data = {
                "name": f"User {i + 1}",
                "email": f"user{i + 1}-{uuid.uuid4().hex[:8]}@example.com",
                "phone_number": f"+123456789{i}",
            }
            response = await client.post("/api/users/", json=user_data)
            created_users.append(response.json())

        # Test first page (limit=2, skip=0)
        response = await client.get("/api/users/", params={"limit": 2, "skip": 0})
        assert response.status_code == 200
        users_page1 = response.json()
        assert len(users_page1) >= 2  # May include existing users from other tests

        # Test second page (limit=2, skip=2)
        response = await client.get("/api/users/", params={"limit": 2, "skip": 2})
        assert response.status_code == 200
        users_page2 = response.json()
        assert isinstance(users_page2, list)

        # Test with larger skip to ensure we can paginate through all users
        response = await client.get("/api/users/", params={"limit": 100, "skip": 0})
        assert response.status_code == 200
        all_users = response.json()
        assert len(all_users) >= 5  # At least our created users

    @pytest.mark.asyncio
    async def test_list_users_default_pagination(self, client):
        """Test user listing with default pagination values"""
        response = await client.get("/api/users/")
        assert response.status_code == 200
        users = response.json()
        assert isinstance(users, list)
        assert len(users) <= 100  # Default limit is 100

    @pytest.mark.asyncio
    async def test_list_users_empty_result(self, client):
        """Test user listing with skip beyond available users"""
        # Get total count first
        response = await client.get("/api/users/", params={"limit": 1000})
        total_users = len(response.json())

        # Skip beyond available users
        response = await client.get("/api/users/", params={"skip": total_users + 100})
        assert response.status_code == 200
        users = response.json()
        assert users == []

    @pytest.mark.asyncio
    async def test_list_users_zero_limit(self, client):
        """Test user listing with zero limit"""
        response = await client.get("/api/users/", params={"limit": 0})
        assert response.status_code == 200
        users = response.json()
        assert users == []

    @pytest.mark.asyncio
    async def test_list_users_large_limit(self, client):
        """Test user listing with very large limit"""
        response = await client.get("/api/users/", params={"limit": 10000})
        assert response.status_code == 200
        users = response.json()
        assert isinstance(users, list)
        # Should return all available users without error
