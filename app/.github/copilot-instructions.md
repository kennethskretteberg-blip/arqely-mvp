# Copilot Instructions — ARQELY (LOCKED)

These instructions are binding for all code in this repository.

Arqely is an AI-native engineering infrastructure platform.
This repository currently implements MVP Phase 1:
Heat Cable Documentation (mobile-first, cloud-based, realtime).

Copilot must strictly follow these rules.

---

# 1. TECH STACK (LOCKED)

- Next.js (App Router)
- TypeScript strict (no `any`, no implicit any)
- Tailwind CSS
- Supabase:
  - Postgres (database)
  - Auth
  - Storage (high-quality images)
  - Realtime
- Vercel deployment

Do not introduce additional frameworks or libraries unless explicitly approved.

---

# 2. CURRENT MVP SCOPE (DO NOT EXPAND)

We are building:

Project → Room → Heat Cable Documentation

Inside each room:
- Identification data (cable, length, power, thermostat)
- Three required measurements:
  - before_install
  - after_install
  - before_power
- Installation checklist (checkbox confirmations)
- Image upload (high resolution, no destructive compression)
- Real-time updates
- Caseworker approval workflow
- Event log (audit trail)

DO NOT IMPLEMENT:
- Full heat prosjektering
- Light module
- Electrical module
- Rule engine
- AI geometry detection
- DWG import
- Overengineering or premature abstractions

Keep scope tight.

---

# 3. ARCHITECTURE PRINCIPLES

## 3.1 Component Rules

- Server Components by default
- Client Components only when needed:
  - Forms
  - Realtime subscriptions
  - Interactive UI

## 3.2 Folder Structure

Use clear separation:

- app/
- components/
- lib/
- types/

Do not mix responsibilities.

## 3.3 Simplicity Rule

- No premature optimization
- No speculative abstractions
- No unnecessary patterns
- Build only what MVP requires

---

# 4. DATA MODEL PRINCIPLES

All mutable entities must:

- Have a stable unique `entityId` (UUID/ULID)
- Have a human-readable code if relevant (e.g. S-001)
- Be traceable in audit log

Required tables in MVP:

- profiles (role: installer | caseworker | admin)
- projects
- rooms
- heat_cable_docs
- heat_cable_measurements
- doc_images
- doc_events

All changes to documentation must create a doc_event entry.

Never remove audit traceability.

---

# 5. REALTIME RULES

- Realtime must use Supabase subscriptions
- UI must update immediately when another user modifies documentation
- No polling
- No fake local-only state

---

# 6. STORAGE RULES

- Images must be stored in Supabase Storage
- Use signed upload URLs
- Never expose service role key in client
- Do not compress destructively
- Images must be zoomable in office review

---

# 7. MOBILE-FIRST REQUIREMENTS

Montør works from mobile.

UI must:
- Use large touch-friendly inputs
- Avoid dense layouts
- Use clear sectioning
- Minimize scrolling friction
- Avoid complex modal flows

Desktop can be optimized later.

---

# 8. STATUS WORKFLOW

Documentation status must support:

- in_progress
- ready_for_review
- approved
- rejected

Caseworker can approve/reject.
Installer can mark ready_for_review.

Status transitions must be logged in doc_events.

---

# 9. COMMIT DISCIPLINE

- Small changes
- One concern per commit
- Do not refactor unrelated files
- Do not rename structure without reason
- Do not auto-generate massive multi-file changes

When changes affect multiple files:
- First generate a plan
- Wait for confirmation
- Then implement

---

# 10. CLARIFICATION-FIRST RULE (CRITICAL)

If ANY requirement is unclear:

- STOP
- Ask clarifying questions
- Propose 2–3 options if relevant
- Do NOT assume business logic

If database design is incomplete:
- Ask before creating fields

If UI behavior is ambiguous:
- Ask before implementing

If role logic is unclear:
- Ask before implementing

Always generate a short implementation plan before writing multi-file changes.

Never assume.

---

# 11. TYPE SAFETY

- No `any`
- No implicit any
- Strict typing for Supabase responses
- Guard null/undefined
- Proper union types for status and roles

---

# 12. NO OVERENGINEERING

Do not:
- Introduce global state managers
- Add unnecessary hooks
- Add dependency-heavy solutions
- Build abstractions not yet needed
- Create future-proof systems beyond MVP

Keep it clean, controlled, production-ready.

---

# 13. DESIGN PRINCIPLES (LOCKED)

- Calm, professional tool
- Light background
- Card-based layout
- Green = OK/approved
- Yellow/orange = warning
- Red = error/deviation
- No gamification
- No marketing language

---

# 14. ALWAYS

Before implementing large changes:

1. Generate a short plan.
2. List affected files.
3. Ask for confirmation.
4. Then implement.

Follow these rules strictly.
