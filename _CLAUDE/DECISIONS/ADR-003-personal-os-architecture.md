# ADR-003 — Personal OS Architecture (Expanded Vision)

**Date:** 2026-03-23
**Decision by:** Claude (Orchestrator)
**Status:** Active — supersedes initial scope

---

## The Expanded Vision

Kernel Flow OS is NOT just a business dashboard. It is a **Personal OS** for Floris that:

1. **Business Layer** — CRM, Projects, Pipeline, Finance, etc. (as originally planned)
2. **Tools Hub** — Launches and embeds all local Python tools as modules
3. **Claude Code Hub** — Shows all sessions, projects, launches Claude Code for any directory
4. **Workspace Manager** — Save/restore workspace states (which tools are open, what project is active)
5. **Auto-Sync** — git pull on startup so Lovable's changes are always current
6. **Future-proof Module System** — New tools auto-discovered and added as cards

---

## The Problem

Local Python tools (MediaKompressor, Voice_to_Text, etc.) can't be directly embedded in a web app. Web apps can't run shell commands.

**Solution: A local launcher service** — a tiny Python FastAPI server that acts as a bridge between the Lovable web app and local tools.

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│           KERNEL FLOW OS (Lovable Web App)               │
│                  Runs in browser                         │
│                                                          │
│  [Business OS] [Tools Hub] [Claude Hub] [Workspaces]     │
└─────────────────────┬────────────────────────────────────┘
                      │ HTTP calls to localhost
          ┌───────────▼───────────────────────┐
          │   KERNEL LAUNCHER SERVICE          │
          │   Python FastAPI @ :8421           │
          │                                   │
          │  /launch/[tool]  → runs .bat       │
          │  /status         → which tools run │
          │  /claude-code    → opens CC in dir │
          │  /workspaces     → save/load state │
          │  /files/browse   → dir browser     │
          └──┬────────────────────────────────┘
             │ launches
    ┌────────▼──────────────────────────────────────────┐
    │              LOCAL TOOLS                          │
    │                                                   │
    │  MediaKompressor    :none (PyGUI)                 │
    │  Voice_to_Text      :none (PyGUI)                 │
    │  Video_to_Transcript :none (PyGUI)                │
    │  Workspace_Launcher  :none (PyQt6 tray)           │
    │  ClaudeCodeManager   :8420 (web UI) ← embeddable  │
    │  LinkHoarder         :8777 (web UI) ← embeddable  │
    └───────────────────────────────────────────────────┘
```

---

## Auto-Sync Flow

```
[Startup.bat]
    → git pull (get Lovable's latest)
    → start KernelLauncher (python launcher_service.py)
    → open browser to localhost:3000 (or prod URL)
```

```
[Lovable pushes to GitHub]
    → Next time Floris runs Startup.bat, gets latest
```

```
[Claude updates NEXT_TASK.md + commits + pushes]
    → Floris pastes NEXT_TASK.md into Lovable
    → Lovable implements + commits + pushes
    → Floris runs Startup.bat → git pull → updated
```

---

## Tool Inventory (Current)

| Tool | Type | Launch | Web UI? | Port |
|------|------|--------|---------|------|
| MediaKompressor | Image/video compression | start.bat → python | No | — |
| Workspace_Launcher | Workspace hub (PyQt6 tray) | start_hub.bat | No | — |
| Voice_to_Text | Audio transcription (Whisper) | START_APP.bat | No | — |
| Video_to_Transcript | Video → transcript | start_gui.bat | No | — |
| ClaudeCodeManager | Claude Code session manager | start.bat → FastAPI | YES | 8420 |
| LinkHoarder | Social media content library | start.bat → FastAPI | YES | 8777 |

---

## Module System Design

Each tool is a "Module Card" in the Tools Hub:

```tsx
interface Module {
  id: string
  name: string
  description: string
  category: 'media' | 'ai' | 'dev' | 'productivity'
  launchType: 'local-gui' | 'local-web' | 'embedded'
  launchEndpoint: string // e.g. /launch/mediacompressor
  webUrl?: string // e.g. http://localhost:8420 (for embedded)
  status: 'running' | 'stopped' | 'unknown'
  icon: string
  path: string // D:\Tools\MediaKompressor
}
```

Modules are defined in a config file (`_CLAUDE/modules.json`) so new tools can be added just by editing the JSON — no code changes needed.

---

## Claude Code Hub

The ClaudeCodeManager already reads `~/.claude/` and knows about all sessions and projects. We embed or link to it.

Additionally, Kernel Flow OS shows:
- Quick Launch: Directory browser → "Open Claude Code here" button
  - Calls `launcher_service` → `code .` in that directory + launches claude
- Session History: From ClaudeCodeManager API
- Active Projects: From `~/.claude/projects/`

"Open Claude Code" call:
```
GET /launch/claude-code?path=D:\Tools\Workspace_Launcher
→ launcher_service runs: start cmd /k "cd [path] && claude"
```

---

## Workspace Manager

A workspace = a named snapshot of:
- Which modules are running
- Which Claude Code project is active
- Which business OS section is open
- Notes for that work session

Saved in Supabase as `workspaces` table. The launcher service manages running process state.

---

## Decisions

1. **Launcher service at :8421** — doesn't conflict with ClaudeCodeManager (:8420) or LinkHoarder (:8777)
2. **modules.json** — module config lives in repo, editable by Claude/Floris
3. **Startup.bat** — single entry point: git pull → start launcher → open browser
4. **ClaudeCodeManager embedded** — iFrame panel in Kernel Flow OS, not replaced
5. **LinkHoarder embedded** — same, iFrame panel
6. **Python GUIs** — launch only (can't embed), show status indicator
7. **No auth still** — personal use, local machine only
