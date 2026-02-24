# Event-Driven Stock Arbitrage Monitoring System — Design

## Overview

A fully automated system that discovers US stock event-driven opportunities (M&A, go-private, tender offers, litigation), analyzes arbitrage risk/reward, tracks event lifecycles, and alerts when action is needed.

**Target user**: Active trader with event-driven experience, seeking to automate and scale coverage.
**Runtime environment**: Local Mac (intermittent availability — must handle sleep/wake gracefully).
**Budget**: ~$94/mo for data sources + ~$30-50/mo for Claude API usage.

---

## Data Source Stack ($94/mo)

| Component | Provider | Cost | Purpose |
|---|---|---|---|
| SEC Filings (real-time) | sec-api.io Personal | $55/mo | WebSocket streaming for 13D, 8-K, DEFM14A, SC TO filings (~300ms latency) |
| SEC Filings (parsing) | edgartools | $0 | Python library for extracting structured data from filings |
| Financial News | Newsfilter.io | ~$10/mo | M&A-specific news, <500ms latency, NLP ticker tagging |
| Market Data | Polygon.io Starter | $29/mo | Reliable delayed prices (15-min), 5yr history, unlimited calls |
| Options Data | Tradier (free account) | $0 | Options chains with Greeks/IV for implied probability analysis |
| Litigation | CourtListener API | $0 | RECAP search alerts for federal securities cases (5K queries/hr) |
| M&A Enrichment | Financial Modeling Prep (free) | $0 | Supplemental M&A deal search API |

### Data source design principles

- Each source is a separate Python module implementing a common adapter interface.
- Sources can be enabled/disabled via config.
- All sources implement rate limiting and exponential backoff.
- Raw data is cached to minimize redundant API calls.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Data Ingestion Layer                   │
│                                                           │
│  sec-api.io ──┐                                          │
│  Newsfilter ──┤── Event Detector ── Raw Events Queue     │
│  CourtListener┤                                          │
│  FMP ─────────┘                                          │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                    Analysis Engine                        │
│                                                           │
│  Claude API ──── Arbitrage Analyzer ──── Event Store     │
│  Polygon.io ─┤                          (PostgreSQL)     │
│  Tradier ────┘                                           │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                    Tracking & Alerts                      │
│                                                           │
│  Scheduler (APScheduler) ── Monitor ── Alert Dispatcher  │
│                                        ├── Telegram Bot  │
│                                        └── Email (SMTP)  │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                    Dashboard                              │
│  FastAPI backend ──── React frontend                     │
│  REST API              (events table, detail, portfolio)  │
└─────────────────────────────────────────────────────────┘
```

### Key design decisions

1. **PostgreSQL** (via Docker) for concurrent reads/writes from scheduler, dashboard, and ingestion.
2. **APScheduler** with PostgreSQL job store for persistence across restarts and sleep/wake recovery.
3. **Event queue pattern** decouples fast ingestion from slower LLM analysis.
4. **Modular source adapters** with a common interface for easy addition/removal.

---

## Tech Stack

- **Language**: Python 3.12+ (backend), TypeScript (frontend)
- **Web framework**: FastAPI
- **Frontend**: React + Vite + TypeScript
- **Database**: PostgreSQL (via Docker)
- **ORM**: SQLAlchemy 2.0 + Alembic for migrations
- **Scheduler**: APScheduler 4.x
- **LLM**: Anthropic Claude API (Haiku/Sonnet/Opus tiered)
- **Notifications**: Telegram Bot API + SMTP email

---

## Project Structure

```
arbitrage-monitor/
├── backend/
│   ├── src/
│   │   ├── ingestion/          # Data source adapters
│   │   │   ├── base.py         # Abstract source adapter interface
│   │   │   ├── sec_api.py      # sec-api.io WebSocket + filing parser
│   │   │   ├── newsfilter.py   # Newsfilter.io news stream
│   │   │   ├── courtlistener.py# CourtListener API poller
│   │   │   ├── fmp.py          # Financial Modeling Prep M&A data
│   │   │   └── price.py        # Polygon.io + Tradier price/options
│   │   ├── analysis/           # LLM-powered analysis
│   │   │   ├── analyzer.py     # Core analysis orchestrator
│   │   │   ├── prompts.py      # Claude API prompt templates per event type
│   │   │   ├── spread.py       # Spread calculation logic
│   │   │   └── probability.py  # Completion probability estimation
│   │   ├── tracking/           # Event lifecycle management
│   │   │   ├── event_store.py  # CRUD for events in PostgreSQL
│   │   │   ├── monitor.py      # Scheduled re-analysis and updates
│   │   │   └── dedup.py        # Event deduplication logic
│   │   ├── alerts/             # Notification system
│   │   │   ├── dispatcher.py   # Alert routing logic
│   │   │   ├── telegram.py     # Telegram Bot integration
│   │   │   └── email.py        # SMTP email sender
│   │   ├── api/                # FastAPI REST API
│   │   │   ├── main.py         # FastAPI app + routes
│   │   │   ├── routes/         # Endpoint modules
│   │   │   └── schemas.py      # Pydantic request/response models
│   │   ├── models/             # SQLAlchemy ORM models
│   │   │   └── models.py       # Event, Analysis, Alert, Position tables
│   │   ├── config.py           # Settings (API keys, thresholds)
│   │   └── scheduler.py        # APScheduler setup + job definitions
│   ├── tests/
│   ├── alembic/                # DB migrations
│   └── pyproject.toml
├── frontend/
│   ├── src/
│   │   ├── pages/              # Events list, event detail, portfolio
│   │   ├── components/         # Table, charts, alert badges
│   │   └── api/                # API client hooks
│   ├── package.json
│   └── vite.config.ts
├── docker-compose.yml          # PostgreSQL
└── .env.example                # API keys template
```

---

## Database Schema

### events

| Column | Type | Notes |
|---|---|---|
| id | UUID | Primary key |
| event_id | str (unique) | Format: `TICKER-YYYYMMDD-TYPE` |
| ticker | str (indexed) | Stock symbol |
| company_name | str | |
| event_type | enum | MA, GO_PRIVATE, TENDER, LITIGATION, ACTIVIST, SPINOFF, REGULATORY, SPAC, BANKRUPTCY |
| status | enum | ACTIVE, COMPLETED, FAILED, THESIS_CHANGED |
| description | text | 1-2 paragraph event summary |
| deal_price | decimal (nullable) | Target/offer price |
| key_dates | jsonb | announcement, expected_close, vote_date, etc. |
| key_parties | jsonb | acquirer, target, plaintiff, etc. |
| source_filings | jsonb[] | Links to SEC filings, news articles |
| created_at | timestamp | |
| updated_at | timestamp | |

### analyses

| Column | Type | Notes |
|---|---|---|
| id | UUID | Primary key |
| event_id | FK → events | |
| current_price | decimal | Price at time of analysis |
| gross_spread_pct | decimal | |
| annualized_spread_pct | decimal | |
| completion_probability | decimal | 0-1 |
| expected_value | decimal | probability * upside - (1-p) * downside |
| downside_estimate | decimal | Estimated price if deal fails |
| risk_factors | jsonb | List of risk factors with severity |
| recommendation | enum | ENTER, HOLD, EXIT, WATCH |
| reasoning | text | Full LLM analysis text |
| created_at | timestamp | New row per analysis run (versioned) |

### positions

| Column | Type | Notes |
|---|---|---|
| id | UUID | Primary key |
| event_id | FK → events | |
| entry_date | date | |
| entry_price | decimal | |
| shares | integer | |
| current_value | decimal | |
| pnl | decimal | |
| status | enum | OPEN, CLOSED |
| notes | text | |

### alerts

| Column | Type | Notes |
|---|---|---|
| id | UUID | Primary key |
| event_id | FK → events | |
| alert_type | enum | NEW_OPPORTUNITY, SPREAD_WIDENED, SPREAD_NARROWED, THESIS_CHANGE, KEY_DATE_APPROACHING, EXIT_SIGNAL, NEW_FILING |
| priority | enum | HIGH, MEDIUM, LOW |
| message | text | |
| sent_via | jsonb | {"telegram": true, "email": false} |
| created_at | timestamp | |

---

## Scheduler Jobs

| Job | Frequency | Description |
|---|---|---|
| `ingest_sec_filings` | Continuous (WebSocket) | Stream SEC filings via sec-api.io |
| `ingest_news` | Every 5 min | Poll Newsfilter.io for new articles |
| `ingest_court` | Every 6 hours | Poll CourtListener for docket entries |
| `ingest_deals` | Every 30 min | Poll FMP for new/updated M&A deals |
| `update_prices` | Every 5 min (market hours) | Fetch prices for tracked tickers via Polygon |
| `update_options` | Every 30 min (market hours) | Fetch options chains via Tradier |
| `run_analysis` | On new event + daily 4:30pm ET | LLM analysis of new/updated events |
| `check_alerts` | Every 5 min | Evaluate alert conditions, dispatch notifications |
| `daily_summary` | 5:00pm ET daily | Email digest of all active events |
| `catch_up` | On system wake | Detect sleep gap, re-fetch missed data |

---

## Alert System

| Alert Type | Trigger | Priority | Channel |
|---|---|---|---|
| NEW_OPPORTUNITY | New event with annualized spread > 10% | HIGH | Telegram + Email |
| SPREAD_WIDENED | Spread increases by > 2% from entry | MEDIUM | Telegram |
| SPREAD_NARROWED | Spread narrows below 3% | MEDIUM | Telegram |
| THESIS_CHANGE | Material development changes risk/reward | HIGH | Telegram + Email |
| KEY_DATE_APPROACHING | Important date within 7 days | MEDIUM | Telegram |
| EXIT_SIGNAL | Deal closed/failed or risk/reward unfavorable | HIGH | Telegram + Email |
| NEW_FILING | Relevant SEC or court filing detected | LOW | Email only |

Daily summary email sent at 5:00pm ET with all active events, spread changes, and upcoming dates.

---

## LLM Cost Strategy

| Tier | Model | Cost/event | Usage |
|---|---|---|---|
| Tier 1 | Haiku | ~$0.001 | Initial event classification and filtering |
| Tier 2 | Sonnet | ~$0.01 | Full analysis for events passing Tier 1 |
| Tier 3 | Opus | ~$0.05 | Complex situations or thesis-change reassessments |

Estimated monthly LLM cost: ~$30-50/mo at moderate volume (15-50 events/day).

---

## Analysis Output Format

For each event, the system produces:

```
Event Summary:
- Ticker & Company Name
- Event Type
- Event Description (1-2 paragraphs)
- Key Dates (announcement, expected close, vote, court dates)
- Key Parties (acquirer, target, plaintiff, activist, etc.)

Arbitrage Assessment:
- Current Price vs. Deal/Target Price
- Gross Spread (%) and Annualized Spread (%)
- Completion Probability (with reasoning)
- Expected Value: (probability x upside) - ((1-p) x downside)
- Key Risks (regulatory, financing, litigation, shareholder vote, MAC)
- Downside Estimate (price if deal fails)

Recommendation:
- Actionable? (threshold: annualized return > 10% after risk adjustment)
- Position sizing guidance (based on confidence)
- Key milestones to watch
```

### Event-type-specific analysis logic

**Merger Arbitrage:**
- Spread = (Deal Price - Current Price) / Current Price
- Annualized = Spread / (Expected Days to Close / 365)
- Probability factors: HSR status, antitrust risk, financing conditions, shareholder approval, MAC clause
- Stock-for-stock: track exchange ratio and acquirer price
- Handle: collar structures, CVRs, mixed consideration

**Go-Private / Buyout:**
- Same as merger arb plus: competing bid probability, special committee status, fairness opinions, shareholder lawsuits

**Tender Offers:**
- Track: minimum condition (% tendered), expiration, extensions
- Proration risk for partial tenders

**Litigation:**
- Settlement/judgment range estimation
- Sum of (probability x outcome) vs. current price
- Track: motions, discovery, trial dates, settlement talks, appeals
- PSLRA lead plaintiff deadlines for securities class actions

---

## Event Lifecycle

Each event maintains a living document:

```
[Event ID: TICKER-YYYYMMDD-TYPE]
Status: ACTIVE / COMPLETED / FAILED / THESIS_CHANGED

Timeline:
- YYYY-MM-DD: Event description (price, spread)
- ...

Current Assessment:
- [Latest analysis snapshot]

Action History:
- YYYY-MM-DD: ENTER/HOLD/EXIT recommendation at $X
```

---

## Dashboard (React + FastAPI)

### Pages

1. **Events List** — sortable table: ticker, event type, spread, annualized return, days to close, status, recommendation
2. **Event Detail** — full analysis, timeline, filing links, price chart, spread history chart
3. **Portfolio** — open positions, current P&L, active alerts
4. **Summary Stats** — total opportunities tracked, hit rate, average return

### API Endpoints

- `GET /api/events` — list events (filterable by type, status, min spread)
- `GET /api/events/{id}` — event detail with analyses history
- `GET /api/events/{id}/analyses` — analysis version history
- `POST /api/positions` — record a new position
- `PATCH /api/positions/{id}` — update/close a position
- `GET /api/alerts` — recent alerts
- `GET /api/dashboard/summary` — aggregate statistics

---

## Implementation Phases

1. **Phase 1: Event Discovery Pipeline** — SEC filing ingestion, news polling, event detection and classification, database setup
2. **Phase 2: Arbitrage Analysis Engine** — Claude API integration, spread calculations, probability estimation, recommendation logic
3. **Phase 3: Continuous Tracking & Alerting** — Scheduler setup, event lifecycle management, Telegram + email alerts
4. **Phase 4: Web Dashboard** — FastAPI REST API, React frontend with events table, detail pages, portfolio view

---

## Constraints & Requirements

- Non-US timezone user — all timestamps include timezone, no US business hours assumptions
- Free data sources first, paid sources clearly marked
- Single-machine deployment (local Mac)
- Reliability over speed — 30-minute detection delay acceptable, but never miss an event
- All analyses saved and versioned for track record review
- English for all code, comments, and output
- Graceful sleep/wake handling with catch-up logic
