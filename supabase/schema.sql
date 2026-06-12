-- ═══════════════════════════════════════════════════════════════════
-- Dia Organizado — Schema do banco (Supabase / Postgres)
--
-- Como usar: Supabase Dashboard → SQL Editor → New query →
-- cole este arquivo inteiro → Run.
-- ═══════════════════════════════════════════════════════════════════

-- ─── Tarefas ─────────────────────────────────────────────────────────

create table if not exists public.tarefas (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade default auth.uid(),
  nome text not null,
  data text,
  horario text,
  prioridade text not null default 'm',
  concluida boolean not null default false,
  atrasada boolean not null default false,
  lembrete boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.tarefas enable row level security;

create policy "Usuário acessa apenas suas tarefas"
  on public.tarefas for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ─── Compromissos ────────────────────────────────────────────────────

create table if not exists public.compromissos (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade default auth.uid(),
  titulo text not null,
  horario text,
  local text default '',
  dia integer not null,
  mes integer not null,
  ano integer not null,
  created_at timestamptz not null default now()
);

alter table public.compromissos enable row level security;

create policy "Usuário acessa apenas seus compromissos"
  on public.compromissos for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ─── Notas ───────────────────────────────────────────────────────────

create table if not exists public.notas (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade default auth.uid(),
  titulo text not null,
  corpo text default '',
  -- Nome com aspas para casar com a chave usada pelo app (camelCase)
  "dataCriacao" text,
  created_at timestamptz not null default now()
);

alter table public.notas enable row level security;

create policy "Usuário acessa apenas suas notas"
  on public.notas for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ─── Versículos Favoritos ────────────────────────────────────────────

create table if not exists public.versiculos_favoritos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade default auth.uid(),
  versiculo text not null,
  referencia text not null,
  created_at timestamptz not null default now()
);

alter table public.versiculos_favoritos enable row level security;

create policy "Usuário acessa apenas seus versículos"
  on public.versiculos_favoritos for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ─── Configurações ───────────────────────────────────────────────────

create table if not exists public.configuracoes (
  user_id uuid primary key references auth.users (id) on delete cascade,
  tema text default 'escuro',
  "somNotificacao" boolean default true,
  "lembretesRecorrentes" boolean default false,
  updated_at timestamptz not null default now()
);

alter table public.configuracoes enable row level security;

create policy "Usuário acessa apenas suas configurações"
  on public.configuracoes for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ─── Realtime (streams ao vivo no app) ───────────────────────────────

alter publication supabase_realtime add table public.tarefas;
alter publication supabase_realtime add table public.compromissos;
alter publication supabase_realtime add table public.notas;
alter publication supabase_realtime add table public.versiculos_favoritos;
