-- ZenVlog community schema. Apply via Supabase SQL Editor or `supabase db push`.
-- Storage: create a public bucket named `post-media` (10MB limit,
-- image/jpeg,image/png,audio/m4a) in Dashboard -> Storage.

-- Enable PostGIS for geo queries
create extension if not exists postgis;

-- Posts table
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null,
  media_url text,
  place_name text,
  -- Fuzzy coordinates: 2 decimal places ~ 1km precision. Exact coords never stored.
  lat_fuzzy numeric(6,2),
  lng_fuzzy numeric(7,2),
  location geography(Point, 4326),
  created_at timestamptz default now()
);

-- Populate geography column from fuzzy coords on insert/update
create or replace function sync_location()
returns trigger as $$
begin
  if new.lat_fuzzy is not null and new.lng_fuzzy is not null then
    new.location := st_point(new.lng_fuzzy, new.lat_fuzzy)::geography;
  end if;
  return new;
end;
$$ language plpgsql;

create trigger posts_sync_location
  before insert or update on public.posts
  for each row execute function sync_location();

-- Follows table
create table public.follows (
  follower_id uuid not null references auth.users(id) on delete cascade,
  following_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  primary key (follower_id, following_id)
);

-- Row-level security
alter table public.posts enable row level security;
alter table public.follows enable row level security;

-- Anyone can read posts
create policy "posts_read_all" on public.posts for select using (true);
-- Users can only insert/update/delete their own posts
create policy "posts_write_own" on public.posts
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Users can read all follows
create policy "follows_read_all" on public.follows for select using (true);
-- Users can only manage their own follows
create policy "follows_write_own" on public.follows
  for all using (auth.uid() = follower_id) with check (auth.uid() = follower_id);

-- Index for Nearby tab performance
create index posts_location_idx on public.posts using gist(location);
create index posts_created_at_idx on public.posts(created_at desc);
create index posts_user_id_idx on public.posts(user_id);
