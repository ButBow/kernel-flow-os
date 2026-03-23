# TASK-002 — Full CRUD + Kanban + Charts

**Assigned by:** Claude (Orchestrator)
**Date:** 2026-03-23
**Priority:** High — this makes the app actually usable
**Depends on:** TASK-001 (complete)

---

## Context

TASK-001 delivered a solid foundation: all pages exist, Supabase is connected, data is readable. But NO page has create/edit/delete functionality yet. This task adds full CRUD to all business sections, plus the Kanban view for Aufträge and charts for Finanzen.

**Split this task across multiple Lovable sessions if needed.** Do sections in order of priority.

---

## PRIORITY 1 — Shared CRUD Infrastructure

Before building individual pages, create reusable components:

### A. Generic Create/Edit Modal

Create `src/components/shared/FormModal.tsx`:
- Shadcn `Dialog` component
- Title, form fields, save/cancel buttons
- Loading state on save
- Calls Supabase insert/update
- Logs to `activity_log` after every create/update/delete
- Toast notification on success/error

### B. Generic Delete Confirmation

Create `src/components/shared/DeleteConfirm.tsx`:
- Shadcn `AlertDialog`
- "Bist du sicher?" message
- Confirm/Cancel buttons
- Red destructive styling

### C. Activity Logger Helper

Create `src/services/activityLog.ts`:
```ts
import { supabase } from "@/integrations/supabase/client"

export async function logActivity(action: string, entityType: string, entityName: string) {
  await supabase.from("activity_log").insert({
    action,
    entity_type: entityType,
    entity_name: entityName,
  })
}
```

Call this after EVERY create, update, and delete operation across all pages.

---

## PRIORITY 2 — Kunden (CRM) — Full CRUD + Detail Page

### Table View (update existing)
- Keep the existing table
- Add "Neuer Kunde" button that opens the Create Modal
- Each row: click to open Detail Page (new route `/kunden/:id`)
- Row actions: Edit (pencil icon), Delete (trash icon)

### Create/Edit Modal Fields
- Name (required, text)
- Status (select: Aktiv / Potenziell / Inaktiv / Archiviert)
- Branche (select: Video / AI / Politik / Sport / Design / Gastronomie / IT / Musik/Events / Sonstiges)
- Kontaktperson (text)
- Email (email input)
- Telefon (text)
- Adresse (textarea)
- Website (url input)
- Tier (select: Premium / Standard / One-off)
- Notizen (textarea)
- Ordner Link (text — local file path)

Auto-generate `client_id` on create: CL-XXX (next sequential number).

### Detail Page (`/kunden/:id`)
- Show all client fields, editable inline or via edit button
- **Linked Aufträge** — list of projects for this client
- **Linked Invoices** — list of invoices with total revenue sum
- **Linked Open Loops** — open loops tagged to this client
- Back button to Kunden list

---

## PRIORITY 3 — Aufträge (Projects) — Kanban + CRUD

### Kanban View (DEFAULT)
- Columns: **Anfrage** | **In Arbeit** | **Review** | **Abgeliefert** | **Abgeschlossen**
- Each card: Auftrags-Nr badge, Titel, Kunde name, Deadline (red if past), Priorität dot
- Drag-and-drop between columns to change status (use @dnd-kit/core or simple click-to-move)
- If drag-and-drop is complex, a dropdown on each card to change status is acceptable

### List View Toggle
- Table similar to current, but with action buttons

### Create/Edit Modal Fields
- Titel (required)
- Kunde (select dropdown — populated from clients table)
- Status (select: Anfrage / In Arbeit / Review / Abgeliefert / Abgeschlossen / Archiviert)
- Typ (select: Video / Foto / Automation / Consulting / Website / Event / Sonstiges)
- Priorität (select: Hoch / Standard / Niedrig)
- Startdatum (date picker)
- Deadline (date picker)
- Budget CHF (number)
- Stunden Geschätzt (number)
- Beschreibung (textarea)
- Ordner Link (text)
- Notizen (textarea)

Auto-generate `auftrags_nr`: KF-XXX.

### Detail Page (`/auftraege/:id`)
- All fields editable
- **Deliverables Checklist** — add/remove items, toggle complete (uses `project_deliverables` table)
- **Time Entries** — log hours (date + hours + note), shows total logged vs estimated
- **Linked Invoice(s)**
- **Linked Open Loops**

---

## PRIORITY 4 — Pipeline (Leads) — Kanban

### Kanban View (DEFAULT)
- Columns: **Neu** | **Kontaktiert** | **Discovery Call** | **Angebot Gesendet** | **Gewonnen** | **Verloren**
- Cards: Name, Quelle badge, Budget, next action
- Click-to-change-status or drag

### Create/Edit Modal Fields
- Name / Firma (required)
- Anfrageart (select: Projektanfrage / Monatsabo / Consulting / Sonstiges)
- Quelle (select: Instagram / Referral / Website / Kalt / Fiverr / Sonstiges)
- Budget Schätzung CHF (number)
- Status (select from kanban columns)
- Eingangsdatum (date, default today)
- Nächste Aktion (text)
- Nächste Aktion Datum (date)
- Email (email)
- Telefon (text)
- Notizen (textarea)

**On "Gewonnen":** Prompt to create a new Auftrag + Kunde from this lead.

---

## PRIORITY 5 — Finanzen — Charts + Invoice CRUD

### Invoice List
- Table: Rechnungs-Nr, Kunde, Betrag, MwSt, Gesamt, Status, Fällig
- Create/Edit modal:
  - Kunde (select from clients)
  - Auftrag (select from projects, optional)
  - Betrag CHF (number, required)
  - MwSt % (number, default 8.1)
  - Gesamt (auto-calculated: betrag * (1 + mwst/100), shown read-only)
  - Status (select: Entwurf / Gesendet / Bezahlt / Überfällig)
  - Ausstellungsdatum (date, default today)
  - Fälligkeitsdatum (date, default +30 days)
  - Leistungsbeschreibung (textarea)
  - Notizen (textarea)
- Auto-generate `rechnungs_nr`: RE-YYYY-XXX

### Dashboard Widgets (TOP of Finanzen page)
Use **Recharts**:
- **Monthly Revenue bar chart** — last 6 months, sum of `bezahlt` invoices per month
- **Revenue by Client pie chart** — top 5 clients by total bezahlt
- 4 stat cards: Total this month, Outstanding, Overdue (red), Total this year
- **Revenue Goals** — 3 progress bars:
  - Tier 1: CHF 3.000/month
  - Tier 2: CHF 5.000/month
  - Tier 3: CHF 7.000/month

---

## PRIORITY 6 — Open Loops — CRUD + Age Highlighting

### List View
- Default: show only `status = 'Offen'`
- Sort by: Leverage (Hoch first), then created_at (oldest first)
- **Age highlighting:**
  - Loop > 7 days old: amber left border
  - Loop > 14 days old: red left border + pulsing dot
- Filter toggles: Offen / Wartet / Alle

### Create/Edit Modal Fields
- Loop text (required, what needs to happen)
- Status (select: Offen / Wartet / Erledigt / Archiviert)
- Leverage (select: Hoch / Mittel / Niedrig)
- Deadline (date, optional)
- Kunde (select from clients, optional)
- Auftrag (select from projects, optional)
- Quelle (select: WhatsApp / Email / Meeting / Notion / Eigene / Sonstiges)
- Owner (select: Ich / Editor / Partner / Extern)
- Beteiligte Personen (text)
- Nächste Aktion (text)
- Notizen (textarea)

---

## PRIORITY 7 — Prompts — CRUD + Copy

### Card View (DEFAULT) + Table toggle
- Favorites pinned at top (star icon toggle)
- Each card: Titel, Kategorie badge, Tags, big **Copy** button
- **Copy-to-clipboard:** Click the Copy button → copies `prompt_text` to clipboard → toast: "Prompt kopiert!"
- Search bar: filter by title, tags, category
- Markdown preview: render prompt_text as markdown in the card (use a simple markdown renderer or just `<pre>` for now)

### Create/Edit Modal Fields
- Titel (required)
- Kategorie (select: Business / Outreach / Content / Coding / Research / Analysis / Sonstiges)
- Prompt Text (textarea, large — this is the main content)
- Tags (multi-input, free text, comma-separated → stored as text[])
- Favorit (toggle)
- Notizen (textarea)

---

## PRIORITY 8 — Remaining Sections (Simpler CRUD)

### Services
- Table view with all fields from schema
- Create/Edit modal with: Name, Kategorie, Beschreibung, Preis Von (CHF), Aufwand (h), Vor-Ort (min), Nachbearbeitung (h), Lieferumfang, Status
- Filter by Status (Aktiv / Entwurf / Archiviert)

### Content (Social Media Planner)
- **Calendar view** (monthly grid showing posts by date) — use a simple grid, not a full calendar library
- **Kanban view** by status: Idee → In Produktion → Fertig → Geplant → Veröffentlicht
- Create/Edit: Titel, Plattform (multi-checkbox), Format, Status, Geplantes Datum, Hook, Script, Hashtags, Tags

### Partner
- Simple table + Create/Edit modal
- Fields: Name, Typ, Kontaktperson, Email, Telefon, Services, Status, Revenue Share %, Website, Notizen

### Roadmap
- **Grouped by Phase** — show Phase 1, Phase 2, Phase 3 as sections
- Each goal: Ziel, Status badge, Kategorie badge, Erfolgsmetrik
- Create/Edit: all fields from schema
- Status Kanban alternative: Geplant → In Progress → Erreicht → Verschoben

---

## GLOBAL REQUIREMENTS

1. **Every create/update/delete MUST log to activity_log** using the helper
2. **Toast notifications** for all actions (success green, error red)
3. **Confirmation dialog** for all deletes
4. **All dates in Swiss format** (DD.MM.YYYY) — use `toLocaleDateString("de-CH")`
5. **Currency as CHF X.XX** — consistent formatting everywhere
6. **Status badges** always use the same color scheme:
   - Green: Aktiv, Bezahlt, Erreicht, Gewonnen, Abgeschlossen, Fertig, Veröffentlicht
   - Blue: In Arbeit, In Progress, In Produktion
   - Amber: Anfrage, Wartet, Potenziell, Review, Geplant, Entwurf
   - Red: Überfällig, Verloren, Archiviert
   - Gray: Inaktiv, Sonstiges

---

## REPORT REQUIRED

After completing (or partially completing) this task:
1. Create `_CLAUDE/REPORTS/REPORT-002.md`
2. List every page you updated and what CRUD was added
3. Note any fields you skipped or changed
4. Note any bugs or issues found
5. Commit with message: `feat(TASK-002): add full CRUD, Kanban, charts`
