-- Supabase migration: create all tables matching Drift schema
-- Each table includes user_id for RLS and local_id to map back to Drift.

-- =============================================================================
-- babies
-- =============================================================================
create table if not exists public.babies (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  local_id    integer not null,
  name        text not null check (char_length(name) between 1 and 100),
  date_of_birth timestamptz not null,
  gender      text,
  blood_type  text,
  photo_url   text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- growth_records
-- =============================================================================
create table if not exists public.growth_records (
  id                    bigint generated always as identity primary key,
  user_id               uuid not null references auth.users(id) on delete cascade,
  local_id              integer not null,
  baby_id               integer not null,
  date                  timestamptz not null,
  weight_kg             double precision,
  height_cm             double precision,
  head_circumference_cm double precision,
  notes                 text,
  photo_url             text,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- daily_logs
-- =============================================================================
create table if not exists public.daily_logs (
  id                bigint generated always as identity primary key,
  user_id           uuid not null references auth.users(id) on delete cascade,
  local_id          integer not null,
  baby_id           integer not null,
  type              text not null,
  started_at        timestamptz not null,
  ended_at          timestamptz,
  duration_minutes  integer,
  metadata          jsonb,
  notes             text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- notification_settings
-- =============================================================================
create table if not exists public.notification_settings (
  id                    bigint generated always as identity primary key,
  user_id               uuid not null references auth.users(id) on delete cascade,
  local_id              integer not null,
  baby_id               integer not null,
  type                  text not null,
  enabled               boolean not null default true,
  interval_minutes      integer not null default 120,
  ai_suggested_interval integer,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- milestones
-- =============================================================================
create table if not exists public.milestones (
  id                  bigint generated always as identity primary key,
  user_id             uuid not null references auth.users(id) on delete cascade,
  local_id            integer not null,
  baby_id             integer not null,
  category            text not null,
  title               text not null,
  description         text,
  achieved_at         timestamptz,
  expected_age_months integer,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- vaccinations
-- =============================================================================
create table if not exists public.vaccinations (
  id              bigint generated always as identity primary key,
  user_id         uuid not null references auth.users(id) on delete cascade,
  local_id        integer not null,
  baby_id         integer not null,
  vaccine_name    text not null,
  dose_number     integer,
  administered_at timestamptz,
  next_due_at     timestamptz,
  provider        text,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- health_events
-- =============================================================================
create table if not exists public.health_events (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  local_id    integer not null,
  baby_id     integer not null,
  type        text not null,
  title       text not null,
  description text,
  started_at  timestamptz,
  ended_at    timestamptz,
  metadata    jsonb,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- food_introductions
-- =============================================================================
create table if not exists public.food_introductions (
  id                bigint generated always as identity primary key,
  user_id           uuid not null references auth.users(id) on delete cascade,
  local_id          integer not null,
  baby_id           integer not null,
  food_name         text not null,
  category          text not null,
  is_allergen       boolean not null default false,
  first_tried_at    timestamptz not null,
  reaction          text,
  reaction_severity text,
  notes             text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- teeth_records
-- =============================================================================
create table if not exists public.teeth_records (
  id              bigint generated always as identity primary key,
  user_id         uuid not null references auth.users(id) on delete cascade,
  local_id        integer not null,
  baby_id         integer not null,
  tooth_position  text not null,
  erupted_at      timestamptz not null,
  notes           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- chat_messages
-- =============================================================================
create table if not exists public.chat_messages (
  id            bigint generated always as identity primary key,
  user_id       uuid not null references auth.users(id) on delete cascade,
  local_id      integer not null,
  baby_id       integer not null,
  role          text not null,
  content       text not null,
  context_data  jsonb,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- media_entries
-- =============================================================================
create table if not exists public.media_entries (
  id                 bigint generated always as identity primary key,
  user_id            uuid not null references auth.users(id) on delete cascade,
  local_id           integer not null,
  baby_id            integer not null,
  type               text not null,
  storage_path       text not null,
  thumbnail_path     text,
  caption            text,
  taken_at           timestamptz,
  linked_record_type text,
  linked_record_id   integer,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  unique (user_id, local_id)
);

-- =============================================================================
-- Auto-update updated_at on every UPDATE
-- =============================================================================
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Apply the trigger to all tables.
do $$
declare
  tbl text;
begin
  for tbl in
    select unnest(array[
      'babies', 'growth_records', 'daily_logs', 'notification_settings',
      'milestones', 'vaccinations', 'health_events', 'food_introductions',
      'teeth_records', 'chat_messages', 'media_entries'
    ])
  loop
    execute format(
      'create trigger set_updated_at before update on public.%I
       for each row execute function public.set_updated_at();',
      tbl
    );
  end loop;
end;
$$;
