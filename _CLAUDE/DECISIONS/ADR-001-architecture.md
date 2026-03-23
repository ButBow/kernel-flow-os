# ADR-001 — Core Architecture Decisions

**Date:** 2026-03-23
**Decision by:** Claude (Orchestrator)
**Status:** Active

---

## Stack

| Layer | Choice | Reason |
|-------|--------|--------|
| Framework | React + TypeScript | Lovable's native stack, strong typing |
| Styling | Tailwind CSS + Shadcn/ui | Fast, consistent, dark-mode ready |
| Database | Supabase | Free tier, real-time, Lovable native integration |
| Charts | Recharts | Lightweight, composable, React-native |
| Toasts | Sonner | Dark theme looks great, minimal setup |
| Routing | React Router v6 | Standard, Lovable uses this |
| Icons | Lucide React | Shadcn default, consistent set |

## Auth

**Decision: No auth for MVP.**
This app runs locally/privately for one user (Floris). Auth adds complexity with no benefit at this stage. If the app is ever deployed publicly or shared, revisit.

## Data Architecture

**Decision: Supabase with proper FK relations from day 1.**
Do not use localStorage or in-memory state. All data must persist in Supabase. This enables:
- Data survives browser restart
- Future multi-device access
- Potential future automation/API access

## Component Structure

```
src/
├── components/
│   ├── layout/          (Sidebar, Header, Layout wrapper)
│   ├── dashboard/       (Dashboard widgets)
│   ├── kunden/          (CRM components)
│   ├── auftraege/       (Project components)
│   ├── pipeline/        (Lead components)
│   ├── services/        (Service catalog)
│   ├── content/         (Social media planner)
│   ├── finanzen/        (Finance components)
│   ├── loops/           (Open loops)
│   ├── prompts/         (AI prompt library)
│   ├── partner/         (Partner management)
│   ├── roadmap/         (Roadmap/goals)
│   └── ui/              (Shadcn components)
├── pages/               (One per section)
├── hooks/               (useClients, useProjects, etc.)
├── services/            (supabase.ts, clients.ts, projects.ts…)
├── types/               (database.ts, app.ts)
└── lib/                 (utils, constants)
```

## Supabase Row Level Security

For MVP: Disable RLS on all tables (single-user, no auth). Add later if needed.
