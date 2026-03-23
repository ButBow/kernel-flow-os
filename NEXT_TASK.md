# NEXT TASK FOR LOVABLE

**Orchestrated by:** Claude (AI Orchestrator for Kernel Flow OS)
**Task:** TASK-001 — Initial App Build (Foundation)
**Date:** 2026-03-23

---

> READ CLAUDE.md FIRST before starting. It contains all architectural rules.
> After finishing, write `_CLAUDE/REPORTS/REPORT-001.md` and commit it.

---

## YOUR JOB RIGHT NOW

Build the foundation of "Kernel Flow OS" — a private internal business dashboard for Kernel Flow GmbH (Swiss AI & Content agency, owner Floris Kern).

This is an internal tool, NOT the public website. Full spec: `_Lovable_Prompt/KERNEL_FLOW_OS_PROMPT.md`

---

## STEP 1 — Project Setup

Create a React + TypeScript + Tailwind CSS app with:
- Shadcn/ui (dark theme, install with `npx shadcn@latest init`)
- React Router v6
- Sonner (toasts)
- Recharts
- Lucide React

Connect to Supabase via Lovable's built-in Supabase integration.

---

## STEP 2 — Design System

Add to tailwind.config.ts:
```js
colors: {
  kernel: {
    bg: '#0A0A0A',
    surface: '#111111',
    surface2: '#1A1A1A',
    primary: '#2563EB',
    accent: '#7C3AED',
    success: '#10B981',
    warning: '#F59E0B',
    danger: '#EF4444',
    text: '#F8FAFC',
    muted: '#94A3B8',
  }
}
```

Always add `dark` class to `<html>` element. Dark mode only.
Font: Inter.

---

## STEP 3 — Supabase Schema

Run this SQL in your Supabase project (SQL Editor):

```sql
create table clients (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  client_id text unique,
  status text default 'Potenziell',
  branche text,
  kontaktperson text,
  email text,
  telefon text,
  adresse text,
  website text,
  tier text,
  letzter_kontakt date,
  notizen text,
  ordner_link text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table projects (
  id uuid default gen_random_uuid() primary key,
  titel text not null,
  auftrags_nr text unique,
  kunde_id uuid references clients(id) on delete set null,
  status text default 'Anfrage',
  typ text,
  prioritaet text default 'Standard',
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

create table project_deliverables (
  id uuid default gen_random_uuid() primary key,
  project_id uuid references projects(id) on delete cascade,
  text text not null,
  completed boolean default false,
  sort_order integer default 0
);

create table time_entries (
  id uuid default gen_random_uuid() primary key,
  project_id uuid references projects(id) on delete cascade,
  datum date not null,
  stunden numeric not null,
  notiz text,
  created_at timestamptz default now()
);

create table leads (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  anfrageart text,
  quelle text,
  budget_schaetzung numeric,
  status text default 'Neu',
  eingangsdatum date default current_date,
  naechste_aktion text,
  naechste_aktion_datum date,
  email text,
  telefon text,
  notizen text,
  created_at timestamptz default now()
);

create table services (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  service_id text unique,
  kategorie text,
  beschreibung text,
  preis_von numeric,
  preis_bis numeric,
  aufwand_stunden numeric,
  vor_ort_minuten integer,
  nachbearbeitung_stunden numeric,
  lieferumfang text,
  status text default 'Entwurf',
  notizen text,
  created_at timestamptz default now()
);

create table content_items (
  id uuid default gen_random_uuid() primary key,
  titel text not null,
  plattform text[],
  format text,
  status text default 'Idee',
  geplantes_datum date,
  fuer_kunde_id uuid references clients(id) on delete set null,
  fuer_eigene boolean default true,
  hook text,
  script text,
  hashtags text,
  datei_link text,
  performance_score integer,
  tags text[],
  created_at timestamptz default now()
);

create table invoices (
  id uuid default gen_random_uuid() primary key,
  rechnungs_nr text unique,
  kunde_id uuid references clients(id) on delete set null,
  projekt_id uuid references projects(id) on delete set null,
  betrag numeric not null,
  mwst_prozent numeric default 8.1,
  status text default 'Entwurf',
  ausstellungsdatum date default current_date,
  faelligkeitsdatum date,
  beschreibung text,
  notizen text,
  created_at timestamptz default now()
);

create table open_loops (
  id uuid default gen_random_uuid() primary key,
  loop text not null,
  status text default 'Offen',
  leverage text default 'Mittel',
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

create table prompts (
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

create table partner (
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

create table roadmap (
  id uuid default gen_random_uuid() primary key,
  ziel text not null,
  phase text,
  kategorie text,
  status text default 'Geplant',
  zieldatum date,
  erfolgsmetrik text,
  beschreibung text,
  prioritaet text default 'Mittel',
  created_at timestamptz default now()
);

create table activity_log (
  id uuid default gen_random_uuid() primary key,
  action text not null,
  entity_type text not null,
  entity_name text,
  created_at timestamptz default now()
);
```

Disable RLS on all tables (this is a single-user MVP, no auth needed).

---

## STEP 4 — Seed Data

Insert this data via Supabase SQL editor or via a seed function in the app:

```sql
-- CLIENTS
insert into clients (name, client_id, status, branche, kontaktperson, tier) values
  ('GLP', 'CL-001', 'Aktiv', 'Politik', 'Tobias Meier Kern', 'Standard'),
  ('Sportanlagen AG Wallisellen', 'CL-002', 'Potenziell', 'Sport', 'Oliver Galliker', 'Standard'),
  ('Gaphiland', 'CL-003', 'Aktiv', 'Design', null, 'Standard'),
  ('SIUC', 'CL-004', 'Potenziell', 'Sonstiges', 'Marianne', 'One-off'),
  ('Klang.Vibes', 'CL-005', 'Potenziell', 'Musik/Events', 'Sandra Schöb-Brunner', 'One-off'),
  ('HUGG', 'CL-006', 'Potenziell', 'Sonstiges', null, 'One-off');

-- SERVICES
insert into services (name, service_id, kategorie, preis_von, aufwand_stunden, vor_ort_minuten, nachbearbeitung_stunden, status, beschreibung) values
  ('Social Media Video 15 Sek. – Light Packet', 'S-001', 'Video', 300, 3, 30, 1, 'Aktiv', '15 Sek Social Media Video – Perfekt für schnelle, knackige Content-Snippets. Inkl. 30 Min Dreh, 1h Schnitt, 1 Korrekturschleife.'),
  ('Social Media Video 30 Sek. – Medium Packet', 'S-002', 'Video', 425, 4, 45, 1.5, 'Aktiv', '30 Sek Social Media Video – Ideal für ausführlichere Stories. Inkl. 45 Min Dreh, 1.5h Schnitt, 2 Korrekturschleifen.'),
  ('Social Media Video 45 Sek. – Large Packet', 'S-003', 'Video', 540, 5, 60, 2, 'Aktiv', '45 Sek Social Media Video – Für umfangreiche Content-Pieces. Inkl. 60 Min Dreh, 2h Schnitt, 2 Korrekturschleifen.'),
  ('Social Media Video 60 Sek. – Premium Packet', 'S-004', 'Video', 650, 6, 75, 2.5, 'Aktiv', '60 Sek Social Media Video – Premium-Qualität. Inkl. 75 Min Dreh, 2.5h Schnitt, 3 Korrekturschleifen.'),
  ('Event Begleitung – Bild und Video', 'S-005', 'Event', 800, 8, 240, 4, 'Aktiv', 'Professionelle Event-Begleitung mit Foto & Video.'),
  ('Sponsoren Suche, Vermittlung, Verhandlung', 'S-006', 'Consulting', null, null, null, null, 'Aktiv', null),
  ('IT Support', 'S-007', 'IT-Support', null, null, null, null, 'Entwurf', null),
  ('AI Crashkurs (GPT richtig im Alltag einsetzen)', 'S-008', 'AI-Automation', null, null, null, null, 'Entwurf', null),
  ('AI Workflows', 'S-009', 'AI-Automation', null, null, null, null, 'Entwurf', null),
  ('Webseite Unterhalt', 'S-010', 'Sonstiges', null, null, null, null, 'Entwurf', null);

-- PARTNER
insert into partner (name, email, telefon, status) values
  ('Fasson', 'vb@fasoon.ch', '+41 71 523 12 57', 'Potenziell');

-- LEADS
insert into leads (name, anfrageart, quelle, budget_schaetzung, status, eingangsdatum, notizen) values
  ('dfddf (test)', 'Projektanfrage', 'Website', 1000, 'Neu', '2026-01-06', 'Social Media Shortform Video interest');

-- CONTENT
insert into content_items (titel, plattform, format, status, fuer_eigene, script) values
  ('Introduction Video', ARRAY['Instagram', 'TikTok', 'YouTube'], 'Short', 'Idee', true, 'Vorstellung von Floris und Kernel Flow GmbH');
```

For projects, insert after getting client IDs from the clients table.

---

## STEP 5 — App Layout Shell

Create `src/components/layout/Layout.tsx` — the persistent shell:
- Left sidebar (240px, fixed)
- Main content area (flex-1, scrollable)
- Sidebar contains: logo, nav items, bottom company info

Create `src/components/layout/Sidebar.tsx`:
- Nav items with icons (Lucide), label, active state
- Active = bg surface2 + left border primary + text white
- Inactive = text muted, hover bg surface2
- Bottom: "Kernel Flow GmbH" + "v0.1"

---

## STEP 6 — Dashboard Page

Build `src/pages/Dashboard.tsx` with:

**Top row — 4 stat cards:**
- Revenue this month: CHF 0 / CHF 3.000 goal (progress bar showing 0%)
- Active projects: count from DB (should be 2 — KF-001 In Arbeit, KF-002,003,004 are Anfrage)
- Open leads: count from leads table
- Open loops: count (0 for now)

**Quick Actions bar:**
- 5 buttons: [+ Auftrag] [+ Kunde] [+ Lead] [+ Loop] [+ Rechnung]
- Clicking them opens a basic create modal (can be simple for now)

**Active Projects list:**
- Show projects with status not 'Abgeschlossen', max 5
- Each row: Auftrags-Nr badge, Titel, Kunde name, Status badge (color coded), Deadline (if set, show days remaining)

**Recent Activity:**
- Show last 10 entries from activity_log
- If empty (no activity yet): show "Keine Aktivität – starte, indem du einen Kunden oder Auftrag erstellst."

---

## STEP 7 — Stub Pages

For each section, create a minimal page:
```tsx
// Example: src/pages/Kunden.tsx
export default function Kunden() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-semibold text-kernel-text">Kunden</h1>
      <p className="text-kernel-muted mt-2">Wird in TASK-002 gebaut.</p>
    </div>
  )
}
```
Do this for: Kunden, Aufträge, Pipeline, Services, Content, Finanzen, Open Loops, Prompts, Partner, Roadmap, Settings.

---

## STEP 8 — Report

After you're done, create `_CLAUDE/REPORTS/REPORT-001.md` using this template:

```markdown
# REPORT-001 — Initial App Build

**Date:** [today]
**Task:** TASK-001
**Status:** COMPLETE / PARTIAL / BLOCKED

## What I Built
[bullet list]

## Files Changed
[list]

## Decisions I Made
[any choices you made independently + WHY]

## Deviations from Task
[anything different from spec]

## What Still Needs Work
[anything skipped or incomplete]

## Questions for Claude
[blockers or unclear things]

## How to Test
[what to click to verify it works]
```

Commit this file along with all code.

---

## IMPORTANT

- Read `CLAUDE.md` for architectural rules
- All data goes to Supabase, not localStorage
- Dark mode only (add `dark` class to html permanently)
- Commit message: `feat(TASK-001): initial app foundation + dashboard`
- Push to the GitHub repo
