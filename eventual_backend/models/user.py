from sqlalchemy import Column, String
from sqlalchemy.dialects.postgresql import UUID
import uuid

from eventual_backend.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False)
    email = Column(String, nullable=False, unique=True)
    phone_number = Column(String, nullable=True)
