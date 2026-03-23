# CLAUDE.md — Kernel Flow OS Project Instructions

**Project:** Kernel Flow OS — Personal Operating System & Business Hub
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

**What:** A Personal Operating System for Floris Kern — combining business management, tool launching, workspace switching, and Claude Code integration into one unified web app. Think: Creative Cloud + Notion + Raycast + tmux in a single custom dashboard. Replaces Notion as single source of truth.

**NOT:** The public website (that's kernelflow.ch — separate Lovable project)

**Two Layers:**
1. **Business OS** — CRM, Projects, Pipeline, Finance, Content, Roadmap (Supabase-backed)
2. **Personal OS** — Tool Hub, Workspace Clusters, Claude Code Hub, System Info (local launcher-backed)

**Tech Stack:**
- React + TypeScript + Tailwind CSS
- Supabase (database for business data)
- React Router v6 (navigation)
- TanStack React Query (async data fetching + caching)
- Recharts (financial charts)
- Sonner (toast notifications)
- Shadcn/ui (component library)
- Lucide React (icons)

**Local Backend (Kernel Launcher Service):**
- Python FastAPI @ http://localhost:8421
- Bridges between the web app and local tools/Claude Code
- Source: `launcher/launcher_service.py`
- Config: `launcher/modules.json`
- Startup: `START.bat` (git pull → start launcher → open browser)

**Design:** Dark mode only. Colors: #0A0A0A bg, #2563EB primary blue, #7C3AED accent purple.

**App Sections:**

Business OS:
1. Dashboard (command center — stats, daily brief, quick actions)
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

Personal OS:
12. Tools Hub (launch/embed all local tools — modules from `launcher/modules.json`)
13. Claude Code Hub (launch CC from any dir, browse projects/sessions)
14. Workspaces (switch between "scenes" — clusters of tools + browser sections)
15. Settings

**Local Tools (registered as modules):**

| Tool | Type | Port | Embeddable |
|------|------|------|-----------|
| Claude Code Manager | FastAPI + PySide6 | 8420 | Yes (iFrame) |
| Link Hoarder | FastAPI + web UI | 8777 | Yes (iFrame) |
| Media Kompressor | Python GUI (CustomTkinter) | — | No (launch only) |
| Voice to Text | Python GUI (Tkinter/Whisper) | — | No (launch only) |
| Video to Transcript | Python GUI (Whisper) | — | No (launch only) |
| Workspace Launcher | Python GUI (PyQt6 tray) | — | No (launch only) |

**Full spec:** See `_Lovable_Prompt/KERNEL_FLOW_OS_PROMPT.md`
**Architecture:** See `_CLAUDE/DECISIONS/ADR-003-personal-os-architecture.md`

---

## ARCHITECTURAL DECISIONS (Running Log)

See `_CLAUDE/DECISIONS/` for detailed decision logs.

**ADR-001:** Supabase for all persistence (not localStorage) — data must survive browser refresh
**ADR-002:** Modal forms for create/edit — no separate routes for forms
**ADR-003:** Shadcn/ui as component base — consistent, accessible, customizable
**ADR-004:** Sonner for toasts — lightweight, matches dark theme well
**ADR-005:** No auth required (MVP) — this runs locally for one user (Floris)
**ADR-006:** Kernel Launcher Service at :8421 — bridges web app to local tools via HTTP API
**ADR-007:** modules.json defines all tools + workspaces — add new tools by editing JSON, no code changes
**ADR-008:** Web-based tools (ClaudeCodeManager :8420, LinkHoarder :8777) embedded via iFrame panels
**ADR-009:** Python GUI tools launched via subprocess — status shown as "Running/Stopped/Unknown"
**ADR-010:** START.bat does git pull on startup — ensures latest Lovable code is always current

## LAUNCHER SERVICE API

The Kernel Flow OS web app talks to `http://localhost:8421` for all local operations.

**Key endpoints the web app uses:**
- `GET /modules` — returns full modules.json (tool list, workspaces, Claude paths)
- `GET /modules/status` — returns running/stopped status for all tools
- `POST /launch/{tool_id}` — launches a local tool (e.g., `/launch/media-kompressor`)
- `POST /workspace/activate` — activates a workspace (launches all its tools)
- `POST /claude-code/launch` — opens Claude Code in a directory (body: `{path, model?}`)
- `GET /claude-code/projects` — lists all Claude Code projects from `~/.claude/projects/`
- `GET /claude-code/quick-paths` — returns bookmarked directories for quick CC launch
- `GET /files/browse?path=...` — directory browser for the Claude Code launcher
- `POST /git/pull` — pulls latest changes from GitHub
- `GET /system/info` — CPU/RAM stats for the dashboard

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
