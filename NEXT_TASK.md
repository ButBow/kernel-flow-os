# NEXT TASK FOR LOVABLE — TASK-002

**Orchestrated by:** Claude (AI Orchestrator)
**Task:** TASK-002 — Full CRUD + Kanban + Charts
**Date:** 2026-03-23

> After finishing, write `_CLAUDE/REPORTS/REPORT-002.md` and commit it.
> See `_CLAUDE/TASKS/TASK-002-full-crud.md` for the complete detailed spec.

---

## OVERVIEW

All pages currently only READ data. This task adds **create, edit, delete** to every business section, plus Kanban views and finance charts. Do them in this priority order.

---

## STEP 0 — Shared Infrastructure

### Activity Logger
Create `src/services/activityLog.ts`:
```ts
import { supabase } from "@/integrations/supabase/client"

export async function logActivity(action: string, entityType: string, entityName: string) {
  await supabase.from("activity_log").insert({ action, entity_type: entityType, entity_name: entityName })
}
```
Call this after EVERY create, update, delete across all pages.

### Delete Confirmation
Use Shadcn `AlertDialog` with "Bist du sicher?" — red destructive confirm button. Reuse across all sections.

### Status Badge Colors (use everywhere consistently)
- Green: Aktiv, Bezahlt, Erreicht, Gewonnen, Abgeschlossen, Fertig, Veröffentlicht, Erledigt
- Blue: In Arbeit, In Progress, In Produktion
- Amber: Anfrage, Wartet, Potenziell, Review, Geplant, Entwurf, Neu, Kontaktiert
- Red: Überfällig, Verloren
- Gray: Inaktiv, Archiviert

### Date/Currency Format
- Dates: `toLocaleDateString("de-CH")` → DD.MM.YYYY
- Currency: `CHF ${amount.toFixed(2)}`

---

## STEP 1 — Kunden (CRM)

Update `KundenPage.tsx`:

**"+ Neuer Kunde" button** opens a Shadcn Dialog modal with fields:
- Name (text, required)
- Status (select: Aktiv / Potenziell / Inaktiv / Archiviert)
- Branche (select: Video / AI / Politik / Sport / Design / Gastronomie / IT / Musik/Events / Sonstiges)
- Kontaktperson (text)
- Email (email)
- Telefon (text)
- Adresse (textarea)
- Website (url)
- Tier (select: Premium / Standard / One-off)
- Notizen (textarea)
- Ordner Link (text)

On save: auto-generate `client_id` as "CL-" + next number (query max existing). Insert into Supabase. Log activity. Toast success. Refetch list.

**Row actions:** Edit button (opens same modal pre-filled), Delete button (confirmation dialog).

**Click row → Detail Page** at `/kunden/:id`:
- All fields shown, edit button to open modal
- Section: "Aufträge" — query `projects` where `kunde_id` matches
- Section: "Rechnungen" — query `invoices` where `kunde_id` matches, show total
- Section: "Open Loops" — query `open_loops` where `kunde_id` matches
- Back button

---

## STEP 2 — Aufträge (Kanban + CRUD)

Rewrite `AuftraegePage.tsx`:

**Default: Kanban board**
- 5 columns: Anfrage | In Arbeit | Review | Abgeliefert | Abgeschlossen
- Each card shows: Auftrags-Nr badge, Titel, Kunde name, Deadline (red if past due), Priorität colored dot (Hoch=red, Standard=blue, Niedrig=gray)
- Click card → detail page
- **Status change:** Dropdown on each card OR drag-and-drop (your choice — dropdown is simpler and reliable)
- Toggle button to switch to List view (table)

**"+ Neuer Auftrag" modal fields:**
- Titel (required)
- Kunde (select dropdown from clients table)
- Status (select: Anfrage / In Arbeit / Review / Abgeliefert / Abgeschlossen)
- Typ (select: Video / Foto / Automation / Consulting / Website / Event / Sonstiges)
- Priorität (select: Hoch / Standard / Niedrig)
- Startdatum, Deadline (date pickers)
- Budget CHF (number)
- Stunden Geschätzt (number)
- Beschreibung, Ordner Link, Notizen (textareas)

Auto-generate `auftrags_nr`: "KF-" + next number.

**Detail Page `/auftraege/:id`:**
- All fields editable
- **Deliverables checklist:** Add new item (text input + add button), toggle checkbox, delete item. Uses `project_deliverables` table.
- **Time entries:** Add entry (date + hours + note), shows list + total hours vs estimated
- Linked invoices, linked open loops

---

## STEP 3 — Pipeline (Leads Kanban)

Rewrite `PipelinePage.tsx`:

**Kanban columns:** Neu | Kontaktiert | Discovery Call | Angebot Gesendet | Gewonnen | Verloren

Cards: Name/Firma, Quelle badge, Budget CHF, Nächste Aktion

**"+ Neuer Lead" modal:**
- Name/Firma (required)
- Anfrageart (select: Projektanfrage / Monatsabo / Consulting / Sonstiges)
- Quelle (select: Instagram / Referral / Website / Kalt / Fiverr / Sonstiges)
- Budget CHF (number)
- Status (select from columns)
- Eingangsdatum (date, default today)
- Nächste Aktion (text), Nächste Aktion Datum (date)
- Email, Telefon, Notizen

---

## STEP 4 — Finanzen (Charts + Invoice CRUD)

Rewrite `FinanzenPage.tsx`:

**Top: Dashboard widgets**
- 4 stat cards: Revenue this month, Outstanding, Overdue (red), Revenue this year
- Monthly revenue **bar chart** (Recharts `BarChart`) — last 6 months, sum of "Bezahlt" invoices per month
- Revenue by client **pie chart** (Recharts `PieChart`) — top 5 clients
- 3 progress bars for revenue goals: Tier 1 CHF 3.000, Tier 2 CHF 5.000, Tier 3 CHF 7.000

**Below: Invoice table + CRUD**
- Columns: Rechnungs-Nr, Kunde, Betrag, MwSt, Gesamt, Status, Fällig
- "Bezahlt" rows in green, "Überfällig" in red
- Create/Edit modal:
  - Kunde (select), Auftrag (select, optional), Betrag CHF, MwSt % (default 8.1)
  - Gesamt shown as read-only calculated field
  - Status, Ausstellungsdatum, Fälligkeitsdatum (+30 days default)
  - Beschreibung, Notizen
  - Auto-generate `rechnungs_nr`: "RE-2026-" + next number

---

## STEP 5 — Open Loops (CRUD + Age Highlighting)

Rewrite `OpenLoopsPage.tsx`:

**Default view:** Only status "Offen", sorted by Leverage (Hoch first) then age (oldest first)

**Age highlighting on each row:**
- Created > 7 days ago: amber left border (`border-l-4 border-warning`)
- Created > 14 days ago: red left border + red dot (`border-l-4 border-destructive`)

**Filter toggles:** Offen | Wartet | Alle

**Create/Edit modal:**
- Loop text (required — what needs to happen)
- Status (select: Offen / Wartet / Erledigt / Archiviert)
- Leverage (select: Hoch / Mittel / Niedrig)
- Deadline (date, optional)
- Kunde (select from clients, optional)
- Auftrag (select from projects, optional)
- Quelle (select: WhatsApp / Email / Meeting / Notion / Eigene / Sonstiges)
- Owner (select: Ich / Editor / Partner / Extern)
- Beteiligte (text)
- Nächste Aktion (text)
- Notizen (textarea)

---

## STEP 6 — Prompts (CRUD + Copy to Clipboard)

Rewrite `PromptsPage.tsx`:

**Card view (default):**
- Favorites (star toggle) pinned at top
- Each card: Titel, Kategorie badge, Tags, truncated prompt preview
- **Big "Copy" button** → `navigator.clipboard.writeText(prompt.prompt_text)` → toast "Prompt kopiert!"
- Click card to expand full prompt text (or toggle expand)
- Search bar filtering by title/tag/category

**Create/Edit modal:**
- Titel (required)
- Kategorie (select: Business / Outreach / Content / Coding / Research / Analysis / Sonstiges)
- Prompt Text (large textarea, this is the main content)
- Tags (comma-separated text input → stored as text[])
- Favorit (toggle)
- Notizen (textarea)

---

## STEP 7 — Remaining Sections

### Services
- Table with create/edit/delete
- Fields: Name, Kategorie, Beschreibung, Preis Von, Aufwand, Vor-Ort, Nachbearbeitung, Lieferumfang, Status
- Filter by Status: Aktiv / Entwurf / Alle

### Content (Social Media Planner)
- Kanban by status: Idee → In Produktion → Fertig → Geplant → Veröffentlicht
- Simple monthly calendar grid (just dots on dates that have content planned)
- Create/edit: Titel, Plattform (multi-checkbox), Format, Status, Geplantes Datum, Hook, Script, Hashtags, Tags

### Partner
- Table + create/edit/delete modal
- Fields: Name, Typ, Kontaktperson, Email, Telefon, Services, Status, Revenue Share %, Website, Notizen

### Roadmap
- Grouped by Phase (Phase 1, Phase 2, Phase 3 as sections with headers)
- Each goal card: Ziel, Status badge, Kategorie badge, Erfolgsmetrik
- Create/edit all fields from schema

---

## COMMIT & REPORT

- Commit: `feat(TASK-002): add full CRUD, Kanban views, finance charts`
- Create `_CLAUDE/REPORTS/REPORT-002.md` listing what was built per section
