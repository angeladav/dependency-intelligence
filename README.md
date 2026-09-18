# Dependency Intelligence

An open-source developer platform for analyzing software dependencies — dependency graph construction, vulnerability/advisory analysis, and dependency blast-radius analysis, with an emphasis on evidence and explainability over opaque risk scores.

Full project plan: [`docs/PROJECT_PLAN.md`](docs/PROJECT_PLAN.md).

## Status

Early scaffolding. No features implemented yet.

## MVP goal

Given a public GitHub repository, produce an accurate dependency graph and identify known vulnerabilities affecting the dependency tree (npm ecosystem only, to start).

## Stack

- **Backend:** Go
- **Frontend:** React + TypeScript (not yet scaffolded)
- **Database:** PostgreSQL
- **Infra:** Docker Compose (local), AWS (later)

## Running locally

```bash
cp .env.example .env
make docker-up   # starts Postgres
make run         # starts the API on :8080
curl localhost:8080/healthz
make docker-down
```

## Architecture

Modular monolith. No microservices, no Kubernetes, no Redis until a real need for caching/job coordination shows up. See the project plan for the full rationale.
