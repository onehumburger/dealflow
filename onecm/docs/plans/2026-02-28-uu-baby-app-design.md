# UU Baby Growth Tracker — Design Document

**Date:** 2026-02-28
**Status:** Approved

## Overview

UU is a baby growth tracking app for parents of children aged 0-3. It records daily growth data, provides AI-powered analysis and personalized advice, and alerts parents to anything requiring attention. Built for personal use first, designed to scale to a public app on Play Store and App Store.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter / Dart |
| Backend | Supabase (PostgreSQL, Auth, Storage, Realtime, Edge Functions) |
| AI Provider | Pluggable interface — default: Google Gemini API (free tier) |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| Local DB | Drift (SQLite) for offline-first |
| Charts | fl_chart or syncfusion_flutter_charts |

## Architecture

```
+-----------------------------------------------+
|                UU App (Flutter)                |
|  +----------+ +----------+ +--------------+   |
|  | Daily    | | Growth   | | AI Chat      |   |
|  | Logs     | | Charts   | | Assistant    |   |
|  +----------+ +----------+ +--------------+   |
|  | Milestone| | Health   | | Knowledge    |   |
|  | Timeline | | Records  | | Base         |   |
|  +----------+ +----------+ +--------------+   |
|  | Media    | | Notifi-  | | Family       |   |
|  | Gallery  | | cations  | | Sharing      |   |
|  +----------+ +----------+ +--------------+   |
+--------------------+-----+--------------------+
                     |
          +----------v----------+
          |     Supabase        |
          |  +---------------+  |    +-----------------+
          |  | PostgreSQL    |  |    | Edge Functions   |
          |  | (all data)    |  |    |  +-------------+ |
          |  +---------------+  |    |  | AI Analysis | |
          |  | Auth          |  |    |  | (Gemini API)| |
          |  | (Google/Apple)|  |    |  +-------------+ |
          |  +---------------+  |    |  | Smart       | |
          |  | Storage       |  |    |  | Notifs      | |
          |  | (photos/video)|  |    |  +-------------+ |
          |  +---------------+  |    |  | Growth      | |
          |  | Realtime      |  |    |  | Scoring     | |
          |  | (live sync)   |  |    |  +-------------+ |
          +---------------------+    +-----------------+
                     |
          +----------v----------+
          |  FCM (Push Notifs)  |
          +---------------------+
```

**Key architectural decisions:**
- Supabase Realtime handles family sync (when mom logs a feeding, dad's app updates instantly)
- Edge Functions (Deno/TypeScript) handle AI calls and scheduled analysis jobs
- Row Level Security (RLS) enforces that users only see data for babies they're linked to
- PostgreSQL enables complex analytics queries (percentile calculations, trend analysis, pattern detection)

## Feature Set (v1)

### Core Tracking
1. Growth measurements (height, weight, head circumference) with WHO percentile curves
2. Daily logs (feeding, sleep, diapers, mood) with live timers
3. Developmental milestones with dates + photos/videos
4. Health records (vaccinations, illness, medications, doctor visits)
5. Food introduction tracker with allergen checklist
6. Teething map (visual tooth diagram)

### Media
7. Full photo + video gallery organized by timeline

### AI & Intelligence
8. AI chatbot (personalized Q&A using baby's data)
9. Knowledge base (searchable pediatric articles)
10. Smart notifications:
    - Growth anomalies (WHO curve deviation)
    - Milestone reminders + delay alerts
    - Vaccination/doctor visit reminders
    - Pattern insights (sleep/feeding/mood trends)
    - Feeding reminders (user-set or AI-suggested intervals)
    - Diaper change reminders (user-set or AI-suggested)

### UX
11. Quick-log one-tap actions (tap = instant log, long-press = form)
12. Dark mode / night mode (auto-switch by time)
13. Home screen widget (next feed/diaper time + action buttons)
14. Offline mode with background sync

### Reports
15. Doctor visit report generator (auto-summary of recent data)
16. Caregiver handoff notes (shareable as link/PDF)
17. "On This Day" memories

### Social
18. Family sharing (multiple users per baby, each with their own account)

### Deferred to v2
- Multi-child support (switching between children)

## Data Model

```sql
-- Core entities
families (
  id uuid PRIMARY KEY,
  name text,
  created_at timestamptz
)

family_members (
  id uuid PRIMARY KEY,
  family_id uuid REFERENCES families,
  user_id uuid REFERENCES auth.users,
  role text CHECK (role IN ('admin', 'member')),
  invited_by uuid,
  joined_at timestamptz
)

babies (
  id uuid PRIMARY KEY,
  family_id uuid REFERENCES families,
  name text NOT NULL,
  date_of_birth date NOT NULL,
  gender text,
  blood_type text,
  allergies text[],
  photo_url text,
  created_at timestamptz
)

-- Growth tracking
growth_records (
  id uuid PRIMARY KEY,
  baby_id uuid REFERENCES babies,
  recorded_by uuid REFERENCES auth.users,
  date date NOT NULL,
  height_cm numeric,
  weight_kg numeric,
  head_circumference_cm numeric,
  notes text,
  photo_url text,
  created_at timestamptz
)

-- Daily logs (polymorphic via type)
daily_logs (
  id uuid PRIMARY KEY,
  baby_id uuid REFERENCES babies,
  recorded_by uuid REFERENCES auth.users,
  type text CHECK (type IN ('feeding', 'sleep', 'diaper', 'mood')),
  started_at timestamptz NOT NULL,
  ended_at timestamptz,
  duration_minutes integer,
  metadata jsonb,
  notes text,
  created_at timestamptz
)
-- metadata examples:
--   feeding: {"method": "breast/bottle/solid", "side": "left/right", "amount_ml": 120}
--   sleep:   {"quality": "good/fair/poor", "location": "crib/stroller"}
--   diaper:  {"type": "wet/dirty/both"}
--   mood:    {"level": 1-5, "tags": ["fussy", "happy", "teething"]}

-- Milestones
milestones (
  id uuid PRIMARY KEY,
  baby_id uuid REFERENCES babies,
  recorded_by uuid REFERENCES auth.users,
  category text CHECK (category IN ('motor', 'language', 'social', 'cognitive')),
  title text NOT NULL,
  description text,
  achieved_at date,
  expected_age_months integer,
  media_urls text[],
  created_at timestamptz
)

-- Health
vaccinations (
  id uuid PRIMARY KEY,
  baby_id uuid REFERENCES babies,
  vaccine_name text NOT NULL,
  dose_number integer,
  administered_at date,
  next_due_at date,
  provider text,
  notes text,
  created_at timestamptz
)

health_events (
  id uuid PRIMARY KEY,
  baby_id uuid REFERENCES babies,
  recorded_by uuid REFERENCES auth.users,
  type text CHECK (type IN ('illness', 'medication', 'doctor_visit')),
  title text NOT NULL,
  description text,
  started_at timestamptz,
  ended_at timestamptz,
  metadata jsonb,
  created_at timestamptz
)

-- Food introduction
food_introductions (
  id uuid PRIMARY KEY,
  baby_id uuid REFERENCES babies,
  food_name text NOT NULL,
  category text CHECK (category IN ('fruit', 'vegetable', 'grain', 'protein', 'dairy', 'allergen')),
  is_allergen boolean DEFAULT false,
  first_tried_at date NOT NULL,
  reaction text,
  reaction_severity text CHECK (reaction_severity IN ('none', 'mild', 'moderate', 'severe')),
  notes text,
  created_at timestamptz
)

-- Teething
teeth_records (
  id uuid PRIMARY KEY,
  baby_id uuid REFERENCES babies,
  tooth_position text NOT NULL, -- A-T using dental notation
  erupted_at date NOT NULL,
  notes text,
  created_at timestamptz
)

-- Notifications & reminders
notification_settings (
  id uuid PRIMARY KEY,
  baby_id uuid REFERENCES babies,
  user_id uuid REFERENCES auth.users,
  type text NOT NULL,
  enabled boolean DEFAULT true,
  interval_minutes integer,
  ai_suggested_interval integer,
  custom_message text,
  created_at timestamptz
)

-- AI chat history
chat_messages (
  id uuid PRIMARY KEY,
  baby_id uuid REFERENCES babies,
  user_id uuid REFERENCES auth.users,
  role text CHECK (role IN ('user', 'assistant')),
  content text NOT NULL,
  context_data jsonb,
  created_at timestamptz
)

-- Media
media (
  id uuid PRIMARY KEY,
  baby_id uuid REFERENCES babies,
  uploaded_by uuid REFERENCES auth.users,
  type text CHECK (type IN ('photo', 'video')),
  storage_path text NOT NULL,
  thumbnail_path text,
  caption text,
  taken_at timestamptz,
  linked_record_type text,
  linked_record_id uuid,
  created_at timestamptz
)
```

## App Screens & Navigation

### Bottom Navigation
```
[Home]  [Logs]  [+]  [Chat]  [Me]
```

### Home Screen
- Baby avatar + name + age
- Quick-action buttons: Fed, Diaper, Sleep, Mood, Timer (one-tap = instant log, long-press = form)
- Today's summary: feeds count, total sleep, diapers, mood
- Growth snapshot (tap to open full charts)
- Active alerts (vaccination due, next feed estimate)
- Recent photo moments

### Logs Tab
- Timeline view of all daily logs, filterable by type
- Active timers pinned at top

### "+" Floating Action Button
Quick-add menu for: feeding, sleep, diaper, mood, growth measurement, milestone, health event, food introduction, tooth eruption

### Chat Tab
- AI chatbot interface with persistent conversation
- Quick-concern buttons at top: Sleep, Feeding, Skin/Rash, Behavior, Growth
- Each query automatically includes baby context (last 7 days)

### Me Tab
Navigation to: Growth charts, Milestone timeline, Health records, Vaccination schedule, Food tracker, Teething map, Media gallery, Doctor report, Caregiver handoff, "On This Day", Family management, Notification settings, App settings

### Key Screen Details

**Growth Charts:** Interactive WHO percentile curves (3rd, 15th, 50th, 85th, 97th) with baby's data plotted. Tabs for weight/height/head circumference. Shows current percentile and trend.

**Teething Map:** Visual diagram of upper and lower jaw with 20 primary teeth (A-T). Tap to mark erupted. Shows count and last eruption date.

**Timer:** Persistent mini-bar below app bar (like Spotify mini player) when active. Expandable to full view. Supports breast feeding (left/right toggle), bottle, sleep, tummy time.

## AI System

### Provider Architecture
Pluggable `AIProvider` interface:
- `chat(messages, babyContext) -> reply`
- `analyze(data, analysisType) -> result`

Default implementation: Google Gemini API (free tier: 15 RPM, sufficient for personal use).

### Chatbot Behavior
1. Pull recent context: last 7 days of logs, growth percentiles, milestones, health events
2. Construct system prompt with baby profile + context
3. Send to AI provider with parent's question
4. Return response grounded in baby's specific data

### Safeguards
- Every health response includes: "This is general guidance, not medical advice. Consult your pediatrician for medical concerns."
- AI never diagnoses — it suggests when to see a doctor
- Response caching per question pattern to reduce API costs

## Smart Notifications

### Rule-Based (no AI needed)
- Vaccination schedule reminders (by age, country-configurable)
- User-set feeding/diaper intervals
- Doctor visit reminders
- Milestone age-window reminders

### AI-Based (Edge Function analysis)
- Feeding/diaper interval suggestion: analyzes last 7 days, suggests optimal intervals
- Growth anomaly: flags measurement deviating >1 SD from baby's trend or crossing percentile lines
- Milestone delay: gentle alert if milestone not marked by expected age + buffer
- Sleep pattern change: flags significant deviation from established pattern
- Mood correlation: identifies patterns (e.g., fussy days correlate with teething)

### "On This Day" Memories
Daily at 9 AM, if media exists from this date in a previous month/year.

### Delivery
FCM push notifications + in-app badge/banner.

## Offline Mode

### Strategy: Local-first with background sync

- All reads from local Drift (SQLite) DB — instant, no network needed
- Writes go to local DB first, then queued for sync
- Supabase Realtime streams updates from family members when online
- Conflict resolution: last-write-wins with timestamp
- Media: cached locally, uploaded in background on WiFi

## UX Principles

1. **One-handed operation:** All primary actions reachable with thumb, one-tap logging
2. **3 AM friendly:** Auto dark mode, minimal brightness, large tap targets
3. **Instant logging:** Quick-log = tap to log with defaults + 5-second edit toast
4. **Persistent timer:** Mini-bar always visible when timer running, even across screens
5. **Widget:** Home screen widget with next feed/diaper time + action buttons
6. **Shareable reports:** Doctor report and caregiver handoff exportable as PDF/link
7. **AI quick-concerns:** Pre-built topic buttons to reduce typing

## Development Phases

### Phase 1 — MVP (Personal Use)
- Baby profile + growth tracking with WHO charts
- Daily logs (feeding, sleep, diaper, mood) with live timers
- Quick-log actions
- Dark mode
- Local storage with Supabase sync
- Basic notifications (user-set intervals)

### Phase 2 — Intelligence
- AI chatbot with baby context
- Smart notifications (AI-suggested intervals)
- Growth anomaly detection
- Pattern insights (sleep/feeding trends)
- Milestone tracking with reminders

### Phase 3 — Full Features
- Family sharing
- Food introduction tracker
- Teething map
- Health records + vaccination schedule
- Media gallery
- Knowledge base
- Doctor visit report generator
- Caregiver handoff notes
- Offline mode (full)

### Phase 4 — Polish for Public Release
- "On This Day" memories
- Home screen widget
- Onboarding flow
- Multi-language support
- App Store / Play Store submission
- Multi-child support
