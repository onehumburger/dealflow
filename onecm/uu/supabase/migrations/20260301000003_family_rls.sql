-- Supabase migration: create families/family_members tables and RLS policies
-- for family-scoped access to shared baby data.

-- =============================================================================
-- families
-- =============================================================================
create table if not exists public.families (
  id          bigint generated always as identity primary key,
  name        text not null check (char_length(name) between 1 and 100),
  invite_code text not null unique,
  created_by  uuid not null references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table public.families enable row level security;

-- Family creator can do everything with their own families.
create policy "Users can view families they created"
  on public.families for select
  using (auth.uid() = created_by);

create policy "Users can insert families"
  on public.families for insert
  with check (auth.uid() = created_by);

create policy "Users can update own families"
  on public.families for update
  using (auth.uid() = created_by)
  with check (auth.uid() = created_by);

create policy "Users can delete own families"
  on public.families for delete
  using (auth.uid() = created_by);

-- Members can also view families they belong to.
create policy "Members can view their families"
  on public.families for select
  using (
    id in (
      select family_id from public.family_members
      where user_id = auth.uid() and status = 'accepted'
    )
  );

-- =============================================================================
-- family_members
-- =============================================================================
create table if not exists public.family_members (
  id          bigint generated always as identity primary key,
  family_id   bigint not null references public.families(id) on delete cascade,
  user_id     uuid references auth.users(id) on delete set null,
  email       text not null,
  role        text not null default 'member' check (role in ('admin', 'member')),
  status      text not null default 'pending' check (status in ('pending', 'accepted', 'declined')),
  invited_at  timestamptz not null default now(),
  joined_at   timestamptz
);

alter table public.family_members enable row level security;

-- Family admins can manage members.
create policy "Admins can view family members"
  on public.family_members for select
  using (
    family_id in (
      select family_id from public.family_members fm
      where fm.user_id = auth.uid() and fm.status = 'accepted'
    )
  );

create policy "Admins can insert family members"
  on public.family_members for insert
  with check (
    family_id in (
      select family_id from public.family_members fm
      where fm.user_id = auth.uid() and fm.role = 'admin' and fm.status = 'accepted'
    )
  );

create policy "Admins can update family members"
  on public.family_members for update
  using (
    family_id in (
      select family_id from public.family_members fm
      where fm.user_id = auth.uid() and fm.role = 'admin' and fm.status = 'accepted'
    )
  );

create policy "Admins can delete family members"
  on public.family_members for delete
  using (
    family_id in (
      select family_id from public.family_members fm
      where fm.user_id = auth.uid() and fm.role = 'admin' and fm.status = 'accepted'
    )
  );

-- Users can accept/decline their own invitations.
create policy "Users can update own invitations"
  on public.family_members for update
  using (email = (select email from auth.users where id = auth.uid()))
  with check (email = (select email from auth.users where id = auth.uid()));

-- Users can view invitations addressed to them.
create policy "Users can view own invitations"
  on public.family_members for select
  using (email = (select email from auth.users where id = auth.uid()));

-- =============================================================================
-- Family-scoped access: extend data table policies so family members
-- can view each other's baby data.
-- =============================================================================

-- For each data table, add a policy that allows SELECT for family members.
-- A user can see rows owned by any user who is in the same accepted family.
do $$
declare
  tbl text;
begin
  for tbl in
    select unnest(array[
      'babies', 'growth_records', 'daily_logs',
      'milestones', 'vaccinations', 'health_events',
      'food_introductions', 'teeth_records', 'media_entries'
    ])
  loop
    execute format(
      'create policy "Family members can view shared %1$s" on public.%1$I
       for select using (
         user_id in (
           select fm2.user_id
           from public.family_members fm1
           join public.family_members fm2 on fm1.family_id = fm2.family_id
           where fm1.user_id = auth.uid()
             and fm1.status = ''accepted''
             and fm2.status = ''accepted''
         )
       );',
      tbl
    );
  end loop;
end;
$$;

-- Apply updated_at trigger to new tables.
create trigger set_updated_at before update on public.families
for each row execute function public.set_updated_at();
