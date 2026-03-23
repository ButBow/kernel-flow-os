# Kernel Flow OS — Lovable Prompt

**Project:** Internal business operating system for Kernel Flow GmbH
**Owner:** Floris Kern
**Date:** 2026-03-23
**Lovable credits budget:** 400 credits / 10 days

---

## HOW TO USE THIS

1. Go to lovable.dev → New Project
2. Copy EVERYTHING below the line "=== START PROMPT ==="
3. Paste into Lovable and generate
4. Then iterate section by section (see iteration order below)
5. Connect Supabase early (free tier) so data persists

**Iteration order after first build:**
1. Fix any layout issues on Dashboard
2. Finanzen — make sure charts render
3. Aufträge Kanban — drag-and-drop
4. Open Loops — leverage sorting + age highlighting
5. Prompts — copy-to-clipboard
6. Content Calendar view
7. Global search (Cmd+K)
8. Mobile responsiveness

---

=== START PROMPT ===

Build me a complete internal business operating system called "Kernel Flow OS" for my Swiss AI & Content agency "Kernel Flow GmbH".

This is NOT a public website — it is my private daily operating system. I run it in the browser as a web app. It replaces Notion as my single source of truth.

Tech stack: React, TypeScript, Tailwind CSS, Supabase (for all data persistence), React Router, Recharts for charts. Dark mode only.

---

## BRAND & DESIGN

Company: Kernel Flow GmbH
Owner: Floris Kern
Domain: kernelflow.ch
Slogan: "Effizienz durch Technologie & Kreativität"

Design system:
- Background: #0A0A0A (near black)
- Surface: #111111 / #1A1A1A (cards, sidebar)
- Primary: #2563EB (electric blue)
- Accent: #7C3AED (purple)
- Success: #10B981
- Warning: #F59E0B
- Danger: #EF4444
- Text: #F8FAFC (primary), #94A3B8 (muted)
- Font: Inter
- Vibe: premium Swiss precision meets modern AI startup
- All UI elements: rounded-lg, subtle shadows, clean spacing
- No gradients unless very subtle. No flashy animations.

---

## APP STRUCTURE

Sidebar (always visible desktop, hamburger mobile) with these sections:

1. 🏠 Dashboard
2. 👥 Kunden
3. 📋 Aufträge
4. 🔮 Pipeline (Leads)
5. 🛠️ Services
6. 📱 Content
7. 💰 Finanzen
8. 🔁 Open Loops
9. 🧠 Prompts
10. 🤝 Partner
11. 🗺️ Roadmap
12. ⚙️ Settings

Active section highlighted in sidebar. React Router for navigation. Toast notifications (sonner) for all CRUD actions. Confirmation dialogs for deletes. Modal forms for create/edit (not separate pages). Sortable, filterable data tables throughout.

---

## 1. DASHBOARD

The command center. First thing I see every morning.

Layout (grid):
- Top row: 4 stat cards
  - Revenue this month: CHF — vs monthly goal (progress bar)
  - Active projects: count + status mini-breakdown
  - Open leads in pipeline: count
  - Open loops: count (flagged if any are >7 days old)

- Middle: Quick Actions bar
  Buttons: [+ Auftrag] [+ Kunde] [+ Lead] [+ Loop] [+ Rechnung]

- Left column: Active Projects (top 5, kanban-style mini-cards with client, status badge, deadline countdown)

- Right column: Daily Brief
  - 3 urgent items today (from open loops, deadlines)
  - Drafts waiting action
  - Content due this week
  - Upcoming deadlines (next 7 days)

- Bottom: Recent Activity feed (last 10 CRUD actions across the app)

---

## 2. KUNDEN (CRM)

Table view + card view toggle.

Fields per client:
- Name (title)
- Client ID (auto: CL-001, CL-002…)
- Status: Aktiv / Potenziell / Inaktiv / Archiviert
- Branche (select): Video / AI / Politik / Sport / Design / Gastronomie / IT / Sonstiges
- Kontaktperson
- Email
- Telefon
- Adresse
- Website
- Tier: Premium / Standard / One-off
- Letzter Kontakt (date)
- Revenue Total (CHF, auto-calculated from linked invoices)
- Notizen
- Ordner Link (text field for local path)

Client detail page (click a client):
- All info editable inline
- Linked Aufträge (list)
- Linked Invoices / Revenue
- Linked Open Loops
- Activity history

Pre-populate these clients:
1. GLP | Branche: Politik | Kontakt: Tobias Meier Kern | Status: Aktiv | Tier: Standard
2. Sportanlagen AG Wallisellen | Adresse: Alte Winterthurerstrasse 62, 8304 Wallisellen | Email: oliver.galliker@sportanlagen-wallisellen.ch | Telefon: +41 44 830 43 40 | Kontakt: Oliver Galliker | Status: Potenziell | Branche: Sport
3. Gaphiland | Status: Aktiv | Branche: Design

Pre-populate these potential clients:
4. SIUC / Marianne | Status: Potenziell | Bereich: Social Media, Sponsorensuche
5. Klang.Vibes | Email: welcome@klang-vibes.ch | Kontakt: Sandra Schöb-Brunner | Status: Potenziell | Branche: Musik/Events
6. HUGG | Status: Potenziell | Branche: Sonstiges

---

## 3. AUFTRÄGE (Project Management)

Kanban board (default) + list view toggle.

Fields per Auftrag:
- Titel (title)
- Auftrags-Nr (auto: KF-001, KF-002…)
- Kunde (linked to Kunden DB)
- Status: Anfrage / In Arbeit / Review / Abgeliefert / Abgeschlossen / Archiviert
- Typ: Video / Foto / Automation / Consulting / Website / Event / Sonstiges
- Priorität: Hoch / Standard / Niedrig
- Startdatum (date)
- Deadline (date) — show red if past due
- Budget (CHF)
- Stunden Geschätzt (number)
- Stunden Geloggt (number, with inline time entry)
- Deliverables (checklist — multiple items, checkable)
- Beschreibung
- Ordner Link
- Notizen

Kanban columns: Anfrage | In Arbeit | Review | Abgeliefert | Abgeschlossen

Project detail page:
- All fields editable
- Deliverables checklist (checkable inline)
- Time entries log (date, hours, note)
- Linked invoice(s)
- Open Loops linked to this project

Pre-populate:
1. Werbekampagne Tobias Meier | KF-001 | Kunde: GLP | Status: In Arbeit | Typ: Video | Startdatum: 19.01.2026
2. Sportanlagen Eis Disco | KF-002 | Kunde: Sportanlagen AG Wallisellen | Status: Anfrage | Typ: Video/Foto/Event
3. GLP Vorstands Foto | KF-003 | Kunde: GLP | Status: Anfrage | Typ: Foto
4. Airbnb Website | KF-004 | Status: Anfrage | Typ: Website

---

## 4. PIPELINE (Lead Management)

Kanban pipeline for new business.

Fields:
- Name / Firma (title)
- Anfrageart: Projektanfrage / Monatsabo / Consulting / Sonstiges
- Quelle: Instagram / Referral / Website / Kalt / Fiverr / Sonstiges
- Paket Interesse (linked to Services)
- Budget Schätzung (CHF)
- Status: Neu / Kontaktiert / Discovery Call / Angebot Gesendet / Gewonnen / Verloren
- Eingangsdatum
- Nächste Aktion (text + date)
- Email / Telefon
- Notizen

Kanban columns: Neu | Kontaktiert | Discovery Call | Angebot Gesendet | Gewonnen | Verloren

Pre-populate:
1. dfddf test | Anfrageart: Projektanfrage | Quelle: Website | Budget: <CHF 1.000 | Status: Neu | Eingangsdatum: 06.01.2026 | Paket: Social Media Shortform Video

---

## 5. SERVICES (Leistungskatalog)

Table view of all service offerings.

Fields:
- Name (title)
- ID (auto: S-001…)
- Kategorie: Video / Foto / AI-Automation / Event / IT-Support / Sonstiges
- Beschreibung
- Basispreis CHF
- Aufwand Stunden
- Vor-Ort Zeit (Minuten)
- Nachbearbeitung Stunden
- Lieferumfang (multi-line text)
- Status: Aktiv / Entwurf / Archiviert

Pre-populate exactly:
1. Social Media Video 15 Sek. | Light Packet | CHF 300 | Status: Aktiv | Aufwand: 3h | Vor-Ort: 30min
2. Social Media Video 30 Sek. | Medium Packet | CHF 425 | Status: Aktiv | Aufwand: 4h | Vor-Ort: 45min
3. Social Media Video 45 Sek. | Large Packet | CHF 540 | Status: Aktiv | Aufwand: 5h | Vor-Ort: 60min
4. Social Media Video 60 Sek. | Premium Packet | CHF 650 | Status: Aktiv | Aufwand: 6h | Vor-Ort: 75min
5. Event Begleitung | Bild und Video | CHF 800 | Status: Aktiv | Aufwand: 8h | Vor-Ort: 240min | Lieferumfang: Bearbeitetes Video (3-5 Min Highlight), 20-30 bearbeitete Fotos, Alle Rohaufnahmen, 1 Korrekturschleife
6. Sponsoren Suche, Vermittlung, Verhandlung | Status: Aktiv | Kategorie: Consulting
7. IT Support | Status: Entwurf | Kategorie: IT-Support
8. AI Crashkurs (GPT richtig im Alltag einsetzen) | Status: Entwurf | Kategorie: AI-Automation
9. AI Workflows | Status: Entwurf | Kategorie: AI-Automation
10. Webseite Unterhalt | Status: Entwurf | Kategorie: Sonstiges

---

## 6. CONTENT (Social Media Planner)

Views: Calendar (monthly) | Kanban (by status) | Table

Fields:
- Titel (title)
- Plattform (multi-select): Instagram / TikTok / YouTube / LinkedIn / Facebook
- Format: Short (≤60s) / Reel / Post / Story / Long-form / Foto
- Status: 💡 Idee / ✍️ In Produktion / ✅ Fertig / 📅 Geplant / 🚀 Veröffentlicht
- Geplantes Datum
- Für: Kernel Flow (eigene) / linked Kunde
- Hook / Headline (text)
- Script / Notizen (long text)
- Hashtags
- Datei Link
- Performance Score (1-10, fillable after publish)
- Tags

Kanban columns: Idee | In Produktion | Fertig | Geplant | Veröffentlicht

Pre-populate:
1. Introduction Video | 60s | Instagram, TikTok, YouTube | Status: Idee | Für: Kernel Flow | Script/Notizen: Vorstellung von Floris und Kernel Flow GmbH

---

## 7. FINANZEN

### Invoices section
Fields:
- Rechnungs-Nr (auto: RE-2026-001…)
- Kunde (linked)
- Auftrag (linked, optional)
- Betrag CHF
- MwSt % (default 8.1% Swiss VAT)
- Gesamt CHF (auto-calculated)
- Status: Entwurf / Gesendet / Bezahlt / Überfällig
- Ausstellungsdatum
- Fälligkeitsdatum (default: +30 days)
- Leistungsbeschreibung
- Notizen

### Dashboard widgets:
- Total Revenue this month (CHF)
- Outstanding invoices total
- Overdue (red alert)
- Revenue this year
- Monthly revenue bar chart (last 6 months) using Recharts
- Revenue by client pie chart
- Revenue goals progress:
  - Tier 1 Goal: CHF 3.000/month (video cashflow)
  - Tier 2 Goal: CHF 5.000/month (with automation)
  - Tier 3 Goal: CHF 7.000/month (SaaS target)

---

## 8. OPEN LOOPS

Fields:
- Loop (title)
- Status: Offen / Wartet / Erledigt / Archiviert
- Leverage: Hoch / Mittel / Niedrig
- Deadline (date, optional)
- Kunde (linked, optional)
- Auftrag (linked, optional)
- Quelle: WhatsApp / Email / Meeting / Notion / Eigene / Sonstiges
- Owner: Ich / Editor / Partner / Extern
- Beteiligte Personen
- Nächste Aktion (text)
- Notizen

Default view: Offen loops only, sorted by Leverage (Hoch first), then by age (oldest first).
Highlight loops older than 7 days with amber, older than 14 days with red.
Nothing auto-closes. Manual confirmation only.

---

## 9. PROMPTS (AI Library)

Fields:
- Titel (title)
- Kategorie: Business / Outreach / Content / Coding / Research / Analysis / Sonstiges
- Prompt Text (long text)
- Tags (multi-select)
- Favorit (boolean, star toggle)
- Zuletzt genutzt (date)
- Notizen

Features:
- Big copy-to-clipboard button on every prompt card
- Markdown preview for prompt text
- Search by title/tag/category
- Favorites pinned at top
- Card view (default) + table view

---

## 10. PARTNER

Fields:
- Name (title)
- Typ: Tech / Creative / Referral / Dienstleister
- Kontaktperson / Email / Telefon
- Services / Kompetenzen
- Status: Aktiv / Potenziell / Archiviert
- Revenue Share %
- Notizen / Website

Pre-populate:
1. Fasson | Email: vb@fasoon.ch | Telefon: +41 71 523 12 57 | Status: Potenziell

---

## 11. ROADMAP

Fields:
- Ziel (title)
- Phase: Phase 1 (M1-2) / Phase 2 (M3-4) / Phase 3 (M5-6) / Laufend
- Kategorie: Revenue / Produkt / Marketing / Ops / Legal / Tech
- Status: Geplant / In Progress / Erreicht / Verschoben
- Zieldatum
- Erfolgsmetrik
- Beschreibung
- Priorität: Hoch / Mittel / Niedrig

Views: Timeline (grouped by phase) | Table | Kanban by status

Pre-populate (3 phases with goals: CHF 2.5-3.5k → 3.5-5k → 5-7k/month)

---

## 12. SETTINGS

- Company info (editable)
- Monthly revenue goals (editable Tier 1/2/3)
- Data export (JSON/CSV)
- Supabase connection status

---

## SUPABASE SCHEMA

Tables: clients, projects, project_deliverables, time_entries, leads, services, content, invoices, open_loops, prompts, partner, roadmap, activity_log — all with proper FK relations.

---

## UX DETAILS

- Global search (Cmd+K) across clients, projects, loops
- Empty states with helpful message + CTA per section
- All dates: DD.MM.YYYY (Swiss format)
- Currency: CHF X.XXX
- Status badges: color-coded chips
- Sidebar notification dot on Open Loops if HIGH leverage loops unresolved
- Mobile: bottom nav with icons

Language: German for business terms, English for UI chrome. Mix is intentional.
