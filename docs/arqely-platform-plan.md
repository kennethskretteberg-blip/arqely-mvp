# Arqely Platform — Architecture & Development Plan

**Version:** 1.0
**Date:** 2026-03-13
**Status:** Draft

---

## Overview

Arqely is an AI-native engineering platform for electrical contractors and suppliers.
This document defines the architecture and phased development plan.

The platform evolves in three stages:
- **Stage A (Phase 1-3):** Traditional SaaS — auth, projects, CRM, offers
- **Stage B (Phase 4-5):** AI-assisted — sales agent, design automation
- **Stage C (Phase 6-7):** Platform — multi-tenant, multi-agent, network effects

---

## Table of Contents

1. [Platform Architecture](#1-platform-architecture)
2. [Multi-Tenant Strategy](#2-multi-tenant-strategy)
3. [Data Model](#3-data-model)
4. [AI Architecture](#4-ai-architecture)
5. [Modular AI Agent Framework](#5-modular-ai-agent-framework)
6. [API Architecture](#6-api-architecture)
7. [Next.js Project Structure](#7-nextjs-project-structure)
8. [Development Phases](#8-development-phases)
9. [Risks and Design Principles](#9-risks-and-design-principles)

---

## 1. Platform Architecture

### High-Level System Design

```
+---------------------------------------------------------+
|                     FRONTEND                             |
|               Next.js (App Router)                       |
|      Dashboard | Projects | CRM | Products | AI         |
+----------------------------+----------------------------+
                             | HTTPS
+----------------------------v----------------------------+
|                    API LAYER                              |
|             Supabase Edge Functions                       |
|          + Next.js API Routes (BFF)                       |
+----+----------+----------+-----------+------------------+
     |          |          |           |
+----v--+ +----v--+ +-----v-----+ +--v-----------------+
|Supa-  | |Vector | |Determin.  | |  AI Orchestrator   |
|base   | |Store  | |Calc       | |  (Agent Router)    |
|Postgr.| |pgvec  | |Engine     | |                    |
+-------+ +-------+ +-----------+ +--+----------------+
                                      |
                            +---------v-----------+
                            |   LLM Providers     |
                            |  Claude / OpenAI    |
                            +---------------------+
```

### Component Responsibilities

- **Frontend (Next.js):** UI for all user types. Tenant-aware routing. Server components for data, client components for interactive tools (canvas, CRM).
- **API Layer (Supabase + BFF):** Supabase handles auth, RLS, real-time, storage. Next.js API routes for complex operations (offer generation, AI calls).
- **Postgres + pgvector:** Single database, tenant-isolated via Row Level Security. pgvector for product embeddings and document search.
- **Deterministic Calculation Engine:** Pure functions for heating calculations, material quantities, rule validation. Never delegated to LLM.
- **AI Orchestrator:** Routes requests to agents. Manages context, retrieval, and tool calls. Agents never touch the database directly.

### Why single Postgres with RLS (not database-per-tenant)

- Simpler operations at scale (1-50 tenants in year 1)
- Supabase RLS is battle-tested
- Shared product comparison requires cross-tenant queries (opt-in)
- Can migrate to schema-per-tenant later if needed

---

## 2. Multi-Tenant Strategy

### Tenant Model

```
Tenant (company)
  +-- type: 'supplier' | 'contractor'
  +-- Users[]
  +-- Products[] (suppliers own, contractors reference)
  +-- Projects[]
  +-- CRM data[]
  +-- Settings (enabled modules, AI features, branding)
```

### Data Isolation

| Data Type  | Isolation             | Exception                          |
|------------|-----------------------|------------------------------------|
| Products   | Supplier owns         | Contractors see enabled suppliers  |
| Projects   | Fully tenant-isolated | Never shared                       |
| CRM        | Fully tenant-isolated | Never shared                       |
| Users      | Belong to one tenant  | Never shared                       |
| AI context | Tenant-scoped         | Never leaks                        |

### User Roles

| Role         | Description                          |
|--------------|--------------------------------------|
| Super Admin  | Arqely platform team                 |
| Tenant Admin | Company administrator                |
| Manager      | Team lead, sees all projects         |
| Designer     | Creates/edits projects               |
| Sales        | CRM, offers, no engineering          |
| Viewer       | Read-only access                     |

### Product Visibility Logic

- **Supplier user:** Sees own products only (unless competitor_comparison enabled)
- **Contractor user:** Sees products from `enabled_suppliers[]` (initially Cenika only)

### RLS Pattern

```sql
-- Basic tenant isolation
CREATE POLICY tenant_isolation ON products
  USING (tenant_id = auth.jwt()->>'tenant_id');

-- Cross-tenant product access for contractors
CREATE POLICY contractor_product_access ON products
  USING (
    tenant_id = auth.jwt()->>'tenant_id'
    OR id IN (
      SELECT product_id FROM tenant_product_access
      WHERE contractor_tenant_id = auth.jwt()->>'tenant_id'
    )
  );
```

---

## 3. Data Model

### Core Tables

```sql
tenants
  id              uuid PK
  name            text
  type            enum('supplier','contractor')
  settings        jsonb
  created_at      timestamptz

users
  id              uuid PK (supabase auth.users)
  tenant_id       uuid FK -> tenants
  role            enum('admin','manager','designer','sales','viewer')
  name            text
  email           text
  created_at      timestamptz

products
  id              uuid PK
  tenant_id       uuid FK -> tenants (the supplier)
  brand           text
  family          text
  name            text
  article_number  text
  el_number       text
  cva_number      text
  type            enum('cable','mat','foil','outdoor_cable',...)
  application     enum('floor','stair','snow','roof',...)
  power_w_per_m2  numeric
  power_w         numeric
  length_m        numeric
  width_mm        numeric
  resistance_ohm  numeric
  voltage         int
  specs           jsonb
  embedding       vector(1536)
  created_at      timestamptz

product_rules
  id              uuid PK
  product_id      uuid FK -> products
  rule_type       enum('min_gap','min_margin','max_power','min_bend_radius',...)
  value           numeric
  unit            text
  description     text

projects
  id              uuid PK
  tenant_id       uuid FK -> tenants
  name            text
  customer_id     uuid FK -> crm_contacts (nullable)
  status          enum('planned','in_progress','ready_for_quote','completed')
  type            enum('indoor','stair','snow','roof','mixed')
  address         text
  data            jsonb (full project state)
  created_at      timestamptz
  updated_at      timestamptz

rooms
  id              uuid PK
  project_id      uuid FK -> projects
  name            text
  floor           int
  geometry        jsonb
  heating_layout  jsonb
  calculated_power_w  numeric
  area_m2         numeric

crm_contacts
  id              uuid PK
  tenant_id       uuid FK -> tenants
  name            text
  company         text
  email           text
  phone           text
  type            enum('customer','lead','partner')
  tags            text[]
  created_at      timestamptz

crm_activities
  id              uuid PK
  tenant_id       uuid FK -> tenants
  contact_id      uuid FK -> crm_contacts
  project_id      uuid FK -> projects (nullable)
  type            enum('email','call','meeting','note','offer_sent','follow_up')
  subject         text
  body            text
  scheduled_at    timestamptz
  completed_at    timestamptz
  created_by      uuid FK -> users

offers
  id              uuid PK
  tenant_id       uuid FK -> tenants
  project_id      uuid FK -> projects
  contact_id      uuid FK -> crm_contacts
  status          enum('draft','sent','accepted','rejected','expired')
  lines           jsonb
  total_ex_vat    numeric
  valid_until     date
  pdf_url         text
  created_at      timestamptz

tenant_product_access
  contractor_tenant_id  uuid FK -> tenants
  supplier_tenant_id    uuid FK -> tenants
  enabled_at            timestamptz
```

### Relationships

```
tenant --< users
tenant --< products (if supplier)
tenant --< projects
tenant --< crm_contacts

crm_contacts --< crm_activities
crm_contacts --< offers

projects --< rooms
projects --< offers
projects --< crm_activities

products --< product_rules
```

### Design Decision: projects.data as JSONB

The existing Romtegner stores full project state as a rich JSON object. The `data` column stores the complete CAD state. The relational `rooms` table is a denormalized index for search, reporting, and AI retrieval. Source of truth for geometry remains the JSONB blob.

---

## 4. AI Architecture

### Three-Layer Principle

| Layer | Purpose | Example |
|-------|---------|---------|
| **Deterministic** | Calculations, rules | Heating power, cable lengths, material quantities |
| **Retrieval** | Search, matching | pgvector similarity, product matching |
| **Reasoning (LLM)** | Language tasks | Email parsing, offer text, design suggestions |

### When to Use What

| Task | Layer | Why |
|------|-------|-----|
| Calculate installed power | Deterministic | Must be exact |
| Validate installation rules | Deterministic | Safety-critical |
| Generate material list | Deterministic | Must be exact |
| Find matching product | Retrieval + LLM | Similarity + reasoning |
| Parse customer email | LLM | Language understanding |
| Write offer text | LLM | Language generation |
| Suggest heating layout | Deterministic + LLM | Calc for validation, LLM for suggestions |
| CRM follow-up reminders | Retrieval + LLM | Context search + prioritization |

### Vector Database Usage (pgvector)

**What gets embedded:**
- Product descriptions (find similar products)
- Product specifications (match requirements)
- Project notes (search across history)
- CRM activity text (find related interactions)

**Strategy:** Embed on insert/update. Use `text-embedding-3-small` (1536 dim).

### Tool Services (callable by AI agents)

```
ProductSearchService
  searchBySpec(watts, type, application) -> Product[]
  findSimilar(productId) -> Product[]
  compareProducts(id1, id2) -> ComparisonResult

CalculationService
  calculateHeatingPower(room, products) -> PowerResult
  calculateMaterialList(project) -> MaterialLine[]
  validateInstallation(room, layout) -> ValidationResult[]

OfferService
  generateOfferLines(project) -> OfferLine[]
  calculatePricing(lines, margin) -> PricingResult

CRMService
  findContact(query) -> Contact[]
  logActivity(contactId, type, data) -> Activity
  getProjectHistory(contactId) -> ProjectSummary[]
```

---

## 5. Modular AI Agent Framework

### Architecture

```
+----------------------------------+
|         AI Orchestrator           |
|  (routes requests to agents)      |
+----------------------------------+
|  Agent Registry                   |
|  +----------+ +----------+       |
|  | Sales    | | Product  |       |
|  | Agent    | | Match    |       |
|  +----------+ +----------+       |
|  +----------+ +----------+       |
|  | Design   | | Doc Gen  |       |
|  | Agent    | | Agent    |       |
|  +----------+ +----------+       |
+----------------------------------+
|  Shared Services                  |
|  Products | Calc | CRM | Offers  |
+----------------------------------+
```

### Agent Interface

```typescript
interface Agent {
  id: string;
  name: string;
  description: string;
  permissions: Permission[];
  requiredContext: ContextType[];
  run(input: AgentInput): Promise<AgentOutput>;
}
```

### Agent Registration (declarative)

```typescript
const salesAgent = {
  id: 'sales-assistant',
  name: 'Salgsassistent',
  permissions: ['products:read', 'crm:read', 'crm:write', 'offers:draft'],
  requiredContext: ['tenant', 'user'],
  triggers: ['email_received', 'manual', 'crm_activity'],
};
```

### Safety Rules

1. Agents never write directly to DB — they return proposed actions
2. User confirms destructive actions
3. Tenant isolation enforced at service level
4. Calculations never generated by LLM
5. Every agent action is audit-logged

### Adding a New Agent

1. Create agent file with interface implementation
2. Register in agent registry
3. Define permissions
4. Deploy — orchestrator picks it up automatically

No changes to existing agents, database, or frontend needed.

---

## 6. API Architecture

### API Routes

```
/api/auth/*                     Supabase auth (built-in)

/api/products
  GET    /                      List (filtered by tenant access)
  GET    /:id                   Detail
  POST   /                      Create (supplier only)
  PUT    /:id                   Update (supplier only)
  POST   /search                Vector + structured search
  POST   /compare               Compare products

/api/projects
  GET    /                      List tenant projects
  GET    /:id                   Full project with data
  POST   /                      Create
  PUT    /:id                   Update
  POST   /:id/duplicate         Duplicate project
  GET    /:id/materials          Calculated material list
  POST   /:id/export             Generate PDF

/api/crm
  GET    /contacts               List contacts
  POST   /contacts               Create contact
  GET    /contacts/:id           Contact with activities
  POST   /activities             Log activity
  GET    /pipeline               Sales pipeline view

/api/offers
  GET    /                      List offers
  POST   /                      Create from project
  PUT    /:id                   Update
  POST   /:id/send               Send to customer

/api/ai
  POST   /chat                   General AI chat (routed to agent)
  POST   /agents/:agentId/run    Run specific agent
  GET    /agents                  List available agents
```

### Agent-API Interaction

Agents call internal services, not HTTP endpoints:

```
User message -> Orchestrator -> Sales Agent
  -> ProductSearchService.searchBySpec(...)
  -> CalculationService.calculateMaterialList(...)
  -> OfferService.generateOfferLines(...)
  <- { response, actions: [{ type: 'create_offer', data }] }
```

---

## 7. Next.js Project Structure

```
arqely-platform/
  app/
    (auth)/
      login/
      signup/
    (dashboard)/
      layout.tsx              Tenant-aware shell
      page.tsx                Dashboard home
      projects/
        page.tsx              Project list
        [id]/
          page.tsx            Project workspace
          design/             CAD canvas (Romtegner)
          materials/          Material list
          docs/               Documentation
      crm/
        page.tsx              Pipeline view
        contacts/
        activities/
      products/
        page.tsx              Catalogue
        [id]/
      offers/
        page.tsx
        [id]/
      settings/
        team/
        products/             Supplier: manage catalogue
        integrations/
    api/
      products/
      projects/
      crm/
      offers/
      ai/
  lib/
    supabase/
      client.ts
      server.ts
      middleware.ts
    ai/
      orchestrator.ts
      agents/
        sales-assistant.ts
        product-match.ts
        design-agent.ts
      services/
        product-search.ts
        calculation.ts
        rule-validation.ts
        offer-generation.ts
      embeddings.ts
    engine/
      heating-calc.ts         Deterministic calculations
      material-list.ts
      rule-validator.ts
    utils/
  components/
    ui/                       Shared UI components
    canvas/                   CAD/drawing components
    crm/                      CRM-specific components
    ai/                       Chat, agent UI
  types/
    database.ts               Generated from Supabase
    agents.ts
    engineering.ts
  supabase/
    migrations/
    functions/                Edge functions
```

### Romtegner Integration

The existing `romtegner.html` canvas migrates into `app/(dashboard)/projects/[id]/design/`. The canvas logic becomes a React component that loads/saves project state via Supabase. Migration happens in Phase 2.

---

## 8. Development Phases

---

### Phase 1: Core Platform Foundation

**Duration:** 6-8 weeks
**Status:** Not started

**Goals:**
- Working multi-tenant auth
- Basic dashboard
- Project CRUD

**Technical work:**
- [ ] Next.js project setup with Supabase
- [ ] Auth flow with tenant assignment
- [ ] Database schema: tenants, users, projects
- [ ] Dashboard with project list
- [ ] Basic project create/edit/delete
- [ ] RLS policies for tenant isolation

**AI capabilities:** None

**Value delivered:** Working multi-tenant platform skeleton. Cenika can log in.

**Depends on:** Nothing

---

### Phase 2: Supplier Pilot (Cenika)

**Duration:** 6-8 weeks
**Status:** Not started

**Goals:**
- Cenika manages products
- Projects with Romtegner design tool
- Material list generation

**Technical work:**
- [ ] Product catalogue CRUD for suppliers
- [ ] Import Cenika product data
- [ ] Migrate Romtegner canvas into project workspace
- [ ] Product rules engine (from existing code)
- [ ] Material list generation
- [ ] Project status workflow

**AI capabilities:** Product embeddings generated (foundation for later)

**Value delivered:** Cenika can design heating systems and manage products.

**Depends on:** Phase 1

---

### Phase 3: CRM + Offers

**Duration:** 4-6 weeks
**Status:** Not started

**Goals:**
- Connect projects to customers
- Generate and send offers

**Technical work:**
- [ ] CRM: contacts, activities, pipeline view
- [ ] Offer generation from project material list
- [ ] PDF export for offers
- [ ] Link projects <-> contacts <-> offers
- [ ] Activity timeline per contact

**AI capabilities:** None (deterministic offer generation)

**Value delivered:** Cenika sales team can track customers and send offers.

**Depends on:** Phase 2

---

### Phase 4: Sales Assistant AI

**Duration:** 4-6 weeks
**Status:** Not started

**Goals:**
- First AI agent
- AI-assisted sales workflows

**Technical work:**
- [ ] AI orchestrator framework
- [ ] Sales assistant agent
- [ ] Product search service (pgvector)
- [ ] Email parsing (extract requirements)
- [ ] Offer text generation (LLM)
- [ ] Chat UI for agent interaction

**AI capabilities:**
- Parse customer request -> match products -> suggest offer
- Natural language product search
- Offer text drafting

**Value delivered:** AI-assisted quote generation. Major time savings for sales reps.

**Depends on:** Phase 3

---

### Phase 5: Engineering Automation

**Duration:** 6-8 weeks
**Status:** Not started

**Goals:**
- AI-assisted heating design
- Validation and documentation

**Technical work:**
- [ ] Design suggestion agent
- [ ] Automatic heating layout proposals
- [ ] Installation rule validation (deterministic)
- [ ] Documentation generation agent
- [ ] Compliance report generation

**AI capabilities:**
- Suggest optimal heating layout for a room
- Flag installation rule violations
- Generate installation documentation

**Value delivered:** Faster, more accurate engineering. Fewer design errors.

**Depends on:** Phase 4

---

### Phase 6: Contractor Onboarding

**Duration:** 4-6 weeks
**Status:** Not started

**Goals:**
- Electrical contractors join the platform

**Technical work:**
- [ ] Contractor tenant type
- [ ] Multi-supplier product access
- [ ] Contractor-specific dashboard
- [ ] Project templates
- [ ] Simplified design workflow

**AI capabilities:** Same agents, scoped to contractor context

**Value delivered:** Platform expands beyond suppliers. Network effects begin.

**Depends on:** Phase 5

---

### Phase 7: Modular Agent Expansion

**Duration:** Ongoing
**Status:** Not started

**Goals:**
- Add specialized agents as needs emerge

**Potential agents:**
- [ ] Competitor comparison agent (for suppliers)
- [ ] Installation checklist agent
- [ ] Energy calculation agent
- [ ] Building code compliance agent
- [ ] Follow-up scheduling agent

**Value delivered:** Platform becomes increasingly intelligent over time.

**Depends on:** Phase 6

---

## 9. Risks and Design Principles

### Design Principles

1. **Engineering calculations are NEVER delegated to LLM.** Power calculations, material quantities, rule validation are pure deterministic functions.
2. **AI assists, humans decide.** Agents propose actions. Users confirm. No autonomous database mutations.
3. **Tenant isolation is non-negotiable.** RLS on every table. AI agents receive tenant-scoped data only.
4. **Start with the simplest thing that works.** No Kubernetes, no microservices in Phase 1.
5. **Agents are additive, not structural.** Adding an agent never requires changing the database or existing agents.
6. **Embeddings are infrastructure.** Generate from Phase 2. They cost nothing to store and enable all future AI.

### Key Risks

| Risk | Mitigation |
|------|------------|
| LLM gives wrong product recommendation | Always show source data. User verifies. |
| Tenant data leaks via AI context | Tenant ID injected at service level |
| Over-engineering early phases | Strict phase gates |
| Romtegner migration breaks existing tool | Keep romtegner.html working in parallel during Phase 2 |
| Cenika expects features faster than delivery | Phase 2 delivers core value. AI is bonus. |
| Vector search returns irrelevant products | Combine vector similarity with structured filters |

---

## Progress Tracking

| Phase | Status | Started | Completed |
|-------|--------|---------|-----------|
| Phase 1: Core Foundation | Not started | - | - |
| Phase 2: Supplier Pilot | Not started | - | - |
| Phase 3: CRM + Offers | Not started | - | - |
| Phase 4: Sales Assistant AI | Not started | - | - |
| Phase 5: Engineering Automation | Not started | - | - |
| Phase 6: Contractor Onboarding | Not started | - | - |
| Phase 7: Agent Expansion | Not started | - | - |
