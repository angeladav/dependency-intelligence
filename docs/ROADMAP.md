# Dependency Intelligence — Roadmap & Learning Plan

Interactive, checkbox-tracked version: https://claude.ai/artifact/4k36moWBimxwqmADXm7AZQ

Product scope is defined in [`PROJECT_PLAN.md`](PROJECT_PLAN.md). This document governs **sequencing and learning process**: what order things get built in, what to actually understand at each step, and how the 10-hour/week budget is spent.

## Operating principles

- Workflow per unit of work: **Understand → Attempt → Ask → Implement → Test → Explain**.
- ~10 hrs/week combined across Dependency Intelligence (DI) and EvalLab. DSA/interview prep runs on separate time and isn't scheduled here.
- Dependency Intelligence runs first, alone, until its MVP milestone (end of Phase 6). EvalLab does not start until then — splitting a 10-hour week across two unfamiliar backend paradigms at once slows both down.
- Complexity (Redis, queues, a graph DB, microservices) is earned by hitting a real requirement, not added preemptively.
- No fabricated metrics, ever — resume numbers come from the system once it exists.
- Every phase ends with checkpoint questions you should be able to answer without notes.

## Phase 0 — Foundations (done, 2026-09-18)

- [x] Go module + directory scaffold created
- [x] Postgres running via `make docker-up`
- [x] `/healthz` verified returning 200
- [x] Pushed to a public GitHub repo

## Phase 1 — Repository Ingestion & Manifest Parsing (~2–3 wks)

**Goal:** given a GitHub URL, produce an in-memory list of direct and resolved dependencies.

Scope:
- [ ] Decide fetch strategy: shallow `git clone` vs. GitHub contents/tarball API
- [ ] Locate `package.json` and the lockfile in the repo
- [ ] Parse `package.json` into a direct-dependency list
- [ ] Parse `package-lock.json`, handling v1 / v2 / v3 shape differences
- [ ] Represent direct vs. transitive + resolved version in memory

Concepts to actually understand:
- Why npm's lockfile format changed across v1 / v2 / v3
- What a semver range (`^`, `~`, exact) actually permits
- Declared (manifest) dependency vs. resolved (lockfile) dependency
- Go idioms: explicit error returns, JSON unmarshaling into structs, optional fields

Checkpoints:
- [ ] Why can two installs of the same `package.json` produce different dependency trees without a lockfile?
- [ ] `package.json` says `^2.0.0`, the lockfile pins `2.3.1` — what's authoritative, and why?

## Phase 2 — Dependency Graph Construction & Storage (~3–4 wks)

**Goal:** the resolved dependency tree becomes a real graph, stored relationally and queryable by depth.

Scope:
- [ ] Design an in-memory `Graph` type: nodes = package@version, edges = "depends on"
- [ ] Implement BFS and DFS traversal
- [ ] Classify direct vs. transitive by traversal distance
- [ ] Design the Postgres schema: `packages`, `package_versions`, `dependencies`
- [ ] Choose and wire up a migration tool
- [ ] Persist a scan's resolved graph
- [ ] Write a recursive CTE that walks a dependency chain N levels deep

Concepts:
- Adjacency list vs. edge list vs. matrix — why adjacency list fits here
- BFS vs. DFS — shortest path to a vulnerable package vs. enumerating all paths
- Why a relational store is enough here — no graph database at this scale
- Recursive CTEs: anchor term, recursive term, the working table

Checkpoints:
- [ ] Why adjacency-list-in-Postgres instead of a graph database, at this scale?
- [ ] Trace what a recursive CTE actually does, step by step, in plain English.
- [ ] What breaks first at 50,000 nodes — the traversal algorithm, or the SQL?

## Phase 3 — API Surface & Integration Testing (~2 wks)

**Goal:** a real REST surface backed by tests that hit an actual database, not a mock.

Scope:
- [ ] Design endpoints: create scan, get scan status, get scan graph, list scan history
- [ ] Choose a router (stdlib mux vs. chi) now that there's real surface area
- [ ] Decide idempotency behavior for scan creation
- [ ] Integration tests against real Postgres (testcontainers-go or a compose test DB)

Concepts:
- REST resource modeling: resources vs. actions, status codes, pagination
- Idempotency: what happens if "create scan" fires twice for one commit
- Why integration tests catch what a mocked DB doesn't

Checkpoints:
- [ ] Is triggering a scan idempotent in your design? What makes it so, or why isn't it?
- [ ] What's the difference between your unit tests and integration tests, and why do you need both?

## Phase 4 — Vulnerability Matching & Concurrency (~3 wks)

**Goal:** every resolved package checked against real advisory data — concurrently, safely, with partial failure handled.

Scope:
- [ ] Integrate OSV.dev for advisory lookups
- [ ] Implement semver range intersection matching
- [ ] Build a bounded worker pool for concurrent advisory fetches
- [ ] Handle partial failure without failing the whole scan
- [ ] Add context-based cancellation
- [ ] Add rate limiting against the OSV API

Concepts:
- Goroutines + channels; why a bounded worker pool over unbounded goroutines
- Where the race condition risk lives, and how to eliminate it
- `context.Context` for cancellation
- Partial-success error handling in concurrent code
- Token bucket vs. fixed-window rate limiting

Checkpoints:
- [ ] One package's OSV lookup times out, out of 400 — what does the user see?
- [ ] Where's the race condition risk in your worker pool, and how did you eliminate it?
- [ ] Why bound the concurrency instead of firing off 400 goroutines at once?

## Phase 5 — Web UI (~1.5–2 wks)

**Goal:** a dashboard to trigger scans and read the results.

Scope:
- [ ] Scaffold Vite + React + TypeScript
- [ ] Scan trigger + status view (polling)
- [ ] Dependency table/tree view — not a force-directed graph yet
- [ ] Findings list view

Concepts:
- How much logic belongs in the frontend vs. the API
- Polling vs. websockets for a long-running scan, at this scale

Checkpoints:
- [ ] Why polling instead of websockets here?

## Phase 6 — Scan History & Change Detection (~1 wk)

**Goal:** diff two scans of the same repo — added, removed, changed, newly flagged.

Scope:
- [ ] Store scan history per repository
- [ ] Implement added/removed/changed diff between two scans
- [ ] Surface new-advisory diffs

Concepts:
- Diffing two sets/graphs efficiently
- What "changed" precisely means: version bump vs. same version, different resolution path

Checkpoints:
- [ ] How does your diff algorithm scale with dependency count — does that matter here?

---

**MVP milestone: end of Phase 6.** ~13–15 weeks at 10 hrs/week (~3–3.5 months).

## Phase 7+ — Differentiators (post-MVP, not scheduled)

- Blast-radius analysis — trace which components/paths a vulnerable package reaches, production vs. dev-only
- Dependency health indicators — release frequency, freshness, maintainer signals, as individual evidence, not a risk score
- CI/CD integration — GitHub Action, baseline comparison, PR comments that explain why something was flagged

Scope for these gets defined for real once the MVP ships.

## EvalLab — secondary track (starts after DI MVP)

High-level sketch only, gets the same phase-by-phase treatment once it's actually up next:

1. Dataset / test case CRUD and storage
2. Synchronous evaluation runner, single provider, exact-match evaluator
3. Provider abstraction — multiple LLM providers behind one interface
4. Rule-based and structured-output evaluators
5. Results storage, aggregate metrics, run-to-run comparison
6. Custom async worker architecture — deliberately not Celery, for the learning value
7. Failure-analysis drill-down: aggregate → case → output → evidence
8. Regression testing / CI hook

## What derails a plan like this

- Scope creep toward the long-term vision sections (SBOM, multi-language, GitHub Apps) before the MVP ships
- Polishing the UI before backend correctness is solid — the UI phase is deliberately last and short
- Starting EvalLab early "to not lose momentum" — fragments both projects instead of sustaining either
- Treating estimates as deadlines — they calibrate scope; if a phase runs 2x, cut scope, not understanding
- Silent scope additions "since we're in there anyway" — Redis, queues, a graph DB before a real, encountered need

## Definition of done, per phase

Code merged to main, tests passing, every checkpoint question answerable without notes, a short note in the commit log about what shipped and why. Light check-in at the end of each phase — what took longer/shorter than expected, what wasn't as well understood as it felt — before scoping the next one.
