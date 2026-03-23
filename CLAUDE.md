# CLAUDE.md — Kernel Flow OS Project Instructions

**Project:** Kernel Flow OS (Internal Business Dashboard)
**Company:** Kernel Flow GmbH | Owner: Floris Kern
**Orchestrator:** Claude (Anthropic) — reads this repo, writes tasks, reviews code
**Developer:** Lovable AI — implements tasks, writes reports, commits code
**Human in the loop:** Floris — approves, pastes tasks, triggers Lovable runs

---

## ROLES & RESPONSIBILITIES

### Claude (Orchestrator)
- Reads all code, reports, and decisions in this repo
- Writes numbered TASK files in `_CLAUDE/TASKS/`
- Reviews Lovable's implementation after each round
- Writes review notes in `_CLAUDE/REVIEWS/`
- Maintains architectural decisions in `_CLAUDE/DECISIONS/`
- Never writes app source code directly — delegates to Lovable
- Updates `NEXT_TASK.md` (Floris pastes this into Lovable)

### Lovable AI (Developer)
- Reads `NEXT_TASK.md` at the start of every session
- Implements exactly what the current task specifies
- After implementing, ALWAYS writes a report (see Report Format below)
- Commits the report to `_CLAUDE/REPORTS/REPORT-XXX.md`
- Commits all code changes with clear commit messages
- Does NOT invent features beyond the task scope
- Asks for clarification via the report if something is unclear

### Floris (Human Operator)
- Pastes `NEXT_TASK.md` content into Lovable to trigger a run
- Tells Claude when Lovable has finished ("done, check it")
- Makes final approval decisions on architecture/design

---

## ASYNC WORKFLOW

```
[Claude] writes NEXT_TASK.md
    ↓
[Floris] pastes NEXT_TASK.md into Lovable
    ↓
[Lovable] implements + writes REPORT to _CLAUDE/REPORTS/
    ↓
[Lovable] commits & pushes to GitHub
    ↓
[Floris] tells Claude "done"
    ↓
[Claude] reads REPORT + reviews code changes
    ↓
[Claude] writes next NEXT_TASK.md
    ↓
repeat
```

---

## LOVABLE REPORT FORMAT

After every implementation session, Lovable MUST create a report file:

**File:** `_CLAUDE/REPORTS/REPORT-XXX.md` (increment number each time)

**Template:**
```markdown
# REPORT-XXX — [Task Title]

**Date:** YYYY-MM-DD
**Task:** TASK-XXX
**Status:** COMPLETE / PARTIAL / BLOCKED

## What I Built
[Bullet list of exactly what was implemented]

## Files Changed
[List of files created/modified]

## Decisions I Made
[Any architectural or design choices I made independently, and WHY]

## Deviations from Task
[Anything I did differently than specified, and why]

## What Still Needs Work
[Anything from the task I couldn't complete or skipped]

## Questions for Claude
[Any blockers, unclear specs, or things needing a decision]

## How to Test
[What Floris should click/check to verify the implementation]
```

---

## PROJECT OVERVIEW

**What:** Private internal dashboard for Kernel Flow GmbH. Replaces Notion.
**NOT:** The public website (that's kernelflow.ch — separate Lovable project)

**Tech Stack:**
- React + TypeScript + Tailwind CSS
- Supabase (database + auth)
- React Router v6 (navigation)
- TanStack React Query (async data fetching + caching)
- Recharts (financial charts)
- Sonner (toast notifications)
- Shadcn/ui (component library)
- Lucide React (icons)

**Design:** Dark mode only. Colors: #0A0A0A bg, #2563EB primary blue, #7C3AED accent purple.

**App Sections:**
1. Dashboard (command center)
2. Kunden (CRM)
3. Aufträge (Projects + Kanban)
4. Pipeline (Leads)
5. Services (Catalog)
6. Content (Social Media Planner)
7. Finanzen (Revenue + Invoices)
8. Open Loops (commitment tracker)
9. Prompts (AI Library)
10. Partner
11. Roadmap
12. Settings

**Full spec:** See `_Lovable_Prompt/KERNEL_FLOW_OS_PROMPT.md`

---

## ARCHITECTURAL DECISIONS (Running Log)

See `_CLAUDE/DECISIONS/` for detailed decision logs.

**ADR-001:** Supabase for all persistence (not localStorage) — data must survive browser refresh
**ADR-002:** Modal forms for create/edit — no separate routes for forms
**ADR-003:** Shadcn/ui as component base — consistent, accessible, customizable
**ADR-004:** Sonner for toasts — lightweight, matches dark theme well
**ADR-005:** No auth required (MVP) — this runs locally for one user (Floris)

---

## CODE STANDARDS

- TypeScript strict mode — no `any` types
- Components in `src/components/[section]/`
- Pages in `src/pages/`
- Supabase types in `src/types/database.ts`
- Custom hooks in `src/hooks/`
- All Supabase calls go through service files in `src/services/`
- German for data labels, English for code identifiers

---

## PROTECTED DATA

The following are in `.gitignore` and must NEVER be committed:
- `Kernel_Home_Export_Notion/` — real Notion export with client data
- `_Data_Exports/` — CSV/JSON with financials and contacts
- `.env` — Supabase keys

Lovable: Store Supabase URL and anon key via Lovable's built-in Supabase integration, NOT in a committed .env file.

---

## CURRENT STATUS

See `NEXT_TASK.md` for the active task.
See `_CLAUDE/REPORTS/` for history of what was built.
See `_CLAUDE/REVIEWS/` for Claude's code review notes.
