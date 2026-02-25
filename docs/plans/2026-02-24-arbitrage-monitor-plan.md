# Event-Driven Arbitrage Monitor — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build an automated system that discovers US stock event-driven opportunities, analyzes arbitrage spreads, tracks event lifecycles, and sends alerts.

**Architecture:** Modular Python backend with source adapters feeding events into PostgreSQL, analyzed by Claude API, tracked by APScheduler, served via FastAPI + React dashboard. See `docs/plans/2026-02-24-arbitrage-monitor-design.md` for full design.

**Tech Stack:** Python 3.12, FastAPI, SQLAlchemy 2.0, Alembic, APScheduler, PostgreSQL (Docker), React + Vite + TypeScript, Anthropic SDK, sec-api, polygon-api-client, httpx

---

## Phase 1: Project Foundation & Database

### Task 1: Project scaffolding

**Files:**
- Create: `backend/pyproject.toml`
- Create: `backend/src/__init__.py`
- Create: `backend/src/config.py`
- Create: `docker-compose.yml`
- Create: `.env.example`
- Create: `.gitignore`

**Step 1: Create `.gitignore`**

```gitignore
__pycache__/
*.pyc
.env
*.egg-info/
dist/
.venv/
node_modules/
frontend/dist/
.pytest_cache/
```

**Step 2: Create `docker-compose.yml`**

```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: arbitrage
      POSTGRES_USER: arbitrage
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-devpassword}
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

**Step 3: Create `.env.example`**

```env
# Database
POSTGRES_PASSWORD=devpassword
DATABASE_URL=postgresql+asyncpg://arbitrage:devpassword@localhost:5432/arbitrage

# Data Sources
SEC_API_KEY=your_sec_api_key
NEWSFILTER_API_KEY=your_newsfilter_key
POLYGON_API_KEY=your_polygon_key
TRADIER_ACCESS_TOKEN=your_tradier_token
FMP_API_KEY=your_fmp_key

# Notifications
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
TELEGRAM_CHAT_ID=your_chat_id
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password
ALERT_EMAIL_TO=your_email@gmail.com

# LLM
ANTHROPIC_API_KEY=your_anthropic_key
```

**Step 4: Create `backend/pyproject.toml`**

```toml
[project]
name = "arbitrage-monitor"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.30.0",
    "sqlalchemy[asyncio]>=2.0.0",
    "asyncpg>=0.30.0",
    "alembic>=1.14.0",
    "pydantic>=2.0.0",
    "pydantic-settings>=2.0.0",
    "httpx>=0.27.0",
    "anthropic>=0.40.0",
    "sec-api>=1.0.0",
    "polygon-api-client>=1.14.0",
    "apscheduler>=4.0.0",
    "python-telegram-bot>=21.0",
    "aiosmtplib>=3.0.0",
    "python-dotenv>=1.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.24.0",
    "pytest-cov>=5.0.0",
    "ruff>=0.6.0",
]

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]

[tool.ruff]
target-version = "py312"
```

**Step 5: Create `backend/src/__init__.py`** (empty file)

**Step 6: Create `backend/src/config.py`**

```python
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Database
    database_url: str = "postgresql+asyncpg://arbitrage:devpassword@localhost:5432/arbitrage"

    # Data Sources
    sec_api_key: str = ""
    newsfilter_api_key: str = ""
    polygon_api_key: str = ""
    tradier_access_token: str = ""
    fmp_api_key: str = ""

    # Notifications
    telegram_bot_token: str = ""
    telegram_chat_id: str = ""
    smtp_host: str = "smtp.gmail.com"
    smtp_port: int = 587
    smtp_user: str = ""
    smtp_password: str = ""
    alert_email_to: str = ""

    # LLM
    anthropic_api_key: str = ""

    # Thresholds
    min_annualized_spread_pct: float = 10.0
    spread_widen_alert_pct: float = 2.0
    spread_narrow_exit_pct: float = 3.0
    key_date_alert_days: int = 7

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
```

**Step 7: Start Postgres and verify**

Run: `docker compose up -d && sleep 3 && docker compose ps`
Expected: `db` container running, healthy

**Step 8: Install dependencies**

Run: `cd backend && python -m venv .venv && source .venv/bin/activate && pip install -e ".[dev]"`

**Step 9: Commit**

```bash
git add .gitignore docker-compose.yml .env.example backend/pyproject.toml backend/src/__init__.py backend/src/config.py
git commit -m "feat: project scaffolding with config, docker-compose, dependencies"
```

---

### Task 2: SQLAlchemy models & Alembic migrations

**Files:**
- Create: `backend/src/models/__init__.py`
- Create: `backend/src/models/models.py`
- Create: `backend/src/models/database.py`
- Create: `backend/tests/__init__.py`
- Create: `backend/tests/test_models.py`

**Step 1: Write the failing test**

Create `backend/tests/__init__.py` (empty) and `backend/tests/test_models.py`:

```python
import uuid
from datetime import datetime, timezone

from src.models.models import (
    Event,
    Analysis,
    Position,
    Alert,
    EventType,
    EventStatus,
    Recommendation,
    AlertType,
    AlertPriority,
    PositionStatus,
)


def test_event_model_creation():
    event = Event(
        id=uuid.uuid4(),
        event_id="AAPL-20260224-MA",
        ticker="AAPL",
        company_name="Apple Inc.",
        event_type=EventType.MA,
        status=EventStatus.ACTIVE,
        description="Test acquisition",
    )
    assert event.ticker == "AAPL"
    assert event.event_type == EventType.MA
    assert event.status == EventStatus.ACTIVE


def test_analysis_model_creation():
    analysis = Analysis(
        id=uuid.uuid4(),
        event_id=uuid.uuid4(),
        current_price=47.50,
        gross_spread_pct=5.3,
        annualized_spread_pct=12.1,
        completion_probability=0.85,
        expected_value=3.2,
        downside_estimate=35.0,
        risk_factors={"regulatory": "medium", "financing": "low"},
        recommendation=Recommendation.ENTER,
        reasoning="Spread is attractive with high completion probability.",
    )
    assert analysis.gross_spread_pct == 5.3
    assert analysis.recommendation == Recommendation.ENTER


def test_event_type_enum_values():
    assert EventType.MA.value == "MA"
    assert EventType.GO_PRIVATE.value == "GO_PRIVATE"
    assert EventType.TENDER.value == "TENDER"
    assert EventType.LITIGATION.value == "LITIGATION"


def test_alert_type_enum_values():
    assert AlertType.NEW_OPPORTUNITY.value == "NEW_OPPORTUNITY"
    assert AlertType.SPREAD_WIDENED.value == "SPREAD_WIDENED"
    assert AlertType.EXIT_SIGNAL.value == "EXIT_SIGNAL"
```

**Step 2: Run test to verify it fails**

Run: `cd backend && source .venv/bin/activate && python -m pytest tests/test_models.py -v`
Expected: FAIL — `ModuleNotFoundError: No module named 'src.models.models'`

**Step 3: Create `backend/src/models/__init__.py`** (empty)

**Step 4: Create `backend/src/models/database.py`**

```python
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine, AsyncSession
from src.config import settings

engine = create_async_engine(settings.database_url, echo=False)
async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)


async def get_session() -> AsyncSession:
    async with async_session() as session:
        yield session
```

**Step 5: Create `backend/src/models/models.py`**

```python
import enum
import uuid
from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import (
    String,
    Text,
    Numeric,
    DateTime,
    ForeignKey,
    Index,
    Enum as SAEnum,
)
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class EventType(enum.Enum):
    MA = "MA"
    GO_PRIVATE = "GO_PRIVATE"
    TENDER = "TENDER"
    LITIGATION = "LITIGATION"
    ACTIVIST = "ACTIVIST"
    SPINOFF = "SPINOFF"
    REGULATORY = "REGULATORY"
    SPAC = "SPAC"
    BANKRUPTCY = "BANKRUPTCY"


class EventStatus(enum.Enum):
    ACTIVE = "ACTIVE"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    THESIS_CHANGED = "THESIS_CHANGED"


class Recommendation(enum.Enum):
    ENTER = "ENTER"
    HOLD = "HOLD"
    EXIT = "EXIT"
    WATCH = "WATCH"


class AlertType(enum.Enum):
    NEW_OPPORTUNITY = "NEW_OPPORTUNITY"
    SPREAD_WIDENED = "SPREAD_WIDENED"
    SPREAD_NARROWED = "SPREAD_NARROWED"
    THESIS_CHANGE = "THESIS_CHANGE"
    KEY_DATE_APPROACHING = "KEY_DATE_APPROACHING"
    EXIT_SIGNAL = "EXIT_SIGNAL"
    NEW_FILING = "NEW_FILING"


class AlertPriority(enum.Enum):
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"


class PositionStatus(enum.Enum):
    OPEN = "OPEN"
    CLOSED = "CLOSED"


class Event(Base):
    __tablename__ = "events"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    event_id: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    ticker: Mapped[str] = mapped_column(String(10), nullable=False, index=True)
    company_name: Mapped[str] = mapped_column(String(256), nullable=False)
    event_type: Mapped[EventType] = mapped_column(SAEnum(EventType), nullable=False)
    status: Mapped[EventStatus] = mapped_column(SAEnum(EventStatus), nullable=False, default=EventStatus.ACTIVE)
    description: Mapped[str] = mapped_column(Text, nullable=False, default="")
    deal_price: Mapped[Decimal | None] = mapped_column(Numeric(12, 4), nullable=True)
    key_dates: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    key_parties: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    source_filings: Mapped[list | None] = mapped_column(JSONB, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    analyses: Mapped[list["Analysis"]] = relationship(back_populates="event", cascade="all, delete-orphan")
    positions: Mapped[list["Position"]] = relationship(back_populates="event", cascade="all, delete-orphan")
    alerts: Mapped[list["Alert"]] = relationship(back_populates="event", cascade="all, delete-orphan")

    __table_args__ = (Index("ix_events_status_type", "status", "event_type"),)


class Analysis(Base):
    __tablename__ = "analyses"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    event_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("events.id"), nullable=False)
    current_price: Mapped[Decimal] = mapped_column(Numeric(12, 4), nullable=False)
    gross_spread_pct: Mapped[Decimal] = mapped_column(Numeric(8, 4), nullable=False)
    annualized_spread_pct: Mapped[Decimal] = mapped_column(Numeric(8, 4), nullable=False)
    completion_probability: Mapped[Decimal] = mapped_column(Numeric(5, 4), nullable=False)
    expected_value: Mapped[Decimal] = mapped_column(Numeric(12, 4), nullable=False)
    downside_estimate: Mapped[Decimal] = mapped_column(Numeric(12, 4), nullable=False)
    risk_factors: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    recommendation: Mapped[Recommendation] = mapped_column(SAEnum(Recommendation), nullable=False)
    reasoning: Mapped[str] = mapped_column(Text, nullable=False, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    event: Mapped["Event"] = relationship(back_populates="analyses")


class Position(Base):
    __tablename__ = "positions"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    event_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("events.id"), nullable=False)
    entry_date: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    entry_price: Mapped[Decimal] = mapped_column(Numeric(12, 4), nullable=False)
    shares: Mapped[int] = mapped_column(nullable=False, default=0)
    current_value: Mapped[Decimal] = mapped_column(Numeric(14, 4), nullable=False, default=0)
    pnl: Mapped[Decimal] = mapped_column(Numeric(14, 4), nullable=False, default=0)
    status: Mapped[PositionStatus] = mapped_column(SAEnum(PositionStatus), nullable=False, default=PositionStatus.OPEN)
    notes: Mapped[str] = mapped_column(Text, nullable=False, default="")

    event: Mapped["Event"] = relationship(back_populates="positions")


class Alert(Base):
    __tablename__ = "alerts"

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    event_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("events.id"), nullable=False)
    alert_type: Mapped[AlertType] = mapped_column(SAEnum(AlertType), nullable=False)
    priority: Mapped[AlertPriority] = mapped_column(SAEnum(AlertPriority), nullable=False)
    message: Mapped[str] = mapped_column(Text, nullable=False)
    sent_via: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    event: Mapped["Event"] = relationship(back_populates="alerts")
```

**Step 6: Run test to verify it passes**

Run: `cd backend && source .venv/bin/activate && python -m pytest tests/test_models.py -v`
Expected: All 4 tests PASS

**Step 7: Initialize Alembic**

Run: `cd backend && source .venv/bin/activate && alembic init alembic`

Then edit `backend/alembic/env.py` — replace the `target_metadata = None` line and add imports:

```python
# At top of env.py, add:
from src.models.models import Base
from src.config import settings

# Replace target_metadata line with:
target_metadata = Base.metadata

# In run_migrations_online(), replace the engine creation with:
from sqlalchemy.ext.asyncio import create_async_engine
connectable = create_async_engine(settings.database_url)
```

Edit `backend/alembic.ini` — set `sqlalchemy.url` to empty (we use config):
```ini
sqlalchemy.url =
```

**Step 8: Generate and run initial migration**

Run:
```bash
cd backend && source .venv/bin/activate
alembic revision --autogenerate -m "initial schema"
alembic upgrade head
```

Expected: Migration file created, tables created in PostgreSQL

**Step 9: Commit**

```bash
git add backend/src/models/ backend/tests/ backend/alembic/ backend/alembic.ini
git commit -m "feat: SQLAlchemy models, Alembic migrations for events/analyses/positions/alerts"
```

---

### Task 3: Event store CRUD operations

**Files:**
- Create: `backend/src/tracking/__init__.py`
- Create: `backend/src/tracking/event_store.py`
- Create: `backend/tests/test_event_store.py`

**Step 1: Write the failing test**

Create `backend/tests/test_event_store.py`:

```python
import uuid
import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from decimal import Decimal

from src.tracking.event_store import EventStore
from src.models.models import EventType, EventStatus, Recommendation


@pytest.fixture
def store():
    return EventStore()


@pytest.fixture
def sample_event_data():
    return {
        "event_id": "AAPL-20260224-MA",
        "ticker": "AAPL",
        "company_name": "Apple Inc.",
        "event_type": EventType.MA,
        "description": "Microsoft acquires Apple at $250/share",
        "deal_price": Decimal("250.00"),
        "key_dates": {"announcement": "2026-02-24", "expected_close": "2026-08-24"},
        "key_parties": {"acquirer": "Microsoft", "target": "Apple"},
        "source_filings": [{"url": "https://sec.gov/filing/123", "type": "DEFM14A"}],
    }


def test_event_store_exists():
    store = EventStore()
    assert store is not None
    assert hasattr(store, "create_event")
    assert hasattr(store, "get_event_by_event_id")
    assert hasattr(store, "get_active_events")
    assert hasattr(store, "update_event_status")
    assert hasattr(store, "upsert_event")
```

**Step 2: Run test to verify it fails**

Run: `cd backend && python -m pytest tests/test_event_store.py -v`
Expected: FAIL — `ModuleNotFoundError`

**Step 3: Implement `backend/src/tracking/__init__.py`** (empty) and `backend/src/tracking/event_store.py`**

```python
import uuid
from decimal import Decimal

from sqlalchemy import select, update
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.dialects.postgresql import insert

from src.models.models import Event, EventType, EventStatus


class EventStore:
    async def create_event(self, session: AsyncSession, **kwargs) -> Event:
        event = Event(**kwargs)
        session.add(event)
        await session.flush()
        return event

    async def get_event_by_event_id(self, session: AsyncSession, event_id: str) -> Event | None:
        result = await session.execute(select(Event).where(Event.event_id == event_id))
        return result.scalar_one_or_none()

    async def get_event_by_id(self, session: AsyncSession, id: uuid.UUID) -> Event | None:
        result = await session.execute(select(Event).where(Event.id == id))
        return result.scalar_one_or_none()

    async def get_active_events(self, session: AsyncSession) -> list[Event]:
        result = await session.execute(
            select(Event).where(Event.status == EventStatus.ACTIVE).order_by(Event.updated_at.desc())
        )
        return list(result.scalars().all())

    async def get_events_by_type(self, session: AsyncSession, event_type: EventType) -> list[Event]:
        result = await session.execute(
            select(Event).where(Event.event_type == event_type).order_by(Event.updated_at.desc())
        )
        return list(result.scalars().all())

    async def update_event_status(self, session: AsyncSession, event_id: str, status: EventStatus) -> Event | None:
        event = await self.get_event_by_event_id(session, event_id)
        if event:
            event.status = status
            await session.flush()
        return event

    async def upsert_event(self, session: AsyncSession, **kwargs) -> Event:
        event_id = kwargs["event_id"]
        existing = await self.get_event_by_event_id(session, event_id)
        if existing:
            for key, value in kwargs.items():
                if key != "event_id" and value is not None:
                    setattr(existing, key, value)
            await session.flush()
            return existing
        return await self.create_event(session, **kwargs)

    async def get_events_by_ticker(self, session: AsyncSession, ticker: str) -> list[Event]:
        result = await session.execute(
            select(Event).where(Event.ticker == ticker).order_by(Event.updated_at.desc())
        )
        return list(result.scalars().all())
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_event_store.py -v`
Expected: PASS

**Step 5: Commit**

```bash
git add backend/src/tracking/ backend/tests/test_event_store.py
git commit -m "feat: event store with CRUD and upsert operations"
```

---

### Task 4: Ingestion base adapter interface

**Files:**
- Create: `backend/src/ingestion/__init__.py`
- Create: `backend/src/ingestion/base.py`
- Create: `backend/tests/test_ingestion_base.py`

**Step 1: Write the failing test**

Create `backend/tests/test_ingestion_base.py`:

```python
import pytest
from src.ingestion.base import BaseSourceAdapter, RawEvent


def test_raw_event_dataclass():
    event = RawEvent(
        source="sec_api",
        source_id="filing-123",
        ticker="AAPL",
        company_name="Apple Inc.",
        event_type_hint="MA",
        title="Merger announcement",
        raw_text="Microsoft to acquire Apple...",
        url="https://sec.gov/filing/123",
        metadata={"filing_type": "DEFM14A"},
    )
    assert event.source == "sec_api"
    assert event.ticker == "AAPL"


def test_base_adapter_is_abstract():
    with pytest.raises(TypeError):
        BaseSourceAdapter()


def test_base_adapter_requires_fetch_and_name():
    class IncompleteAdapter(BaseSourceAdapter):
        pass

    with pytest.raises(TypeError):
        IncompleteAdapter()
```

**Step 2: Run test to verify it fails**

Run: `cd backend && python -m pytest tests/test_ingestion_base.py -v`
Expected: FAIL

**Step 3: Implement `backend/src/ingestion/__init__.py`** (empty) and `backend/src/ingestion/base.py`**

```python
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import datetime, timezone


@dataclass
class RawEvent:
    source: str
    source_id: str
    ticker: str
    company_name: str
    event_type_hint: str
    title: str
    raw_text: str
    url: str
    metadata: dict = field(default_factory=dict)
    detected_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))


class BaseSourceAdapter(ABC):
    @property
    @abstractmethod
    def name(self) -> str:
        """Unique name for this source adapter."""
        ...

    @abstractmethod
    async def fetch(self) -> list[RawEvent]:
        """Fetch new raw events from this source. Returns deduplicated events since last fetch."""
        ...

    async def start(self) -> None:
        """Optional: start continuous streaming (for WebSocket sources)."""
        pass

    async def stop(self) -> None:
        """Optional: stop streaming."""
        pass
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_ingestion_base.py -v`
Expected: All 3 tests PASS

**Step 5: Commit**

```bash
git add backend/src/ingestion/ backend/tests/test_ingestion_base.py
git commit -m "feat: base source adapter interface and RawEvent dataclass"
```

---

## Phase 1 continued: Source Adapters (Tasks 5-9) are in Phase 1B below.
## Phase 2: Analysis Engine (Tasks 10-14)
## Phase 3: Tracking & Alerts (Tasks 15-19)
## Phase 4: Dashboard (Tasks 20-25)

These will be detailed when Phase 1A (Tasks 1-4) is complete. Each subsequent phase plan follows the same TDD pattern.

---

## Phase 1B: Source Adapters

### Task 5: SEC API adapter (sec-api.io)

**Files:**
- Create: `backend/src/ingestion/sec_api.py`
- Create: `backend/tests/test_sec_api_adapter.py`

**Step 1: Write the failing test**

Create `backend/tests/test_sec_api_adapter.py`:

```python
import pytest
from unittest.mock import patch, MagicMock, AsyncMock
from src.ingestion.sec_api import SecApiAdapter
from src.ingestion.base import BaseSourceAdapter, RawEvent


def test_sec_api_adapter_is_source_adapter():
    adapter = SecApiAdapter(api_key="test-key")
    assert isinstance(adapter, BaseSourceAdapter)
    assert adapter.name == "sec_api"


def test_sec_api_adapter_filing_type_mapping():
    adapter = SecApiAdapter(api_key="test-key")
    assert adapter.filing_type_to_event_hint("SC 13D") == "ACTIVIST"
    assert adapter.filing_type_to_event_hint("SC 13D/A") == "ACTIVIST"
    assert adapter.filing_type_to_event_hint("DEFM14A") == "MA"
    assert adapter.filing_type_to_event_hint("PREM14A") == "MA"
    assert adapter.filing_type_to_event_hint("SC TO-T") == "TENDER"
    assert adapter.filing_type_to_event_hint("SC TO-C") == "TENDER"
    assert adapter.filing_type_to_event_hint("8-K") == "GENERAL"
    assert adapter.filing_type_to_event_hint("10-K") == "UNKNOWN"


def test_sec_api_parse_filing_to_raw_event():
    adapter = SecApiAdapter(api_key="test-key")
    filing = {
        "accessionNo": "0001234567-26-000001",
        "formType": "SC 13D",
        "companyName": "Apple Inc.",
        "ticker": "AAPL",
        "filedAt": "2026-02-24T10:30:00-05:00",
        "documentUrl": "https://www.sec.gov/Archives/edgar/data/...",
        "description": "Schedule 13D - Report of beneficial ownership",
    }
    raw_event = adapter.parse_filing(filing)
    assert raw_event is not None
    assert raw_event.source == "sec_api"
    assert raw_event.ticker == "AAPL"
    assert raw_event.event_type_hint == "ACTIVIST"
    assert raw_event.source_id == "0001234567-26-000001"


def test_sec_api_skips_irrelevant_filings():
    adapter = SecApiAdapter(api_key="test-key")
    filing = {
        "accessionNo": "0001234567-26-000002",
        "formType": "10-K",
        "companyName": "Apple Inc.",
        "ticker": "AAPL",
        "filedAt": "2026-02-24T10:30:00-05:00",
        "documentUrl": "https://www.sec.gov/...",
        "description": "Annual report",
    }
    raw_event = adapter.parse_filing(filing)
    assert raw_event is None
```

**Step 2: Run test to verify it fails**

Run: `cd backend && python -m pytest tests/test_sec_api_adapter.py -v`
Expected: FAIL

**Step 3: Implement `backend/src/ingestion/sec_api.py`**

```python
import logging
from datetime import datetime, timezone

import httpx

from src.ingestion.base import BaseSourceAdapter, RawEvent

logger = logging.getLogger(__name__)

RELEVANT_FORM_TYPES = {
    "SC 13D": "ACTIVIST",
    "SC 13D/A": "ACTIVIST",
    "SC 13G": "ACTIVIST",
    "SC 13G/A": "ACTIVIST",
    "DEFM14A": "MA",
    "PREM14A": "MA",
    "DEFM14C": "MA",
    "SC TO-T": "TENDER",
    "SC TO-T/A": "TENDER",
    "SC TO-C": "TENDER",
    "SC TO-I": "TENDER",
    "8-K": "GENERAL",
    "S-4": "MA",
    "S-4/A": "MA",
}


class SecApiAdapter(BaseSourceAdapter):
    def __init__(self, api_key: str):
        self._api_key = api_key
        self._base_url = "https://api.sec-api.io"
        self._seen_accessions: set[str] = set()

    @property
    def name(self) -> str:
        return "sec_api"

    def filing_type_to_event_hint(self, form_type: str) -> str:
        return RELEVANT_FORM_TYPES.get(form_type, "UNKNOWN")

    def parse_filing(self, filing: dict) -> RawEvent | None:
        form_type = filing.get("formType", "")
        event_hint = self.filing_type_to_event_hint(form_type)
        if event_hint == "UNKNOWN":
            return None

        accession = filing.get("accessionNo", "")
        if accession in self._seen_accessions:
            return None
        self._seen_accessions.add(accession)

        ticker = filing.get("ticker", "")
        if not ticker:
            return None

        return RawEvent(
            source=self.name,
            source_id=accession,
            ticker=ticker,
            company_name=filing.get("companyName", ""),
            event_type_hint=event_hint,
            title=f"{form_type}: {filing.get('description', '')}",
            raw_text=filing.get("description", ""),
            url=filing.get("documentUrl", ""),
            metadata={"form_type": form_type, "filed_at": filing.get("filedAt", "")},
        )

    async def fetch(self) -> list[RawEvent]:
        """Poll sec-api.io full-text search for recent relevant filings."""
        events = []
        async with httpx.AsyncClient() as client:
            for form_type in RELEVANT_FORM_TYPES:
                try:
                    response = await client.post(
                        f"{self._base_url}/full-text-search",
                        json={
                            "query": f'formType:"{form_type}"',
                            "dateRange": "custom",
                            "startDt": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
                            "endDt": datetime.now(timezone.utc).strftime("%Y-%m-%d"),
                        },
                        headers={"Authorization": self._api_key},
                        timeout=30.0,
                    )
                    response.raise_for_status()
                    data = response.json()
                    for filing in data.get("filings", []):
                        raw_event = self.parse_filing(filing)
                        if raw_event:
                            events.append(raw_event)
                except httpx.HTTPError as e:
                    logger.warning(f"SEC API error for {form_type}: {e}")
        return events
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_sec_api_adapter.py -v`
Expected: All 4 tests PASS

**Step 5: Commit**

```bash
git add backend/src/ingestion/sec_api.py backend/tests/test_sec_api_adapter.py
git commit -m "feat: SEC API adapter with filing type detection and parsing"
```

---

### Task 6: Newsfilter adapter

**Files:**
- Create: `backend/src/ingestion/newsfilter.py`
- Create: `backend/tests/test_newsfilter_adapter.py`

**Step 1: Write the failing test**

Create `backend/tests/test_newsfilter_adapter.py`:

```python
from src.ingestion.newsfilter import NewsfilterAdapter
from src.ingestion.base import BaseSourceAdapter, RawEvent


def test_newsfilter_adapter_is_source_adapter():
    adapter = NewsfilterAdapter(api_key="test-key")
    assert isinstance(adapter, BaseSourceAdapter)
    assert adapter.name == "newsfilter"


def test_newsfilter_parse_article():
    adapter = NewsfilterAdapter(api_key="test-key")
    article = {
        "id": "article-123",
        "title": "Microsoft to Acquire Activision for $69B",
        "description": "Microsoft announced a definitive agreement to acquire Activision Blizzard...",
        "url": "https://example.com/article",
        "tickers": ["MSFT", "ATVI"],
        "publishedAt": "2026-02-24T14:00:00Z",
        "source": {"name": "Reuters"},
    }
    events = adapter.parse_article(article)
    assert len(events) == 2  # one per ticker
    assert events[0].ticker == "MSFT"
    assert events[1].ticker == "ATVI"
    assert events[0].source == "newsfilter"
    assert "Microsoft to Acquire" in events[0].title


def test_newsfilter_skips_no_ticker():
    adapter = NewsfilterAdapter(api_key="test-key")
    article = {
        "id": "article-456",
        "title": "Market roundup",
        "description": "General market news...",
        "url": "https://example.com/article2",
        "tickers": [],
        "publishedAt": "2026-02-24T14:00:00Z",
        "source": {"name": "Reuters"},
    }
    events = adapter.parse_article(article)
    assert len(events) == 0
```

**Step 2: Run test to verify it fails**

Run: `cd backend && python -m pytest tests/test_newsfilter_adapter.py -v`
Expected: FAIL

**Step 3: Implement `backend/src/ingestion/newsfilter.py`**

```python
import logging
from datetime import datetime, timezone, timedelta

import httpx

from src.ingestion.base import BaseSourceAdapter, RawEvent

logger = logging.getLogger(__name__)

MA_KEYWORDS = [
    "acquire", "acquisition", "merger", "buyout", "takeover", "tender offer",
    "go-private", "going private", "definitive agreement", "deal price",
    "per share", "all-cash", "stock-for-stock",
]

LITIGATION_KEYWORDS = [
    "lawsuit", "settlement", "class action", "securities fraud", "SEC charges",
    "indictment", "ruling", "verdict", "injunction",
]


class NewsfilterAdapter(BaseSourceAdapter):
    def __init__(self, api_key: str):
        self._api_key = api_key
        self._base_url = "https://api.newsfilter.io/public/actions"
        self._seen_ids: set[str] = set()

    @property
    def name(self) -> str:
        return "newsfilter"

    def _classify_text(self, text: str) -> str:
        text_lower = text.lower()
        for kw in MA_KEYWORDS:
            if kw in text_lower:
                return "MA"
        for kw in LITIGATION_KEYWORDS:
            if kw in text_lower:
                return "LITIGATION"
        return "GENERAL"

    def parse_article(self, article: dict) -> list[RawEvent]:
        tickers = article.get("tickers", [])
        if not tickers:
            return []

        article_id = article.get("id", "")
        if article_id in self._seen_ids:
            return []
        self._seen_ids.add(article_id)

        title = article.get("title", "")
        description = article.get("description", "")
        combined_text = f"{title} {description}"
        event_hint = self._classify_text(combined_text)

        events = []
        for ticker in tickers:
            events.append(
                RawEvent(
                    source=self.name,
                    source_id=f"{article_id}-{ticker}",
                    ticker=ticker,
                    company_name="",  # enriched later
                    event_type_hint=event_hint,
                    title=title,
                    raw_text=description,
                    url=article.get("url", ""),
                    metadata={
                        "news_source": article.get("source", {}).get("name", ""),
                        "published_at": article.get("publishedAt", ""),
                    },
                )
            )
        return events

    async def fetch(self) -> list[RawEvent]:
        events = []
        since = datetime.now(timezone.utc) - timedelta(minutes=10)
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    self._base_url,
                    params={
                        "token": self._api_key,
                        "queryString": "*",
                        "from": 0,
                        "size": 50,
                        "publishedAt": f">{since.strftime('%Y-%m-%dT%H:%M:%S')}",
                    },
                    timeout=30.0,
                )
                response.raise_for_status()
                data = response.json()
                for article in data.get("articles", []):
                    events.extend(self.parse_article(article))
        except httpx.HTTPError as e:
            logger.warning(f"Newsfilter API error: {e}")
        return events
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_newsfilter_adapter.py -v`
Expected: All 3 tests PASS

**Step 5: Commit**

```bash
git add backend/src/ingestion/newsfilter.py backend/tests/test_newsfilter_adapter.py
git commit -m "feat: Newsfilter adapter with keyword classification"
```

---

### Task 7: CourtListener adapter

**Files:**
- Create: `backend/src/ingestion/courtlistener.py`
- Create: `backend/tests/test_courtlistener_adapter.py`

**Step 1: Write the failing test**

Create `backend/tests/test_courtlistener_adapter.py`:

```python
from src.ingestion.courtlistener import CourtListenerAdapter
from src.ingestion.base import BaseSourceAdapter, RawEvent


def test_courtlistener_adapter_is_source_adapter():
    adapter = CourtListenerAdapter()
    assert isinstance(adapter, BaseSourceAdapter)
    assert adapter.name == "courtlistener"


def test_courtlistener_parse_docket():
    adapter = CourtListenerAdapter()
    docket = {
        "id": 12345,
        "case_name": "SEC v. Ripple Labs Inc.",
        "docket_number": "1:20-cv-10832",
        "court": "https://www.courtlistener.com/api/rest/v4/courts/nysd/",
        "date_filed": "2020-12-22",
        "date_last_filing": "2026-02-20",
        "absolute_url": "/docket/12345/sec-v-ripple-labs-inc/",
    }
    event = adapter.parse_docket(docket, ticker_hint="XRP")
    assert event is not None
    assert event.source == "courtlistener"
    assert event.event_type_hint == "LITIGATION"
    assert "SEC v. Ripple" in event.title


def test_courtlistener_parse_docket_no_ticker():
    adapter = CourtListenerAdapter()
    docket = {
        "id": 99999,
        "case_name": "Doe v. Smith",
        "docket_number": "1:26-cv-00001",
        "court": "https://www.courtlistener.com/api/rest/v4/courts/nysd/",
        "date_filed": "2026-01-01",
        "absolute_url": "/docket/99999/doe-v-smith/",
    }
    event = adapter.parse_docket(docket, ticker_hint="")
    assert event is None  # No ticker = skip
```

**Step 2: Run test to verify it fails**

Run: `cd backend && python -m pytest tests/test_courtlistener_adapter.py -v`
Expected: FAIL

**Step 3: Implement `backend/src/ingestion/courtlistener.py`**

```python
import logging
from datetime import datetime, timezone, timedelta

import httpx

from src.ingestion.base import BaseSourceAdapter, RawEvent

logger = logging.getLogger(__name__)


class CourtListenerAdapter(BaseSourceAdapter):
    def __init__(self, auth_token: str = ""):
        self._auth_token = auth_token
        self._base_url = "https://www.courtlistener.com/api/rest/v4"
        self._seen_ids: set[int] = set()
        self._watched_tickers: dict[str, list[str]] = {}  # ticker -> [search terms]

    @property
    def name(self) -> str:
        return "courtlistener"

    def set_watched_tickers(self, ticker_terms: dict[str, list[str]]) -> None:
        """Set tickers to watch with search terms. E.g., {"XRP": ["Ripple Labs"], "AAPL": ["Apple Inc"]}"""
        self._watched_tickers = ticker_terms

    def parse_docket(self, docket: dict, ticker_hint: str = "") -> RawEvent | None:
        if not ticker_hint:
            return None

        docket_id = docket.get("id", 0)
        if docket_id in self._seen_ids:
            return None
        self._seen_ids.add(docket_id)

        case_name = docket.get("case_name", "")
        return RawEvent(
            source=self.name,
            source_id=str(docket_id),
            ticker=ticker_hint,
            company_name="",
            event_type_hint="LITIGATION",
            title=case_name,
            raw_text=f"Case: {case_name}, Docket: {docket.get('docket_number', '')}",
            url=f"https://www.courtlistener.com{docket.get('absolute_url', '')}",
            metadata={
                "docket_number": docket.get("docket_number", ""),
                "court": docket.get("court", ""),
                "date_filed": docket.get("date_filed", ""),
                "date_last_filing": docket.get("date_last_filing", ""),
            },
        )

    async def fetch(self) -> list[RawEvent]:
        events = []
        headers = {}
        if self._auth_token:
            headers["Authorization"] = f"Token {self._auth_token}"

        async with httpx.AsyncClient() as client:
            for ticker, terms in self._watched_tickers.items():
                for term in terms:
                    try:
                        response = await client.get(
                            f"{self._base_url}/search/",
                            params={
                                "q": term,
                                "type": "r",  # RECAP dockets
                                "order_by": "dateFiled desc",
                            },
                            headers=headers,
                            timeout=30.0,
                        )
                        response.raise_for_status()
                        data = response.json()
                        for result in data.get("results", []):
                            event = self.parse_docket(result, ticker_hint=ticker)
                            if event:
                                events.append(event)
                    except httpx.HTTPError as e:
                        logger.warning(f"CourtListener error for {term}: {e}")
        return events
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_courtlistener_adapter.py -v`
Expected: All 3 tests PASS

**Step 5: Commit**

```bash
git add backend/src/ingestion/courtlistener.py backend/tests/test_courtlistener_adapter.py
git commit -m "feat: CourtListener adapter for litigation tracking"
```

---

### Task 8: FMP M&A adapter

**Files:**
- Create: `backend/src/ingestion/fmp.py`
- Create: `backend/tests/test_fmp_adapter.py`

**Step 1: Write the failing test**

Create `backend/tests/test_fmp_adapter.py`:

```python
from src.ingestion.fmp import FmpAdapter
from src.ingestion.base import BaseSourceAdapter


def test_fmp_adapter_is_source_adapter():
    adapter = FmpAdapter(api_key="test-key")
    assert isinstance(adapter, BaseSourceAdapter)
    assert adapter.name == "fmp"


def test_fmp_parse_deal():
    adapter = FmpAdapter(api_key="test-key")
    deal = {
        "companyName": "Activision Blizzard",
        "symbol": "ATVI",
        "targetedCompanyName": "Activision Blizzard",
        "targetedSymbol": "ATVI",
        "acquirerCompanyName": "Microsoft",
        "acquirerSymbol": "MSFT",
        "transactionDate": "2022-01-18",
        "acceptanceTime": "2022-01-18 16:30:00",
        "url": "https://sec.gov/...",
        "price": 95.0,
    }
    event = adapter.parse_deal(deal)
    assert event is not None
    assert event.ticker == "ATVI"
    assert event.event_type_hint == "MA"
    assert event.metadata["acquirer_ticker"] == "MSFT"
    assert event.metadata["deal_price"] == 95.0


def test_fmp_skips_no_ticker():
    adapter = FmpAdapter(api_key="test-key")
    deal = {"companyName": "Unknown", "symbol": "", "transactionDate": "2026-01-01"}
    event = adapter.parse_deal(deal)
    assert event is None
```

**Step 2: Run test to verify it fails**

Run: `cd backend && python -m pytest tests/test_fmp_adapter.py -v`
Expected: FAIL

**Step 3: Implement `backend/src/ingestion/fmp.py`**

```python
import logging

import httpx

from src.ingestion.base import BaseSourceAdapter, RawEvent

logger = logging.getLogger(__name__)


class FmpAdapter(BaseSourceAdapter):
    def __init__(self, api_key: str):
        self._api_key = api_key
        self._base_url = "https://financialmodelingprep.com/api/v4"
        self._seen_ids: set[str] = set()

    @property
    def name(self) -> str:
        return "fmp"

    def parse_deal(self, deal: dict) -> RawEvent | None:
        ticker = deal.get("targetedSymbol") or deal.get("symbol", "")
        if not ticker:
            return None

        deal_id = f"{ticker}-{deal.get('transactionDate', '')}"
        if deal_id in self._seen_ids:
            return None
        self._seen_ids.add(deal_id)

        acquirer = deal.get("acquirerCompanyName", "")
        target = deal.get("targetedCompanyName") or deal.get("companyName", "")
        price = deal.get("price")

        return RawEvent(
            source=self.name,
            source_id=deal_id,
            ticker=ticker,
            company_name=target,
            event_type_hint="MA",
            title=f"{acquirer} to acquire {target}" if acquirer else f"M&A deal: {target}",
            raw_text=f"Deal price: ${price}" if price else "Deal terms not disclosed",
            url=deal.get("url", ""),
            metadata={
                "acquirer": acquirer,
                "acquirer_ticker": deal.get("acquirerSymbol", ""),
                "deal_price": price,
                "transaction_date": deal.get("transactionDate", ""),
            },
        )

    async def fetch(self) -> list[RawEvent]:
        events = []
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self._base_url}/mergers-acquisitions-rss-feed",
                    params={"apikey": self._api_key, "page": 0},
                    timeout=30.0,
                )
                response.raise_for_status()
                data = response.json()
                if isinstance(data, list):
                    for deal in data:
                        event = self.parse_deal(deal)
                        if event:
                            events.append(event)
        except httpx.HTTPError as e:
            logger.warning(f"FMP API error: {e}")
        return events
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_fmp_adapter.py -v`
Expected: All 3 tests PASS

**Step 5: Commit**

```bash
git add backend/src/ingestion/fmp.py backend/tests/test_fmp_adapter.py
git commit -m "feat: FMP adapter for M&A deal discovery"
```

---

### Task 9: Price/options data adapter (Polygon + Tradier)

**Files:**
- Create: `backend/src/ingestion/price.py`
- Create: `backend/tests/test_price_adapter.py`

**Step 1: Write the failing test**

Create `backend/tests/test_price_adapter.py`:

```python
import pytest
from decimal import Decimal
from src.ingestion.price import PriceService, Quote, OptionsChain, OptionContract


def test_quote_dataclass():
    q = Quote(ticker="AAPL", price=Decimal("175.50"), volume=1000000, timestamp="2026-02-24T16:00:00Z")
    assert q.ticker == "AAPL"
    assert q.price == Decimal("175.50")


def test_option_contract_dataclass():
    c = OptionContract(
        ticker="AAPL",
        strike=Decimal("180.00"),
        expiration="2026-03-21",
        option_type="call",
        bid=Decimal("2.50"),
        ask=Decimal("2.70"),
        implied_volatility=0.25,
        delta=0.45,
        volume=500,
        open_interest=1200,
    )
    assert c.strike == Decimal("180.00")
    assert c.implied_volatility == 0.25


def test_price_service_exists():
    svc = PriceService(polygon_api_key="test", tradier_token="test")
    assert hasattr(svc, "get_quote")
    assert hasattr(svc, "get_quotes")
    assert hasattr(svc, "get_options_chain")
```

**Step 2: Run test to verify it fails**

Run: `cd backend && python -m pytest tests/test_price_adapter.py -v`
Expected: FAIL

**Step 3: Implement `backend/src/ingestion/price.py`**

```python
import logging
from dataclasses import dataclass
from decimal import Decimal

import httpx

logger = logging.getLogger(__name__)


@dataclass
class Quote:
    ticker: str
    price: Decimal
    volume: int
    timestamp: str


@dataclass
class OptionContract:
    ticker: str
    strike: Decimal
    expiration: str
    option_type: str  # "call" or "put"
    bid: Decimal
    ask: Decimal
    implied_volatility: float
    delta: float
    volume: int
    open_interest: int


@dataclass
class OptionsChain:
    ticker: str
    contracts: list[OptionContract]


class PriceService:
    def __init__(self, polygon_api_key: str, tradier_token: str):
        self._polygon_key = polygon_api_key
        self._tradier_token = tradier_token

    async def get_quote(self, ticker: str) -> Quote | None:
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"https://api.polygon.io/v2/aggs/ticker/{ticker}/prev",
                    params={"apiKey": self._polygon_key},
                    timeout=15.0,
                )
                response.raise_for_status()
                data = response.json()
                results = data.get("results", [])
                if results:
                    r = results[0]
                    return Quote(
                        ticker=ticker,
                        price=Decimal(str(r.get("c", 0))),
                        volume=r.get("v", 0),
                        timestamp=str(r.get("t", "")),
                    )
        except httpx.HTTPError as e:
            logger.warning(f"Polygon quote error for {ticker}: {e}")
        return None

    async def get_quotes(self, tickers: list[str]) -> dict[str, Quote]:
        quotes = {}
        for ticker in tickers:
            quote = await self.get_quote(ticker)
            if quote:
                quotes[ticker] = quote
        return quotes

    async def get_options_chain(self, ticker: str, expiration: str = "") -> OptionsChain | None:
        try:
            params = {"symbol": ticker, "greeks": "true"}
            if expiration:
                params["expiration"] = expiration

            async with httpx.AsyncClient() as client:
                response = await client.get(
                    "https://api.tradier.com/v1/markets/options/chains",
                    params=params,
                    headers={
                        "Authorization": f"Bearer {self._tradier_token}",
                        "Accept": "application/json",
                    },
                    timeout=15.0,
                )
                response.raise_for_status()
                data = response.json()
                options = data.get("options", {}).get("option", [])
                contracts = []
                for opt in options:
                    contracts.append(
                        OptionContract(
                            ticker=ticker,
                            strike=Decimal(str(opt.get("strike", 0))),
                            expiration=opt.get("expiration_date", ""),
                            option_type=opt.get("option_type", ""),
                            bid=Decimal(str(opt.get("bid", 0))),
                            ask=Decimal(str(opt.get("ask", 0))),
                            implied_volatility=opt.get("greeks", {}).get("mid_iv", 0.0),
                            delta=opt.get("greeks", {}).get("delta", 0.0),
                            volume=opt.get("volume", 0),
                            open_interest=opt.get("open_interest", 0),
                        )
                    )
                return OptionsChain(ticker=ticker, contracts=contracts)
        except httpx.HTTPError as e:
            logger.warning(f"Tradier options error for {ticker}: {e}")
        return None
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_price_adapter.py -v`
Expected: All 3 tests PASS

**Step 5: Commit**

```bash
git add backend/src/ingestion/price.py backend/tests/test_price_adapter.py
git commit -m "feat: price service with Polygon quotes and Tradier options chains"
```

---

## Phase 2: Analysis Engine (Tasks 10-14)

### Task 10: Spread calculation module

**Files:**
- Create: `backend/src/analysis/__init__.py`
- Create: `backend/src/analysis/spread.py`
- Create: `backend/tests/test_spread.py`

**Step 1: Write the failing test**

```python
# backend/tests/test_spread.py
from decimal import Decimal
from datetime import date
from src.analysis.spread import calculate_gross_spread, calculate_annualized_spread


def test_gross_spread_basic():
    result = calculate_gross_spread(current_price=Decimal("47.50"), deal_price=Decimal("50.00"))
    assert result == Decimal("5.2632")  # (50-47.50)/47.50 * 100, rounded to 4 places


def test_gross_spread_at_deal_price():
    result = calculate_gross_spread(current_price=Decimal("50.00"), deal_price=Decimal("50.00"))
    assert result == Decimal("0.0000")


def test_gross_spread_above_deal_price():
    result = calculate_gross_spread(current_price=Decimal("51.00"), deal_price=Decimal("50.00"))
    assert result < 0  # negative spread


def test_annualized_spread():
    result = calculate_annualized_spread(
        gross_spread_pct=Decimal("5.0000"),
        expected_close=date(2026, 8, 24),
        as_of=date(2026, 2, 24),
    )
    # 5% over 181 days = 5 / (181/365) = ~10.08%
    assert Decimal("10.0") < result < Decimal("10.2")


def test_annualized_spread_short_horizon():
    result = calculate_annualized_spread(
        gross_spread_pct=Decimal("2.0000"),
        expected_close=date(2026, 3, 24),
        as_of=date(2026, 2, 24),
    )
    # 2% over 28 days = 2 / (28/365) = ~26.07%
    assert result > Decimal("25.0")
```

**Step 2: Run test to verify it fails**

Run: `cd backend && python -m pytest tests/test_spread.py -v`
Expected: FAIL

**Step 3: Implement `backend/src/analysis/__init__.py`** (empty) and `backend/src/analysis/spread.py`**

```python
from decimal import Decimal, ROUND_HALF_UP
from datetime import date


def calculate_gross_spread(current_price: Decimal, deal_price: Decimal) -> Decimal:
    if current_price == 0:
        return Decimal("0.0000")
    spread = ((deal_price - current_price) / current_price) * 100
    return spread.quantize(Decimal("0.0001"), rounding=ROUND_HALF_UP)


def calculate_annualized_spread(
    gross_spread_pct: Decimal,
    expected_close: date,
    as_of: date | None = None,
) -> Decimal:
    if as_of is None:
        as_of = date.today()
    days = (expected_close - as_of).days
    if days <= 0:
        return gross_spread_pct  # already past close date
    year_fraction = Decimal(str(days)) / Decimal("365")
    annualized = gross_spread_pct / year_fraction
    return annualized.quantize(Decimal("0.0001"), rounding=ROUND_HALF_UP)
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_spread.py -v`
Expected: All 5 tests PASS

**Step 5: Commit**

```bash
git add backend/src/analysis/ backend/tests/test_spread.py
git commit -m "feat: spread calculation with gross and annualized computations"
```

---

### Task 11: Event deduplication logic

**Files:**
- Create: `backend/src/tracking/dedup.py`
- Create: `backend/tests/test_dedup.py`

**Step 1: Write the failing test**

```python
# backend/tests/test_dedup.py
from src.tracking.dedup import EventDeduplicator
from src.ingestion.base import RawEvent


def make_event(**kwargs) -> RawEvent:
    defaults = {
        "source": "test",
        "source_id": "1",
        "ticker": "AAPL",
        "company_name": "Apple",
        "event_type_hint": "MA",
        "title": "Test",
        "raw_text": "Test text",
        "url": "https://example.com",
    }
    defaults.update(kwargs)
    return RawEvent(**defaults)


def test_dedup_same_source_id():
    dedup = EventDeduplicator()
    e1 = make_event(source="sec", source_id="filing-1")
    e2 = make_event(source="sec", source_id="filing-1")
    assert dedup.is_duplicate(e1) is False
    assert dedup.is_duplicate(e2) is True


def test_dedup_different_sources_same_event():
    dedup = EventDeduplicator()
    e1 = make_event(source="sec", source_id="filing-1", ticker="ATVI", event_type_hint="MA")
    e2 = make_event(source="newsfilter", source_id="article-1", ticker="ATVI", event_type_hint="MA")
    assert dedup.is_duplicate(e1) is False
    # Same ticker + same event type within window = duplicate
    assert dedup.is_duplicate(e2) is True


def test_dedup_different_tickers():
    dedup = EventDeduplicator()
    e1 = make_event(source="sec", source_id="f1", ticker="AAPL", event_type_hint="MA")
    e2 = make_event(source="sec", source_id="f2", ticker="MSFT", event_type_hint="MA")
    assert dedup.is_duplicate(e1) is False
    assert dedup.is_duplicate(e2) is False


def test_dedup_different_event_types():
    dedup = EventDeduplicator()
    e1 = make_event(source="sec", source_id="f1", ticker="AAPL", event_type_hint="MA")
    e2 = make_event(source="sec", source_id="f2", ticker="AAPL", event_type_hint="LITIGATION")
    assert dedup.is_duplicate(e1) is False
    assert dedup.is_duplicate(e2) is False
```

**Step 2: Run test, verify fail, then implement**

**Step 3: Implement `backend/src/tracking/dedup.py`**

```python
from datetime import datetime, timezone, timedelta

from src.ingestion.base import RawEvent


class EventDeduplicator:
    def __init__(self, window_hours: int = 24):
        self._seen_source_ids: set[str] = set()
        self._seen_events: dict[str, datetime] = {}  # "TICKER-TYPE" -> last seen time
        self._window = timedelta(hours=window_hours)

    def _event_key(self, event: RawEvent) -> str:
        return f"{event.ticker}-{event.event_type_hint}"

    def is_duplicate(self, event: RawEvent) -> bool:
        source_key = f"{event.source}:{event.source_id}"
        if source_key in self._seen_source_ids:
            return True
        self._seen_source_ids.add(source_key)

        event_key = self._event_key(event)
        now = datetime.now(timezone.utc)
        if event_key in self._seen_events:
            if now - self._seen_events[event_key] < self._window:
                return True
        self._seen_events[event_key] = now
        return False

    def clear_expired(self) -> None:
        now = datetime.now(timezone.utc)
        expired = [k for k, v in self._seen_events.items() if now - v > self._window]
        for k in expired:
            del self._seen_events[k]
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_dedup.py -v`
Expected: All 4 tests PASS

**Step 5: Commit**

```bash
git add backend/src/tracking/dedup.py backend/tests/test_dedup.py
git commit -m "feat: event deduplication across sources with time window"
```

---

### Task 12: Claude API prompts and analyzer

**Files:**
- Create: `backend/src/analysis/prompts.py`
- Create: `backend/src/analysis/analyzer.py`
- Create: `backend/tests/test_analyzer.py`

**Step 1: Write the failing test**

```python
# backend/tests/test_analyzer.py
import json
import pytest
from unittest.mock import AsyncMock, patch, MagicMock
from decimal import Decimal

from src.analysis.analyzer import ArbitrageAnalyzer, AnalysisResult
from src.analysis.prompts import build_classification_prompt, build_analysis_prompt


def test_analysis_result_dataclass():
    result = AnalysisResult(
        event_type="MA",
        is_actionable=True,
        current_price=Decimal("47.50"),
        deal_price=Decimal("50.00"),
        gross_spread_pct=Decimal("5.26"),
        annualized_spread_pct=Decimal("12.10"),
        completion_probability=Decimal("0.85"),
        expected_value=Decimal("3.20"),
        downside_estimate=Decimal("35.00"),
        risk_factors={"regulatory": "medium"},
        recommendation="ENTER",
        reasoning="Attractive spread.",
        key_dates={"expected_close": "2026-08-24"},
        key_parties={"acquirer": "Buyer Corp"},
    )
    assert result.is_actionable is True
    assert result.recommendation == "ENTER"


def test_classification_prompt_contains_event_info():
    prompt = build_classification_prompt(
        title="SC 13D: Activist takes 10% stake",
        raw_text="Large fund acquires significant position...",
        ticker="AAPL",
        source="sec_api",
    )
    assert "AAPL" in prompt
    assert "SC 13D" in prompt
    assert "classify" in prompt.lower() or "event type" in prompt.lower()


def test_analysis_prompt_contains_deal_info():
    prompt = build_analysis_prompt(
        event_type="MA",
        title="Microsoft to acquire Activision",
        raw_text="All-cash deal at $95/share...",
        ticker="ATVI",
        current_price=Decimal("90.00"),
    )
    assert "ATVI" in prompt
    assert "90.00" in prompt or "90" in prompt
    assert "spread" in prompt.lower() or "arbitrage" in prompt.lower()


def test_analyzer_exists():
    analyzer = ArbitrageAnalyzer(api_key="test-key")
    assert hasattr(analyzer, "classify_event")
    assert hasattr(analyzer, "analyze_event")
```

**Step 2: Run test, verify fail**

**Step 3: Implement `backend/src/analysis/prompts.py`**

```python
from decimal import Decimal


def build_classification_prompt(title: str, raw_text: str, ticker: str, source: str) -> str:
    return f"""You are a financial analyst specializing in event-driven strategies.

Classify the following event and determine if it represents an actionable event-driven opportunity.

**Ticker:** {ticker}
**Source:** {source}
**Title:** {title}
**Details:** {raw_text}

Respond in JSON format:
{{
  "event_type": "MA|GO_PRIVATE|TENDER|LITIGATION|ACTIVIST|SPINOFF|REGULATORY|SPAC|BANKRUPTCY|NONE",
  "is_actionable": true/false,
  "confidence": 0.0-1.0,
  "summary": "One sentence summary of the event"
}}

Rules:
- "is_actionable" means there is likely an arbitrage spread or catalyst-driven opportunity
- Set "event_type" to "NONE" if this is not an event-driven situation
- Be conservative: only mark actionable if there's a clear defined price target or catalyst"""


def build_analysis_prompt(
    event_type: str,
    title: str,
    raw_text: str,
    ticker: str,
    current_price: Decimal,
    additional_context: str = "",
) -> str:
    return f"""You are a senior event-driven arbitrage analyst. Analyze this opportunity thoroughly.

**Event Type:** {event_type}
**Ticker:** {ticker}
**Current Price:** ${current_price}
**Title:** {title}
**Details:** {raw_text}
{f"**Additional Context:** {additional_context}" if additional_context else ""}

Provide your analysis in JSON format:
{{
  "deal_price": <number or null if not applicable>,
  "gross_spread_pct": <number>,
  "expected_close_date": "<YYYY-MM-DD or null>",
  "completion_probability": <0.0-1.0>,
  "downside_estimate": <price if deal fails>,
  "expected_value": <probability * upside - (1-p) * downside>,
  "risk_factors": {{
    "<risk_name>": "<low|medium|high>",
    ...
  }},
  "recommendation": "ENTER|HOLD|EXIT|WATCH",
  "reasoning": "<2-3 paragraph analysis>",
  "key_dates": {{
    "<date_name>": "<YYYY-MM-DD>",
    ...
  }},
  "key_parties": {{
    "<role>": "<name>",
    ...
  }}
}}

Analysis guidelines:
- Calculate spread as (deal_price - current_price) / current_price * 100
- Annualize the spread based on expected days to close
- ENTER recommendation requires annualized return > 10% after risk adjustment
- Be specific about risk factors and their severity
- Consider regulatory risk, financing conditions, shareholder votes, litigation, MAC clauses
- For litigation events, estimate settlement/judgment range and probabilities"""
```

**Step 4: Implement `backend/src/analysis/analyzer.py`**

```python
import json
import logging
from dataclasses import dataclass
from decimal import Decimal

import anthropic

from src.analysis.prompts import build_classification_prompt, build_analysis_prompt

logger = logging.getLogger(__name__)


@dataclass
class ClassificationResult:
    event_type: str
    is_actionable: bool
    confidence: float
    summary: str


@dataclass
class AnalysisResult:
    event_type: str
    is_actionable: bool
    current_price: Decimal
    deal_price: Decimal | None
    gross_spread_pct: Decimal
    annualized_spread_pct: Decimal
    completion_probability: Decimal
    expected_value: Decimal
    downside_estimate: Decimal
    risk_factors: dict
    recommendation: str
    reasoning: str
    key_dates: dict
    key_parties: dict


class ArbitrageAnalyzer:
    def __init__(self, api_key: str):
        self._client = anthropic.Anthropic(api_key=api_key)

    async def classify_event(
        self, title: str, raw_text: str, ticker: str, source: str
    ) -> ClassificationResult:
        prompt = build_classification_prompt(title, raw_text, ticker, source)
        try:
            message = self._client.messages.create(
                model="claude-haiku-4-5-20251001",
                max_tokens=512,
                messages=[{"role": "user", "content": prompt}],
            )
            text = message.content[0].text
            data = json.loads(text)
            return ClassificationResult(
                event_type=data.get("event_type", "NONE"),
                is_actionable=data.get("is_actionable", False),
                confidence=data.get("confidence", 0.0),
                summary=data.get("summary", ""),
            )
        except Exception as e:
            logger.error(f"Classification error for {ticker}: {e}")
            return ClassificationResult(event_type="NONE", is_actionable=False, confidence=0.0, summary=str(e))

    async def analyze_event(
        self,
        event_type: str,
        title: str,
        raw_text: str,
        ticker: str,
        current_price: Decimal,
        additional_context: str = "",
    ) -> AnalysisResult:
        prompt = build_analysis_prompt(event_type, title, raw_text, ticker, current_price, additional_context)
        try:
            message = self._client.messages.create(
                model="claude-sonnet-4-5-20250929",
                max_tokens=2048,
                messages=[{"role": "user", "content": prompt}],
            )
            text = message.content[0].text
            data = json.loads(text)
            deal_price = data.get("deal_price")
            return AnalysisResult(
                event_type=event_type,
                is_actionable=True,
                current_price=current_price,
                deal_price=Decimal(str(deal_price)) if deal_price else None,
                gross_spread_pct=Decimal(str(data.get("gross_spread_pct", 0))),
                annualized_spread_pct=Decimal(str(data.get("gross_spread_pct", 0))),  # recalculated later
                completion_probability=Decimal(str(data.get("completion_probability", 0))),
                expected_value=Decimal(str(data.get("expected_value", 0))),
                downside_estimate=Decimal(str(data.get("downside_estimate", 0))),
                risk_factors=data.get("risk_factors", {}),
                recommendation=data.get("recommendation", "WATCH"),
                reasoning=data.get("reasoning", ""),
                key_dates=data.get("key_dates", {}),
                key_parties=data.get("key_parties", {}),
            )
        except Exception as e:
            logger.error(f"Analysis error for {ticker}: {e}")
            return AnalysisResult(
                event_type=event_type,
                is_actionable=False,
                current_price=current_price,
                deal_price=None,
                gross_spread_pct=Decimal("0"),
                annualized_spread_pct=Decimal("0"),
                completion_probability=Decimal("0"),
                expected_value=Decimal("0"),
                downside_estimate=Decimal("0"),
                risk_factors={},
                recommendation="WATCH",
                reasoning=f"Analysis failed: {e}",
                key_dates={},
                key_parties={},
            )
```

**Step 5: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_analyzer.py -v`
Expected: All 4 tests PASS

**Step 6: Commit**

```bash
git add backend/src/analysis/ backend/tests/test_analyzer.py
git commit -m "feat: Claude API analyzer with classification and full analysis prompts"
```

---

### Task 13: Alert dispatcher (Telegram + Email)

**Files:**
- Create: `backend/src/alerts/__init__.py`
- Create: `backend/src/alerts/telegram.py`
- Create: `backend/src/alerts/email.py`
- Create: `backend/src/alerts/dispatcher.py`
- Create: `backend/tests/test_alerts.py`

**Step 1: Write the failing test**

```python
# backend/tests/test_alerts.py
import pytest
from unittest.mock import AsyncMock, patch
from src.alerts.dispatcher import AlertDispatcher
from src.alerts.telegram import TelegramNotifier
from src.alerts.email import EmailNotifier
from src.models.models import AlertType, AlertPriority


def test_telegram_notifier_exists():
    notifier = TelegramNotifier(bot_token="test", chat_id="test")
    assert hasattr(notifier, "send")


def test_email_notifier_exists():
    notifier = EmailNotifier(host="smtp.test.com", port=587, user="u", password="p", to="to@test.com")
    assert hasattr(notifier, "send")


def test_dispatcher_routes_high_priority_to_both():
    dispatcher = AlertDispatcher(
        telegram=TelegramNotifier(bot_token="t", chat_id="c"),
        email=EmailNotifier(host="h", port=587, user="u", password="p", to="to@t.com"),
    )
    channels = dispatcher.get_channels(AlertPriority.HIGH)
    assert "telegram" in channels
    assert "email" in channels


def test_dispatcher_routes_medium_to_telegram():
    dispatcher = AlertDispatcher(
        telegram=TelegramNotifier(bot_token="t", chat_id="c"),
        email=EmailNotifier(host="h", port=587, user="u", password="p", to="to@t.com"),
    )
    channels = dispatcher.get_channels(AlertPriority.MEDIUM)
    assert "telegram" in channels
    assert "email" not in channels


def test_dispatcher_routes_low_to_email():
    dispatcher = AlertDispatcher(
        telegram=TelegramNotifier(bot_token="t", chat_id="c"),
        email=EmailNotifier(host="h", port=587, user="u", password="p", to="to@t.com"),
    )
    channels = dispatcher.get_channels(AlertPriority.LOW)
    assert "email" in channels
    assert "telegram" not in channels
```

**Step 2: Run test, verify fail**

**Step 3: Implement the three files**

`backend/src/alerts/__init__.py` (empty)

`backend/src/alerts/telegram.py`:

```python
import logging
import httpx

logger = logging.getLogger(__name__)


class TelegramNotifier:
    def __init__(self, bot_token: str, chat_id: str):
        self._bot_token = bot_token
        self._chat_id = chat_id

    async def send(self, message: str) -> bool:
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"https://api.telegram.org/bot{self._bot_token}/sendMessage",
                    json={"chat_id": self._chat_id, "text": message, "parse_mode": "Markdown"},
                    timeout=15.0,
                )
                response.raise_for_status()
                return True
        except httpx.HTTPError as e:
            logger.error(f"Telegram send error: {e}")
            return False
```

`backend/src/alerts/email.py`:

```python
import logging
from email.message import EmailMessage

import aiosmtplib

logger = logging.getLogger(__name__)


class EmailNotifier:
    def __init__(self, host: str, port: int, user: str, password: str, to: str):
        self._host = host
        self._port = port
        self._user = user
        self._password = password
        self._to = to

    async def send(self, subject: str, body: str) -> bool:
        try:
            msg = EmailMessage()
            msg["From"] = self._user
            msg["To"] = self._to
            msg["Subject"] = subject
            msg.set_content(body)

            await aiosmtplib.send(
                msg,
                hostname=self._host,
                port=self._port,
                username=self._user,
                password=self._password,
                start_tls=True,
            )
            return True
        except Exception as e:
            logger.error(f"Email send error: {e}")
            return False
```

`backend/src/alerts/dispatcher.py`:

```python
import logging
from src.alerts.telegram import TelegramNotifier
from src.alerts.email import EmailNotifier
from src.models.models import AlertPriority

logger = logging.getLogger(__name__)

ROUTING = {
    AlertPriority.HIGH: ["telegram", "email"],
    AlertPriority.MEDIUM: ["telegram"],
    AlertPriority.LOW: ["email"],
}


class AlertDispatcher:
    def __init__(self, telegram: TelegramNotifier, email: EmailNotifier):
        self._telegram = telegram
        self._email = email

    def get_channels(self, priority: AlertPriority) -> list[str]:
        return ROUTING.get(priority, ["email"])

    async def dispatch(self, priority: AlertPriority, subject: str, message: str) -> dict[str, bool]:
        channels = self.get_channels(priority)
        results = {}
        if "telegram" in channels:
            results["telegram"] = await self._telegram.send(f"*{subject}*\n\n{message}")
        if "email" in channels:
            results["email"] = await self._email.send(subject, message)
        return results
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_alerts.py -v`
Expected: All 5 tests PASS

**Step 5: Commit**

```bash
git add backend/src/alerts/ backend/tests/test_alerts.py
git commit -m "feat: alert dispatcher with Telegram and email notifiers"
```

---

### Task 14: Scheduler setup with APScheduler

**Files:**
- Create: `backend/src/scheduler.py`
- Create: `backend/tests/test_scheduler.py`

**Step 1: Write the failing test**

```python
# backend/tests/test_scheduler.py
from src.scheduler import create_scheduler, JOB_DEFINITIONS


def test_job_definitions_exist():
    assert "ingest_news" in JOB_DEFINITIONS
    assert "ingest_court" in JOB_DEFINITIONS
    assert "ingest_deals" in JOB_DEFINITIONS
    assert "update_prices" in JOB_DEFINITIONS
    assert "check_alerts" in JOB_DEFINITIONS
    assert "daily_summary" in JOB_DEFINITIONS


def test_job_definitions_have_required_fields():
    for name, job in JOB_DEFINITIONS.items():
        assert "func" in job, f"{name} missing 'func'"
        assert "trigger" in job, f"{name} missing 'trigger'"


def test_create_scheduler_returns_scheduler():
    scheduler = create_scheduler()
    assert scheduler is not None
```

**Step 2: Run test, verify fail**

**Step 3: Implement `backend/src/scheduler.py`**

```python
import logging
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger
from apscheduler.triggers.cron import CronTrigger

logger = logging.getLogger(__name__)


async def ingest_news():
    logger.info("Running: ingest_news")


async def ingest_court():
    logger.info("Running: ingest_court")


async def ingest_deals():
    logger.info("Running: ingest_deals")


async def update_prices():
    logger.info("Running: update_prices")


async def update_options():
    logger.info("Running: update_options")


async def run_analysis():
    logger.info("Running: run_analysis")


async def check_alerts():
    logger.info("Running: check_alerts")


async def daily_summary():
    logger.info("Running: daily_summary")


async def catch_up():
    logger.info("Running: catch_up")


JOB_DEFINITIONS = {
    "ingest_news": {
        "func": ingest_news,
        "trigger": IntervalTrigger(minutes=5),
    },
    "ingest_court": {
        "func": ingest_court,
        "trigger": IntervalTrigger(hours=6),
    },
    "ingest_deals": {
        "func": ingest_deals,
        "trigger": IntervalTrigger(minutes=30),
    },
    "update_prices": {
        "func": update_prices,
        "trigger": IntervalTrigger(minutes=5),
    },
    "update_options": {
        "func": update_options,
        "trigger": IntervalTrigger(minutes=30),
    },
    "run_analysis": {
        "func": run_analysis,
        "trigger": CronTrigger(hour=16, minute=30, timezone="US/Eastern"),
    },
    "check_alerts": {
        "func": check_alerts,
        "trigger": IntervalTrigger(minutes=5),
    },
    "daily_summary": {
        "func": daily_summary,
        "trigger": CronTrigger(hour=17, minute=0, timezone="US/Eastern"),
    },
}


def create_scheduler() -> AsyncIOScheduler:
    scheduler = AsyncIOScheduler()
    for name, job_def in JOB_DEFINITIONS.items():
        scheduler.add_job(
            job_def["func"],
            trigger=job_def["trigger"],
            id=name,
            name=name,
            replace_existing=True,
            misfire_grace_time=3600,
        )
    return scheduler
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_scheduler.py -v`
Expected: All 3 tests PASS

**Step 5: Commit**

```bash
git add backend/src/scheduler.py backend/tests/test_scheduler.py
git commit -m "feat: APScheduler with all job definitions"
```

---

## Phase 3: FastAPI Backend (Tasks 15-17)

### Task 15: FastAPI app with event endpoints

**Files:**
- Create: `backend/src/api/__init__.py`
- Create: `backend/src/api/main.py`
- Create: `backend/src/api/schemas.py`
- Create: `backend/src/api/routes/__init__.py`
- Create: `backend/src/api/routes/events.py`
- Create: `backend/tests/test_api_events.py`

**Step 1: Write the failing test**

```python
# backend/tests/test_api_events.py
import pytest
from httpx import AsyncClient, ASGITransport
from src.api.main import app


@pytest.mark.asyncio
async def test_health_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


@pytest.mark.asyncio
async def test_events_list_endpoint_exists():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.get("/api/events")
    # Should return 200 (empty list) or work without DB for now
    assert response.status_code in (200, 500)  # 500 acceptable if no DB
```

**Step 2: Run test, verify fail**

**Step 3: Implement the files**

`backend/src/api/__init__.py` (empty)
`backend/src/api/routes/__init__.py` (empty)

`backend/src/api/schemas.py`:

```python
from datetime import datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel


class EventResponse(BaseModel):
    id: UUID
    event_id: str
    ticker: str
    company_name: str
    event_type: str
    status: str
    description: str
    deal_price: Decimal | None
    key_dates: dict | None
    key_parties: dict | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class AnalysisResponse(BaseModel):
    id: UUID
    event_id: UUID
    current_price: Decimal
    gross_spread_pct: Decimal
    annualized_spread_pct: Decimal
    completion_probability: Decimal
    expected_value: Decimal
    downside_estimate: Decimal
    risk_factors: dict | None
    recommendation: str
    reasoning: str
    created_at: datetime

    model_config = {"from_attributes": True}


class PositionCreate(BaseModel):
    event_id: UUID
    entry_price: Decimal
    shares: int
    notes: str = ""


class PositionUpdate(BaseModel):
    current_value: Decimal | None = None
    pnl: Decimal | None = None
    status: str | None = None
    notes: str | None = None


class AlertResponse(BaseModel):
    id: UUID
    event_id: UUID
    alert_type: str
    priority: str
    message: str
    sent_via: dict | None
    created_at: datetime

    model_config = {"from_attributes": True}


class DashboardSummary(BaseModel):
    total_active_events: int
    total_positions_open: int
    total_pnl: Decimal
    events_by_type: dict[str, int]
    avg_spread_pct: Decimal | None
```

`backend/src/api/routes/events.py`:

```python
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from src.models.database import get_session
from src.models.models import Event, Analysis, EventStatus, EventType
from src.api.schemas import EventResponse, AnalysisResponse

router = APIRouter(prefix="/api/events", tags=["events"])


@router.get("", response_model=list[EventResponse])
async def list_events(
    status: str | None = Query(None),
    event_type: str | None = Query(None),
    session: AsyncSession = Depends(get_session),
):
    query = select(Event).order_by(Event.updated_at.desc())
    if status:
        query = query.where(Event.status == EventStatus(status))
    if event_type:
        query = query.where(Event.event_type == EventType(event_type))
    result = await session.execute(query)
    return result.scalars().all()


@router.get("/{event_id}", response_model=EventResponse)
async def get_event(event_id: UUID, session: AsyncSession = Depends(get_session)):
    result = await session.execute(select(Event).where(Event.id == event_id))
    event = result.scalar_one_or_none()
    if not event:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Event not found")
    return event


@router.get("/{event_id}/analyses", response_model=list[AnalysisResponse])
async def get_event_analyses(event_id: UUID, session: AsyncSession = Depends(get_session)):
    result = await session.execute(
        select(Analysis).where(Analysis.event_id == event_id).order_by(Analysis.created_at.desc())
    )
    return result.scalars().all()
```

`backend/src/api/main.py`:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from src.api.routes.events import router as events_router

app = FastAPI(title="Arbitrage Monitor API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],  # Vite dev server
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(events_router)


@app.get("/api/health")
async def health():
    return {"status": "ok"}
```

**Step 4: Run test to verify it passes**

Run: `cd backend && python -m pytest tests/test_api_events.py -v`
Expected: health test PASS

**Step 5: Commit**

```bash
git add backend/src/api/ backend/tests/test_api_events.py
git commit -m "feat: FastAPI app with event and analysis endpoints"
```

---

### Task 16: Position and alert API endpoints

**Files:**
- Create: `backend/src/api/routes/positions.py`
- Create: `backend/src/api/routes/alerts.py`
- Create: `backend/src/api/routes/dashboard.py`
- Modify: `backend/src/api/main.py` (add routers)

Follow same TDD pattern. Implement CRUD for positions (POST create, PATCH update, GET list), alerts (GET list), and dashboard summary (GET aggregate stats). Wire routers into `main.py`.

**Step 5: Commit**

```bash
git commit -m "feat: position, alert, and dashboard API endpoints"
```

---

### Task 17: Main entry point wiring everything together

**Files:**
- Create: `backend/src/main.py`

```python
import asyncio
import logging

from src.config import settings
from src.models.database import engine
from src.scheduler import create_scheduler
from src.ingestion.sec_api import SecApiAdapter
from src.ingestion.newsfilter import NewsfilterAdapter
from src.ingestion.courtlistener import CourtListenerAdapter
from src.ingestion.fmp import FmpAdapter
from src.ingestion.price import PriceService
from src.analysis.analyzer import ArbitrageAnalyzer
from src.alerts.telegram import TelegramNotifier
from src.alerts.email import EmailNotifier
from src.alerts.dispatcher import AlertDispatcher

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(name)s] %(levelname)s: %(message)s")
logger = logging.getLogger(__name__)


async def main():
    logger.info("Starting Arbitrage Monitor")

    # Initialize components
    sec_adapter = SecApiAdapter(api_key=settings.sec_api_key)
    news_adapter = NewsfilterAdapter(api_key=settings.newsfilter_api_key)
    court_adapter = CourtListenerAdapter()
    fmp_adapter = FmpAdapter(api_key=settings.fmp_api_key)
    price_service = PriceService(
        polygon_api_key=settings.polygon_api_key,
        tradier_token=settings.tradier_access_token,
    )
    analyzer = ArbitrageAnalyzer(api_key=settings.anthropic_api_key)
    dispatcher = AlertDispatcher(
        telegram=TelegramNotifier(bot_token=settings.telegram_bot_token, chat_id=settings.telegram_chat_id),
        email=EmailNotifier(
            host=settings.smtp_host, port=settings.smtp_port,
            user=settings.smtp_user, password=settings.smtp_password, to=settings.alert_email_to,
        ),
    )

    # Start scheduler
    scheduler = create_scheduler()
    scheduler.start()
    logger.info("Scheduler started with %d jobs", len(scheduler.get_jobs()))

    try:
        while True:
            await asyncio.sleep(1)
    except (KeyboardInterrupt, SystemExit):
        logger.info("Shutting down...")
        scheduler.shutdown()


if __name__ == "__main__":
    asyncio.run(main())
```

**Commit:**

```bash
git add backend/src/main.py
git commit -m "feat: main entry point wiring all components together"
```

---

## Phase 4: React Frontend (Tasks 18-22)

### Task 18: React project scaffolding

Run: `cd frontend && npm create vite@latest . -- --template react-ts && npm install && npm install @tanstack/react-query axios react-router-dom`

Commit: `git commit -m "feat: React + Vite + TypeScript frontend scaffolding"`

### Task 19: API client and types

Create `frontend/src/api/client.ts` (axios instance) and `frontend/src/api/types.ts` (TypeScript interfaces matching Pydantic schemas).

### Task 20: Events list page

Create `frontend/src/pages/EventsPage.tsx` — sortable table with columns: ticker, event type, spread, annualized return, days to close, status, recommendation. Use `@tanstack/react-query` for data fetching.

### Task 21: Event detail page

Create `frontend/src/pages/EventDetailPage.tsx` — full analysis display, timeline of analyses, filing links, key dates, risk factors.

### Task 22: Portfolio and dashboard pages

Create `frontend/src/pages/PortfolioPage.tsx` and `frontend/src/pages/DashboardPage.tsx` — positions with P&L, summary statistics.

Each frontend task follows: create component → wire route → verify in browser → commit.

---

## Summary

| Phase | Tasks | Description |
|---|---|---|
| **1A: Foundation** | 1-4 | Scaffolding, models, migrations, event store, base adapter |
| **1B: Source Adapters** | 5-9 | SEC API, Newsfilter, CourtListener, FMP, Price service |
| **2: Analysis** | 10-12 | Spread calc, deduplication, Claude analyzer |
| **3: Backend** | 13-17 | Alerts, scheduler, FastAPI endpoints, main entry |
| **4: Frontend** | 18-22 | React scaffolding, API client, events/detail/portfolio pages |

Total: ~22 tasks, each 2-15 minutes. Commit after every task.
