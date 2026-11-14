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

-- Explicit Data API grants: policies below still control which rows are accessible.
grant usage on schema public to anon, authenticated;
grant select, insert, update on table public.trip_data to anon, authenticated;

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


-- Exclusive concert-look reservations. One person can hold one look, and
-- each look can be held by one person. Writes go through a constrained RPC.
create table if not exists public.trip_look_claims (
  look_id text primary key check (look_id ~ '^[0-7]$'),
  person text not null unique
    check (person in ('Katie','Kristi','Vanessa','Becca','Mel')),
  updated_at timestamptz not null default now()
);

alter table public.trip_look_claims enable row level security;

drop policy if exists "Look claims are viewable by visitors" on public.trip_look_claims;
create policy "Look claims are viewable by visitors"
  on public.trip_look_claims for select
  to anon, authenticated
  using (true);

grant select on table public.trip_look_claims to anon, authenticated;
revoke insert, update, delete on table public.trip_look_claims from anon, authenticated;

create or replace function public.claim_trip_look(p_person text, p_look_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  current_owner text;
begin
  if p_person not in ('Katie','Kristi','Vanessa','Becca','Mel') then
    raise exception 'Choose one of the five trip members.';
  end if;
  if p_look_id !~ '^[0-7]$' then
    raise exception 'Unknown outfit.';
  end if;

  -- Serialize simultaneous claims. The unique constraints provide a second guard.
  perform pg_advisory_xact_lock(772001);

  select person into current_owner
    from public.trip_look_claims
    where look_id = p_look_id
    for update;

  if current_owner = p_person then
    delete from public.trip_look_claims
      where look_id = p_look_id and person = p_person;
    return jsonb_build_object('ok', true, 'action', 'released');
  end if;

  if current_owner is not null then
    return jsonb_build_object('ok', false, 'action', 'unavailable', 'owner', current_owner);
  end if;

  -- A friend may only hold one look; switching releases their prior claim.
  delete from public.trip_look_claims where person = p_person;

  insert into public.trip_look_claims (look_id, person, updated_at)
  values (p_look_id, p_person, now());

  return jsonb_build_object('ok', true, 'action', 'claimed');
end;
$$;

revoke all on function public.claim_trip_look(text, text) from public;
grant execute on function public.claim_trip_look(text, text) to anon, authenticated;

do $$
begin
  alter publication supabase_realtime add table public.trip_look_claims;
exception
  when duplicate_object then null;
  when undefined_object then
    raise notice 'Realtime publication is unavailable; claims will refresh on page reload.';
end $$;
