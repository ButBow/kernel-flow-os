# NEXT TASK FOR LOVABLE — TASK-004

**Orchestrated by:** Claude (AI Orchestrator)
**Task:** TASK-004 — Drag-and-Drop Kanban, Inline Editing, Multiple Views
**Date:** 2026-03-24

> After finishing, write `_CLAUDE/REPORTS/REPORT-004.md` and commit it.

---

## PART 1 — Drag-and-Drop Kanban

Install `@dnd-kit/core` and `@dnd-kit/sortable`.

### Aufträge Kanban
- Drag cards between columns (Anfrage → In Arbeit → Review → Abgeliefert → Abgeschlossen)
- On drop: update project status in Supabase, call `syncToNotion("projects")`, log activity, show toast
- Visual: dragging card gets lift shadow + slight opacity, drop target column gets primary border glow
- Keep status dropdown on cards as fallback

### Pipeline Kanban
- Drag between columns (Neu → Kontaktiert → Discovery Call → Angebot Gesendet → Gewonnen → Verloren)
- On drop to "Gewonnen": toast suggesting to create an Auftrag

### Content Kanban
- Drag between status columns (Idee → In Produktion → Fertig → Geplant → Veröffentlicht)

### Open Loops
- Add Kanban view toggle (beside existing list): 3 columns (Offen | Wartet | Erledigt), draggable
- Keep list as default, Kanban as toggle

All drag-and-drop must call `syncToNotion(table)` after status change.

---

## PART 2 — Inline Editing (Notion-like)

Make table cells directly editable without opening a modal:

- **Text cells:** Click → becomes input, Enter or blur to save
- **Status cells:** Click → inline select dropdown appears in-place
- **Date cells:** Click → inline date picker
- **Number cells:** Click → inline number input
- Auto-save on blur, show subtle green flash on cell for 500ms on success
- After save: call `syncToNotion(table)` in background
- Keep the full edit modal accessible via "..." menu or expand icon on each row

Apply to these table views: Kunden, Services, Partner, Prompts (table view), Finanzen invoices table.

---

## PART 3 — Multiple Views per Section

Add a `ViewSwitcher` component — small segmented button group in each page header:

```tsx
// src/components/shared/ViewSwitcher.tsx
interface ViewSwitcherProps {
  views: { id: string; label: string; icon: LucideIcon }[]
  active: string
  onChange: (view: string) => void
}
```

Icons: LayoutGrid (table), Columns3 (kanban), Calendar (calendar), GanttChart (timeline), Grid3x3 (cards)

Remember selected view per section in localStorage (`view-preference-{section}`).

### Views per section:

**Kunden:** Table (default) | Card Grid
- Card Grid: cards with name large, status badge, branche tag, kontaktperson, email — 3 columns

**Aufträge:** Kanban (default) | Table | Timeline
- Timeline: horizontal bars from startdatum → deadline, grouped by month, color by status

**Pipeline:** Kanban (default) | Table

**Content:** Kanban (default) | Calendar | Table
- Calendar: monthly grid (Mon-Sun), nav arrows for prev/next month, day cells show colored pills for items on that date, click day → popover with items, click item → edit modal, click empty day → create with that date prefilled

**Open Loops:** List (default) | Kanban

**Prompts:** Cards (default) | Table

**Roadmap:** Phase Groups (default) | Kanban | Timeline
- Kanban: Geplant → In Progress → Erreicht → Verschoben
- Timeline: horizontal bars by zieldatum, grouped by phase

**Finanzen:** Dashboard+Table (keep current)
**Services:** Table (default) | Card Grid
**Partner:** Table (default) | Card Grid

---

## PART 4 — Rich Text Fields (Notion-feel)

For long text fields (Beschreibung, Script, Notizen, Prompt Text):
- Display mode: render basic markdown (bold, italic, bullets, headings) — use a simple regex renderer or `react-markdown` if already available
- Click → edit mode: textarea with markdown support
- Small formatting hint bar: **B** *I* • list (just visual hints, not buttons)
- Toggle between edit/preview with a small eye icon

---

## GLOBAL RULES
- All mutations: log activity + syncToNotion
- Toast on every action
- Dark mode throughout
- Responsive: Kanban scrolls horizontally on mobile, tables scroll horizontally, calendar stacks

Commit: `feat(TASK-004): drag-and-drop Kanban, inline editing, multiple views, rich text`
Write `_CLAUDE/REPORTS/REPORT-004.md` when done.
