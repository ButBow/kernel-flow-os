# ADR-004 — Self-Hosted LAN Deployment

**Date:** 2026-03-23
**Decision by:** Floris + Claude
**Status:** Active — target for final deployment

---

## Goal

Run Kernel Flow OS on an always-on PC in the local network. Access it from any device (laptop, phone, tablet) on the same LAN. No cloud hosting, no internet dependency for the core app.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│            ALWAYS-ON PC (Server)                        │
│                                                         │
│  ┌─────────────────────────────────┐                    │
│  │  Nginx or Caddy                 │  ← :80 / :443     │
│  │  Serves built React app (dist/) │     LAN accessible │
│  └─────────────────────────────────┘                    │
│                                                         │
│  ┌─────────────────────────────────┐                    │
│  │  Supabase (Docker self-hosted)  │  ← :54321          │
│  │  PostgreSQL + PostgREST + Auth  │     LAN accessible │
│  │  + Edge Functions runtime       │                    │
│  └─────────────────────────────────┘                    │
│                                                         │
│  ┌─────────────────────────────────┐                    │
│  │  Kernel Launcher Service        │  ← :8421           │
│  │  (Python FastAPI)               │     LOCAL ONLY     │
│  └─────────────────────────────────┘                    │
│                                                         │
│  Local Tools: ClaudeCodeManager :8420                   │
│               LinkHoarder :8777                         │
│               MediaKompressor, Voice_to_Text (GUIs)     │
└─────────────────────────────────────────────────────────┘
         │  LAN (192.168.x.x)
         │
┌────────▼──────────┐  ┌──────────────────┐
│  Floris Laptop    │  │  Phone / Tablet   │
│  Browser → :80    │  │  Browser → :80    │
│  + Launcher :8421 │  │  (no launcher)    │
│  (if same PC)     │  │                   │
└───────────────────┘  └──────────────────┘
```

---

## Two Tiers of Access

### Tier 1 — Full Access (from the server PC itself)
- Web app + all business features
- Launcher Service → launch local tools, Claude Code, workspaces
- iFrame embeds of ClaudeCodeManager + LinkHoarder
- Everything works

### Tier 2 — Remote LAN Access (from other devices)
- Web app + all business features (Supabase queries work)
- Launcher Service: NOT accessible (localhost only for security)
- Tools Hub: shows "Launcher only available on server PC"
- Claude Code Hub: shows "Only available on server PC"
- Workspaces: shows "Only available on server PC"
- Business sections (CRM, Projects, Finance, etc.): FULLY FUNCTIONAL

---

## Deployment Stack

### Option A: Simple (Recommended for Start)
- **Frontend:** `npm run build` → `dist/` → served by simple Node server or Python `http.server`
- **Supabase:** Keep cloud-hosted (Lovable's Supabase, free tier)
- **Launcher:** Python FastAPI on localhost
- **Pros:** Simplest, works now, free
- **Cons:** Supabase needs internet

### Option B: Fully Self-Hosted (Target)
- **Frontend:** `npm run build` → nginx serving `dist/`
- **Supabase:** Docker self-hosted (`supabase/supabase` Docker image)
- **Launcher:** Python FastAPI on localhost
- **Notion Sync:** Edge function runs as a local cron job or Node script instead
- **Pros:** Zero internet dependency, full control, true offline
- **Cons:** Docker setup, more maintenance

### Option C: Hybrid (Best Balance)
- **Frontend:** nginx on always-on PC
- **Supabase:** Cloud (free tier) — still needs internet but minimal
- **Launcher:** localhost only
- **Notion Sync:** Cloud edge function (works with cloud Supabase)
- **Pros:** Simple setup, Notion sync just works, LAN access for UI
- **Cons:** Internet needed for DB

---

## Recommended Path

1. **Now:** Keep Supabase cloud while building. Focus on features.
2. **When app is feature-complete:** Build frontend (`npm run build`), serve on always-on PC
3. **Later if wanted:** Migrate to self-hosted Supabase Docker

---

## Setup Steps (for Option C — do this when ready)

### On the always-on PC:

```bash
# 1. Clone the repo
git clone https://github.com/ButBow/kernel-flow-os-9413c665.git
cd kernel-flow-os-9413c665

# 2. Install dependencies
npm install

# 3. Build for production
npm run build
# → creates dist/ folder with static files

# 4. Serve with a simple server (pick one):

# Option: Python (simplest)
cd dist && python -m http.server 80

# Option: Node (slightly better)
npx serve dist -l 80

# Option: Nginx (production-grade)
# Copy dist/ to /var/www/kernel-flow-os/
# Configure nginx to serve it on port 80

# 5. Start Launcher Service (only useful on this PC)
cd launcher && python launcher_service.py &

# 6. Auto-start on boot (Windows Task Scheduler or startup folder)
```

### Access from other devices:
- Find server IP: `ipconfig` → e.g., `192.168.1.100`
- Open browser on any LAN device: `http://192.168.1.100`
- Bookmark it

### Windows auto-start:
Create a scheduled task or put in Startup folder:
```bat
@echo off
cd /d C:\path\to\kernel-flow-os-9413c665
start /min npx serve dist -l 80
start /min python launcher\launcher_service.py
```

---

## Network Security

- Only accessible on LAN (no port forwarding to internet)
- No auth needed (trusted home/office network)
- If exposing to internet later: add Supabase Auth + HTTPS via Cloudflare Tunnel or Tailscale
- Launcher Service MUST stay localhost-only (:8421 bound to 127.0.0.1)

---

## What Changes in the App Code

The web app needs to detect if the launcher is available and gracefully hide system features when accessed remotely:

```ts
// Already handled! ToolsHub, ClaudeCodeHub, Workspaces all check
// launcher health and show "Launcher Offline" banner when unreachable.
// No code changes needed — it degrades gracefully.
```
