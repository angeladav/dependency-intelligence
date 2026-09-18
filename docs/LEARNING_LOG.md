# Learning Log — Dependency Intelligence

A running, dated record of decisions, reasoning, and checkpoint answers as the project progresses.

This is the companion to [`ROADMAP.md`](ROADMAP.md) — the roadmap tracks *what's done*; this tracks *the reasoning behind it* and *how well the underlying concepts actually landed*. Checkpoint questions from the roadmap get answered here, not just checked off.

## How to read an entry

Each entry: date, phase/task, what was attempted or decided, the reasoning given, and an assessment (solid / partial gap / needs revisit). A "partial gap" isn't a failing grade — it's a flag to come back to before treating the topic as done for interview purposes.

---

## 2026-09-18 — Phase 1: fetch strategy decided

**Task:** decide the repository fetch strategy — `git clone` vs. GitHub REST API.

**Decision:** GitHub REST API — the **Git Trees API** (`GET /repos/{owner}/{repo}/git/trees/{sha}?recursive=1`) for cheap path discovery, then the **Contents API** for fetching the specific manifest/lockfile content once found. Implemented over plain `net/http` — no `go-git`, no shelling out to the `git` binary.

**Reasoning (final, after two revisions):**
- The Trees API returns a full path listing in one request without downloading any file content — this is what actually solves monorepo discovery (`package.json` at multiple paths), which a local clone can't do without first pulling every file's content to disk.
- Rate limit was quantified, not assumed: ~2-3 API calls per scan (one tree listing + a couple of content fetches) against a 5,000/hr authenticated limit — realistic MVP usage doesn't come close. Explicit upgrade path acknowledged (GitHub App / higher-tier token) if that ever changes — treated as a problem to solve when it's real, not preemptively.
- Plain `net/http` over `go-git` or shelling out to `git`: avoids an external binary dependency in the deployment environment (Docker image, CI) and avoids a library dependency for marginal benefit on a narrow need (fetch 2-3 known files).

**Corrected along the way:**
- Initial claim that shallow clone (`--depth 1`) avoids "extra stuff" conflated commit history with file breadth. `--depth 1` trims history, not the file tree — a shallow clone of a 5,000-file repo still downloads all 5,000 files at HEAD. Corrected.
- Stated justification that the REST API is "more portable across git hosting platforms" doesn't hold — git's protocol (used by `git clone`) is actually the host-agnostic mechanism; every host's REST API is a different, incompatible surface (GitHub Contents/Trees API vs. GitLab's Repository Files API vs. Bitbucket's Source API). Dropped — wasn't load-bearing for the final decision anyway, and multi-host support isn't in MVP or long-term-vision scope.

**Assessment: solid.** The core reasoning (Trees API for discovery, rate-limit quantification, implementation simplicity) is well worked-through and stands on its own without the flawed portability claim. Two real misconceptions surfaced getting here (shallow-clone mechanics, host portability), both understood once raised rather than just accepted. Good instinct spotting the Trees API angle unprompted on the first pass, even though it got second-guessed by an unquantified rate-limit worry before coming back with actual numbers.

**Next:** proof of concept — for a real public repo, use the Trees API to list paths, find `package.json` (and lockfile), fetch its content via the Contents API, print to stdout. Bonus: repeat against a repo where `package.json` isn't at the root, to confirm the discovery step actually solves the case it's meant for.
