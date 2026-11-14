-- Together, Together — Chicago 2027
-- Run once in Supabase Dashboard > SQL Editor.
-- Public collaborative planner: anyone with the site URL may read/update this single trip record.
-- Do not store sensitive personal, financial, or account data in this table.

create table if not exists public.trip_data (
  id integer primary key check (id = 1),
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.trip_data enable row level security;

drop policy if exists "Trip is viewable by visitors" on public.trip_data;
create policy "Trip is viewable by visitors"
  on public.trip_data for select
  to anon, authenticated
  using (id = 1);

drop policy if exists "Visitors can create trip data" on public.trip_data;
create policy "Visitors can create trip data"
  on public.trip_data for insert
  to anon, authenticated
  with check (id = 1);

drop policy if exists "Visitors can update trip data" on public.trip_data;
create policy "Visitors can update trip data"
  on public.trip_data for update
  to anon, authenticated
  using (id = 1)
  with check (id = 1);

insert into public.trip_data (id, data)
values (1, '{}'::jsonb)
on conflict (id) do nothing;

do $$
begin
  alter publication supabase_realtime add table public.trip_data;
exception
  when duplicate_object then null;
  when undefined_object then
    raise notice 'Realtime publication is unavailable; the app will still sync on refresh.';
end $$;
