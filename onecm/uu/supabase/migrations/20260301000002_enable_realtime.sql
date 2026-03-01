-- Supabase migration: enable Realtime for synced tables.
-- This allows the app to receive live updates via Supabase Realtime.

-- Enable realtime for babies and growth_records (initial sync tables).
-- Add more tables here as sync support expands.
alter publication supabase_realtime add table public.babies;
alter publication supabase_realtime add table public.growth_records;

-- Set REPLICA IDENTITY to FULL so that UPDATE and DELETE events
-- include the full previous row data.
alter table public.babies replica identity full;
alter table public.growth_records replica identity full;
