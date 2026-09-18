# Learning Log — Dependency Intelligence

A running, dated record of decisions, reasoning, and checkpoint answers as the project progresses.

This is the companion to [`ROADMAP.md`](ROADMAP.md) — the roadmap tracks *what's done*; this tracks *the reasoning behind it* and *how well the underlying concepts actually landed*. Checkpoint questions from the roadmap get answered here, not just checked off.

## How to read an entry

Each entry: date, phase/task, what was attempted or decided, the reasoning given, and an assessment (solid / partial gap / needs revisit). A "partial gap" isn't a failing grade — it's a flag to come back to before treating the topic as done for interview purposes.

---

## 2026-09-18 — Phase 1 kicked off

- **Task:** decide the repository fetch strategy — `git clone` (shallow, via shell-out or `go-git`) vs. GitHub REST API (Contents API or tarball/archive endpoint).
- **Status:** assigned as a research task. Angela is investigating rate limits, monorepo discovery, and implementation cost before writing any code, per the Understand → Attempt → Ask → Implement → Test → Explain workflow.
- **Next:** bring back a recommendation + reasoning, then a minimal proof of concept (fetch one file from a real public repo).
