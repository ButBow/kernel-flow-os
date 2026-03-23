# TASK-001 — Initial App Build (Foundation)

**Assigned by:** Claude (Orchestrator)
**Date:** 2026-03-23
**Priority:** Critical — this is the foundation everything else builds on
**Estimated credits:** 20-35

---

## Context

We are building "Kernel Flow OS" — a private internal business dashboard for Kernel Flow GmbH (Swiss AI & Content agency). Owner: Floris Kern.

This is NOT the public website (kernelflow.ch). This is the internal tool.

Full spec is in: `_Lovable_Prompt/KERNEL_FLOW_OS_PROMPT.md`

Read CLAUDE.md first for architectural decisions and project overview.

---

## What to Build in This Task

### 1. Project Foundation
- Create a new React + TypeScript + Tailwind CSS app
- Install and configure Shadcn/ui (dark theme)
- Set up React Router v6 with all 12 routes
- Install: sonner (toasts), recharts, lucide-react
- Connect to Supabase (Lovable native integration)

### 2. Design System
Apply this exactly:
```css
/* tailwind.config — extend colors */
background: #0A0A0A
surface: #111111, #1A1A1A
primary: #2563EB
accent: #7C3AED
success: #10B981
warning: #F59E0B
danger: #EF4444
text-primary: #F8FAFC
text-muted: #94A3B8
```
Font: Inter (import from Google Fonts or use system)
Dark mode: class-based, always active (add `dark` class to html element permanently)

### 3. Layout Shell
Build the persistent app shell:

**Sidebar (desktop):**
- Fixed left sidebar, 240px wide, bg #111111
- App logo/name at top: "KF OS" in primary blue + "Kernel Flow OS" small muted text
- Navigation items (icon + label):
  - 🏠 Dashboard → /
  - 👥 Kunden → /kunden
  - 📋 Aufträge → /auftraege
  - 🔮 Pipeline → /pipeline
  - 🛠️ Services → /services
  - 📱 Content → /content
  - 💰 Finanzen → /finanzen
  - 🔁 Open Loops → /loops
  - 🧠 Prompts → /prompts
  - 🤝 Partner → /partner
  - 🗺️ Roadmap → /roadmap
  - ⚙️ Settings → /settings
- Active item: bg #1A1A1A, left border 3px #2563EB, text white
- Inactive: text #94A3B8, hover bg #1A1A1A
- Notification dot on "Open Loops" nav item (amber dot, will be dynamic later)
- Bottom of sidebar: small text "Kernel Flow GmbH" + version "v0.1"

**Mobile:**
- Sidebar hidden, hamburger button top-left opens it as overlay
- OR: bottom navigation bar with icons only (5 most important sections)

**Main content area:**
- Right of sidebar, full height, bg #0A0A0A
- Top bar: page title (dynamic) + right side: quick action button relevant to current page

### 4. Supabase Database Schema
Create ALL tables now so relations work from day 1:

```sql
-- Run these in Supabase SQL editor

create table clients (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  client_id text unique, -- auto: CL-001
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

create table projects (
  id uuid default gen_random_uuid() primary key,
  titel text not null,
  auftrags_nr text unique, -- auto: KF-001
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

create table content (
  id uuid default gen_random_uuid() primary key,
  titel text not null,
  plattform text[], -- array: Instagram, TikTok, etc.
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
  rechnungs_nr text unique, -- auto: RE-2026-001
  kunde_id uuid references clients(id) on delete set null,
  projekt_id uuid references projects(id) on delete set null,
  betrag numeric not null,
  mwst_prozent numeric default 8.1,
  gesamt numeric generated always as (betrag * (1 + mwst_prozent / 100)) stored,
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
  phase text, -- Phase 1 (M1-2) / Phase 2 (M3-4) / Phase 3 (M5-6)
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
  action text not null, -- created/updated/deleted
  entity_type text not null, -- client/project/lead/etc.
  entity_name text,
  created_at timestamptz default now()
);
```

**Disable RLS on all tables for now (MVP, single user).**

### 5. Seed Data
Insert this real data into the database:

**Clients:**
- GLP | status: Aktiv | branche: Politik | kontaktperson: Tobias Meier Kern | tier: Standard
- Sportanlagen AG Wallisellen | adresse: Alte Winterthurerstrasse 62, 8304 Wallisellen | email: oliver.galliker@sportanlagen-wallisellen.ch | telefon: +41 44 830 43 40 | kontaktperson: Oliver Galliker | status: Potenziell | branche: Sport
- Gaphiland | status: Aktiv | branche: Design
- SIUC | status: Potenziell | notizen: Bereich Social Media, Sponsorensuche – Kontakt: Marianne
- Klang.Vibes | status: Potenziell | email: welcome@klang-vibes.ch | kontaktperson: Sandra Schöb-Brunner | branche: Musik/Events
- HUGG | status: Potenziell

**Projects:**
- Werbekampagne Tobias Meier | KF-001 | kunde: GLP | status: In Arbeit | typ: Video | startdatum: 2026-01-19
- Sportanlagen Eis Disco | KF-002 | kunde: Sportanlagen AG Wallisellen | status: Anfrage | typ: Event
- GLP Vorstands Foto | KF-003 | kunde: GLP | status: Anfrage | typ: Foto
- Airbnb Website | KF-004 | status: Anfrage | typ: Website

**Services (exact):**
- S-001 | Social Media Video 15 Sek. – Light Packet | CHF 300 | Aktiv | aufwand: 3h | vor_ort: 30min | nachbearbeitung: 1h | beschreibung: 15 Sek Social Media Video – Perfekt für schnelle, knackige Content-Snippets. Inkl. 30 Min Dreh, 1h Schnitt, 1 Korrekturschleife.
- S-002 | Social Media Video 30 Sek. – Medium Packet | CHF 425 | Aktiv | aufwand: 4h | vor_ort: 45min | nachbearbeitung: 1.5h
- S-003 | Social Media Video 45 Sek. – Large Packet | CHF 540 | Aktiv | aufwand: 5h | vor_ort: 60min | nachbearbeitung: 2h
- S-004 | Social Media Video 60 Sek. – Premium Packet | CHF 650 | Aktiv | aufwand: 6h | vor_ort: 75min | nachbearbeitung: 2.5h
- S-005 | Event Begleitung – Bild und Video | CHF 800 | Aktiv | aufwand: 8h | vor_ort: 240min | lieferumfang: Bearbeitetes Video (3-5 Min Highlight)\n20-30 bearbeitete Fotos\nAlle Rohaufnahmen\n1 Korrekturschleife
- S-006 | Sponsoren Suche, Vermittlung, Verhandlung | Aktiv | kategorie: Consulting
- S-007 | IT Support | Entwurf | kategorie: IT-Support
- S-008 | AI Crashkurs (GPT richtig im Alltag einsetzen) | Entwurf | kategorie: AI-Automation
- S-009 | AI Workflows | Entwurf | kategorie: AI-Automation
- S-010 | Webseite Unterhalt | Entwurf

**Leads:**
- dfddf (test) | anfrageart: Projektanfrage | quelle: Website | budget: 1000 | status: Neu | eingangsdatum: 2026-01-06 | notizen: Social Media Shortform Video interest

**Partner:**
- Fasson | email: vb@fasoon.ch | telefon: +41 71 523 12 57 | status: Potenziell

**Roadmap (Phase 1):**
- Firmengründung abschliessen | Phase 1 | kategorie: Legal | status: In Progress
- Basis-Website live | Phase 1 | kategorie: Marketing | status: Erreicht
- 2-3 Stammkunden Video Editing | Phase 1 | kategorie: Revenue | erfolgsmetrik: CHF 2.500-3.500/Monat | status: In Progress
- Fiverr-Profil aufsetzen | Phase 1 | kategorie: Marketing | status: Geplant
- Portfolio aufbauen | Phase 1 | kategorie: Marketing | status: In Progress

**Roadmap (Phase 2):**
- Erstes AI-Automation Projekt | Phase 2 | kategorie: Revenue | erfolgsmetrik: CHF 300-600 eingenommen | status: Geplant
- LinkedIn/Twitter Präsenz | Phase 2 | kategorie: Marketing | status: Geplant
- Micro-SaaS Idee validieren | Phase 2 | kategorie: Produkt | status: Geplant
- CHF 3.500-5.000/Monat | Phase 2 | kategorie: Revenue | status: Geplant

**Roadmap (Phase 3):**
- SaaS Beta Launch | Phase 3 | kategorie: Produkt | status: Geplant
- Pro AI Workspace Paket anbieten | Phase 3 | kategorie: Revenue | status: Geplant
- CHF 5.000-7.000/Monat | Phase 3 | kategorie: Revenue | status: Geplant

**Content:**
- Introduction Video | plattform: [Instagram, TikTok, YouTube] | format: Short | status: Idee | fuer_eigene: true | script: Vorstellung von Floris und Kernel Flow GmbH

**Prompt:**
- Neue Kunden anschreiben | kategorie: Outreach | tags: [Email, Kaltakquise] | prompt_text: [Full German outreach prompt — 3-phase system: Phase 1 Recherche & Einordnung, Phase 2 Angebotene Perspektive, Phase 3 E-Mail erstellen. Tonalität: ruhig, respektvoll, selbstsicher, neugierig, max 120-150 Wörter, kein Sales-Pitch, kein Druck]

### 6. Dashboard Page (Basic)
Build the Dashboard page with:
- 4 stat cards (Revenue, Active Projects, Open Leads, Open Loops) — pull real counts from Supabase
- Quick Actions bar (5 buttons: + Auftrag, + Kunde, + Lead, + Loop, + Rechnung)
- Active Projects list (top 5, with client name, status badge, deadline)
- Recent Activity feed (from activity_log table, last 10 entries)
- Revenue goal progress bars (hardcode goals: T1=3000, T2=5000, T3=7000 CHF for now, revenue=0 since no invoices)

### 7. Stub Pages
For all other sections (Kunden, Aufträge, etc.), create placeholder pages that:
- Show the correct page title
- Have a "Coming in next task" message with the section icon
- Have the correct sidebar navigation working

---

## What NOT to Build in This Task

- Do not build detailed CRUD forms for every section yet — just the Dashboard fully
- Do not build charts in Finanzen yet
- Do not build Kanban views yet
- Do not build the Settings page yet

Focus: Foundation + database + shell + Dashboard + data seed.

---

## Definition of Done

- [ ] App loads without errors
- [ ] All 12 sidebar nav items work (navigate without crash)
- [ ] Dashboard shows real data from Supabase (counts are correct)
- [ ] All seed data is in the database
- [ ] Supabase connection is working (not localStorage)
- [ ] Dark theme applied correctly everywhere
- [ ] Sidebar looks correct on desktop
- [ ] `_CLAUDE/REPORTS/REPORT-001.md` committed with full report

---

## Report Required

After completing this task, write `_CLAUDE/REPORTS/REPORT-001.md` following the CLAUDE.md report template. Include every file you created and every architectural decision you made.
