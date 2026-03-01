-- Supabase migration: enable Row Level Security on all tables.
-- Policy: users can only read/write their own rows (user_id = auth.uid()).

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
    -- Enable RLS
    execute format('alter table public.%I enable row level security;', tbl);

    -- SELECT: own rows only
    execute format(
      'create policy "Users can view own %1$s" on public.%1$I
       for select using (auth.uid() = user_id);',
      tbl
    );

    -- INSERT: can insert with own user_id
    execute format(
      'create policy "Users can insert own %1$s" on public.%1$I
       for insert with check (auth.uid() = user_id);',
      tbl
    );

    -- UPDATE: own rows only
    execute format(
      'create policy "Users can update own %1$s" on public.%1$I
       for update using (auth.uid() = user_id)
       with check (auth.uid() = user_id);',
      tbl
    );

    -- DELETE: own rows only
    execute format(
      'create policy "Users can delete own %1$s" on public.%1$I
       for delete using (auth.uid() = user_id);',
      tbl
    );
  end loop;
end;
$$;
