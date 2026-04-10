create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  phone       text,
  role        text check (role in ('passenger', 'driver')) default 'passenger',
  avatar_url  text,
  created_at  timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "profiles: select own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles: update own" on public.profiles
  for update using (auth.uid() = id);

-- Auto-create a profile row whenever a new user signs up
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, full_name, phone)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'phone'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- ────────────────────────────────────────────
-- RIDES
-- ────────────────────────────────────────────
create table if not exists public.rides (
  id               uuid primary key default gen_random_uuid(),
  passenger_id     uuid references public.profiles(id) on delete cascade,
  driver_id        uuid references public.profiles(id),
  pickup_lat       double precision,
  pickup_lng       double precision,
  pickup_address   text,
  dropoff_lat      double precision,
  dropoff_lng      double precision,
  dropoff_address  text,
  offered_fare     numeric(10,2),
  accepted_fare    numeric(10,2),
  status           text check (status in (
                     'pending','negotiating','accepted',
                     'in_progress','completed','cancelled'
                   )) default 'pending',
  started_at       timestamptz,
  completed_at     timestamptz,
  created_at       timestamptz default now()
);

alter table public.rides enable row level security;

create policy "rides: passenger sees own" on public.rides
  for select using (auth.uid() = passenger_id);

create policy "rides: driver sees assigned" on public.rides
  for select using (auth.uid() = driver_id);

create policy "rides: passenger can insert" on public.rides
  for insert with check (auth.uid() = passenger_id);

create policy "rides: passenger can update own pending" on public.rides
  for update using (auth.uid() = passenger_id and status = 'pending');

create policy "rides: driver can update assigned" on public.rides
  for update using (auth.uid() = driver_id);


-- ────────────────────────────────────────────
-- DRIVER OFFERS  (counter-offers on a ride)
-- ────────────────────────────────────────────
create table if not exists public.driver_offers (
  id           uuid primary key default gen_random_uuid(),
  ride_id      uuid references public.rides(id) on delete cascade,
  driver_id    uuid references public.profiles(id) on delete cascade,
  offered_fare numeric(10,2) not null,
  status       text check (status in ('pending','accepted','rejected')) default 'pending',
  created_at   timestamptz default now()
);

alter table public.driver_offers enable row level security;

create policy "driver_offers: driver insert own" on public.driver_offers
  for insert with check (auth.uid() = driver_id);

create policy "driver_offers: driver sees own" on public.driver_offers
  for select using (auth.uid() = driver_id);

create policy "driver_offers: passenger sees offers on own ride" on public.driver_offers
  for select using (
    exists (
      select 1 from public.rides r
      where r.id = ride_id and r.passenger_id = auth.uid()
    )
  );

create policy "driver_offers: passenger can accept/reject" on public.driver_offers
  for update using (
    exists (
      select 1 from public.rides r
      where r.id = ride_id and r.passenger_id = auth.uid()
    )
  );
