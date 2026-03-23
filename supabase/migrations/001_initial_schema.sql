-- Kernel Flow OS — Initial Schema
-- Migration: 001
-- Date: 2026-03-23
-- Run this in Supabase SQL Editor

-- ============================================================
-- CLIENTS
-- ============================================================
create table if not exists clients (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  client_id text unique,
  status text default 'Potenziell', -- Aktiv/Potenziell/Inaktiv/Archiviert
  branche text,
  kontaktperson text,
  email text,
  telefon text,
  adresse text,
  website text,
  tier text, -- Premium/Standard/One-off
  letzter_kontakt date,
  notizen text,
  ordner_link text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ============================================================
-- PROJECTS
-- ============================================================
create table if not exists projects (
  id uuid default gen_random_uuid() primary key,
  titel text not null,
  auftrags_nr text unique,
  kunde_id uuid references clients(id) on delete set null,
  status text default 'Anfrage', -- Anfrage/In Arbeit/Review/Abgeliefert/Abgeschlossen/Archiviert
  typ text,
  prioritaet text default 'Standard', -- Hoch/Standard/Niedrig
  startdatum date,
  deadline date,
  budget numeric,
  stunden_geschaetzt numeric default 0,
  stunden_geloggt numeric default 0,
  beschreibung text,
  ordner_link text,
  notizen text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists project_deliverables (
  id uuid default gen_random_uuid() primary key,
  project_id uuid references projects(id) on delete cascade,
  text text not null,
  completed boolean default false,
  sort_order integer default 0
);

create table if not exists time_entries (
  id uuid default gen_random_uuid() primary key,
  project_id uuid references projects(id) on delete cascade,
  datum date not null,
  stunden numeric not null,
  notiz text,
  created_at timestamptz default now()
);

-- ============================================================
-- LEADS
-- ============================================================
create table if not exists leads (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  anfrageart text,
  quelle text,
  budget_schaetzung numeric,
  status text default 'Neu', -- Neu/Kontaktiert/Discovery Call/Angebot Gesendet/Gewonnen/Verloren
  eingangsdatum date default current_date,
  naechste_aktion text,
  naechste_aktion_datum date,
  email text,
  telefon text,
  notizen text,
  created_at timestamptz default now()
);

-- ============================================================
-- SERVICES
-- ============================================================
create table if not exists services (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  service_id text unique,
  kategorie text, -- Video/Foto/AI-Automation/Event/IT-Support/Consulting/Sonstiges
  beschreibung text,
  preis_von numeric,
  preis_bis numeric,
  aufwand_stunden numeric,
  vor_ort_minuten integer,
  nachbearbeitung_stunden numeric,
  lieferumfang text,
  status text default 'Entwurf', -- Aktiv/Entwurf/Archiviert
  notizen text,
  created_at timestamptz default now()
);

-- ============================================================
-- CONTENT
-- ============================================================
create table if not exists content_items (
  id uuid default gen_random_uuid() primary key,
  titel text not null,
  plattform text[],
  format text,
  status text default 'Idee', -- Idee/In Produktion/Fertig/Geplant/Veröffentlicht
  geplantes_datum date,
  fuer_kunde_id uuid references clients(id) on delete set null,
  fuer_eigene boolean default true,
  hook text,
  script text,
  hashtags text,
  datei_link text,
  performance_score integer check (performance_score between 1 and 10),
  tags text[],
  created_at timestamptz default now()
);

-- ============================================================
-- INVOICES
-- ============================================================
create table if not exists invoices (
  id uuid default gen_random_uuid() primary key,
  rechnungs_nr text unique,
  kunde_id uuid references clients(id) on delete set null,
  projekt_id uuid references projects(id) on delete set null,
  betrag numeric not null,
  mwst_prozent numeric default 8.1,
  status text default 'Entwurf', -- Entwurf/Gesendet/Bezahlt/Überfällig
  ausstellungsdatum date default current_date,
  faelligkeitsdatum date,
  beschreibung text,
  notizen text,
  created_at timestamptz default now()
);

-- ============================================================
-- OPEN LOOPS
-- ============================================================
create table if not exists open_loops (
  id uuid default gen_random_uuid() primary key,
  loop text not null,
  status text default 'Offen', -- Offen/Wartet/Erledigt/Archiviert
  leverage text default 'Mittel', -- Hoch/Mittel/Niedrig
  deadline date,
  kunde_id uuid references clients(id) on delete set null,
  projekt_id uuid references projects(id) on delete set null,
  quelle text,
  owner text default 'Ich',
  beteiligte text,
  naechste_aktion text,
  notizen text,
  created_at timestamptz default now()
);

-- ============================================================
-- PROMPTS
-- ============================================================
create table if not exists prompts (
  id uuid default gen_random_uuid() primary key,
  titel text not null,
  kategorie text,
  prompt_text text not null,
  tags text[],
  favorit boolean default false,
  zuletzt_genutzt date,
  notizen text,
  created_at timestamptz default now()
);

-- ============================================================
-- PARTNER
-- ============================================================
create table if not exists partner (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  typ text,
  kontaktperson text,
  email text,
  telefon text,
  services text,
  status text default 'Potenziell',
  revenue_share numeric,
  notizen text,
  website text,
  created_at timestamptz default now()
);

-- ============================================================
-- ROADMAP
-- ============================================================
create table if not exists roadmap (
  id uuid default gen_random_uuid() primary key,
  ziel text not null,
  phase text, -- Phase 1 (M1-2)/Phase 2 (M3-4)/Phase 3 (M5-6)/Laufend
  kategorie text, -- Revenue/Produkt/Marketing/Ops/Legal/Tech
  status text default 'Geplant', -- Geplant/In Progress/Erreicht/Verschoben
  zieldatum date,
  erfolgsmetrik text,
  beschreibung text,
  prioritaet text default 'Mittel',
  created_at timestamptz default now()
);

-- ============================================================
-- ACTIVITY LOG
-- ============================================================
create table if not exists activity_log (
  id uuid default gen_random_uuid() primary key,
  action text not null, -- created/updated/deleted
  entity_type text not null, -- client/project/lead/invoice/loop/etc.
  entity_name text,
  created_at timestamptz default now()
);

-- ============================================================
-- DISABLE RLS (MVP — single user, no auth needed)
-- ============================================================
alter table clients disable row level security;
alter table projects disable row level security;
alter table project_deliverables disable row level security;
alter table time_entries disable row level security;
alter table leads disable row level security;
alter table services disable row level security;
alter table content_items disable row level security;
alter table invoices disable row level security;
alter table open_loops disable row level security;
alter table prompts disable row level security;
alter table partner disable row level security;
alter table roadmap disable row level security;
alter table activity_log disable row level security;
