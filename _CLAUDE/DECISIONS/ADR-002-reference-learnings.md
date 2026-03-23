# ADR-002 — Reference: Learnings from Previous Kernel Projects

**Date:** 2026-03-23
**Source:** Z:\Kernel_Flow_GmbH\AI\All_Kernel_Tests (12 analyzed projects)
**Decision by:** Claude (Orchestrator)

---

## What We Learned from Past Kernel Apps (DON'T REPEAT THESE MISTAKES)

Based on analysis of 12 previous Kernel projects (ai-kernal-forge, floris-kernel-buddy, kernel-buddy-lab, KernelJr, lovable-kernel-genesis, Kernel_15, Kernel_Delta, Kernel_Exon, etc.):

### Common Failure Patterns
1. **Auth too early** — Adding complex auth before the app had real value. We skip auth for MVP.
2. **Over-engineering the AI layer** — Building orchestration before having a working UI. We build UI first.
3. **No persistent data** — Multiple projects used localStorage or in-memory, data lost on refresh. We use Supabase from day 1.
4. **Too many features at once** — Projects tried to build everything simultaneously. We build one section per task.
5. **No CLAUDE.md consistency** — Each project had different standards. We have one standard from the start.
6. **Abandoned mid-build** — Projects got complex and were dropped. We keep tasks small and completeable.

### What Worked Well (From Best Projects)
- **Shadcn/ui + Tailwind** (from lovable-kernel-genesis) — fastest for dark theme, accessible
- **React Query** (from lovable-kernel-genesis) — for async data fetching with Supabase
- **Lucide React** icons — consistent set
- **Sonner** for toasts — clean, dark mode native
- **Supabase migrations** folder — track schema changes as SQL files

### Code Patterns to Reuse
From `lovable-kernel-genesis` (most polished Lovable build):
- Uses `@tanstack/react-query` with `QueryClientProvider`
- Layout via `AppLayout` component wrapping all routes
- Sonner + shadcn Toaster both imported
- React Router v6 with `BrowserRouter > Routes > Route`

### D:\Tools Integration Notes
The following local tools exist and may be integrated later (Phase 2+):
- `D:\Tools\Voice_to_Text` — Python GUI for voice transcription (PyQt6 based)
- `D:\Tools\Video_to_Transcript` — Video transcription pipeline
- `D:\Tools\Workspace_Launcher` — PyQt6 app launcher
- `D:\Tools\MediaKompressor` — Media compression tool
These are local tools, not web apps. Future: could surface their outputs in Kernel Flow OS via file watchers or APIs.

### Supabase Pattern (from lovable-kernel-genesis)
They use `/supabase/migrations/` folder to track schema as SQL files.
We should do the same — keeps schema in version control.

---

## Decisions Made Based on This

1. **Add React Query** — not just raw Supabase calls. Caching + loading states are essential.
2. **Add migrations folder** — `supabase/migrations/001_initial_schema.sql`
3. **Keep tasks small** — max 1-2 sections per Lovable task to avoid abandonment
4. **No monorepo** — previous Kernel projects over-engineered with NestJS/K8s. This is a simple web app. Keep it simple.
5. **AI Workflow Standard** — follow the standard from `All_Kernel_Tests/CLAUDE.md` (v2.0): verify context, execute incrementally, communicate clearly, log decisions.
