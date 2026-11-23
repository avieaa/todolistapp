-- Paste this whole file into Supabase > SQL Editor > Run

create table sections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  grp text not null check (grp in ('home','primary','freelance','side')),
  name text not null check (length(trim(name)) > 0),
  kind text not null default 'plain' check (kind in ('plain','affiliate','adobe')),
  pos int not null default 0
);

create table tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  section_id uuid not null references sections(id) on delete cascade,
  title text not null check (length(trim(title)) > 0),
  notes text,
  due date,
  priority text not null default 'normal' check (priority in ('normal','high')),
  done boolean not null default false,
  done_at timestamptz,
  platform text,
  target int check (target is null or target >= 0),
  keywords text,
  hashtags text,
  status text check (status is null or status in ('draft','uploaded','approved')),
  created_at timestamptz not null default now()
);

-- Security: only the logged-in owner can read or change their own rows
alter table sections enable row level security;
alter table tasks enable row level security;

create policy "own sections" on sections for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own tasks" on tasks for all
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
