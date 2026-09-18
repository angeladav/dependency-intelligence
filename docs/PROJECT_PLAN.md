# Dependency Intelligence

## 1. Project Context

### Working name
**Dependency Intelligence**

### One-line description
An open-source developer platform that analyzes software dependencies to identify vulnerabilities, maintenance risks, dependency concentration, and potential blast radius—then explains the findings in terms developers can act on.

### Problem

Modern applications rarely depend on a small number of libraries. A single application can contain hundreds or thousands of direct and transitive dependencies.

Existing dependency scanners are useful for answering questions such as:

> “Does this dependency have a known vulnerability?”

Dependency Intelligence aims to answer the harder questions:

> “Where does this dependency actually matter in my application?”

> “What parts of my system could be affected?”

> “How much of my application depends on this package?”

> “Which dependencies represent unusual maintenance or supply-chain risk?”

> “What changed between this release and the previous one?”

The product should emphasize **evidence and explainability**, rather than producing an opaque numerical “risk score.”

---

## 2. Target Users

Primary users:

- software engineers
- engineering teams
- security engineers
- DevOps/DevSecOps engineers
- open-source maintainers

Initial target:

> An individual developer who wants to scan a GitHub repository and understand its dependency structure and risks.

Do not initially target large enterprises. Enterprise functionality can come later.

---

## 3. Core Product

A user provides a repository.

Dependency Intelligence:

1. identifies the project's package ecosystem
2. resolves its dependency graph
3. stores the graph
4. analyzes dependency metadata
5. checks known security advisories
6. identifies affected application paths
7. detects changes between scans
8. presents the results through a web dashboard and CLI/API

Example:

```text
Repository
    │
    ▼
Repository ingestion
    │
    ▼
Package manifest / lockfile parsing
    │
    ▼
Dependency resolution
    │
    ▼
Dependency graph
    │
    ├── Vulnerability analysis
    ├── Dependency health analysis
    ├── Reachability analysis
    ├── Change analysis
    └── Dependency concentration
              │
              ▼
         Developer UI
```

---

# 4. MVP

The first version should be deliberately small.

### MVP goal

Given a public GitHub repository:

> **Produce an accurate dependency graph and identify known vulnerabilities affecting the dependency tree.**

### MVP capabilities

- GitHub repository URL input
- repository cloning/ingestion
- `package.json` / lockfile parsing
- npm dependency graph
- direct vs. transitive dependency distinction
- package version identification
- vulnerability/advisory lookup
- dependency graph visualization
- scan history
- basic REST API
- basic web interface

### Explicitly NOT in MVP

- every programming language
- AI-generated security advice
- sophisticated risk scoring
- enterprise authentication
- Kubernetes
- complex microservices
- browser extension
- automatic remediation
- production-scale distributed infrastructure

We earn complexity by encountering real requirements.

---

# 5. Differentiating Features

After the MVP works, the major differentiator becomes **dependency blast-radius analysis**.

For example:

```text
Vulnerability
     │
     ▼
package X
     │
     ├── Service A
     │      └── production
     │
     ├── Service B
     │      └── production
     │
     └── Test tooling
            └── development
```

The system should help answer:

- Which packages introduce the affected dependency?
- Is it direct or transitive?
- Which application components depend on it?
- Which dependency paths lead to it?
- Did the dependency enter or leave the project recently?
- Is it present in production or only development tooling?

The objective is **context**, not merely severity labels.

---

# 6. Dependency Health

Later versions can analyze signals such as:

- release frequency
- time since latest release
- dependency freshness
- unresolved issues
- maintainer information
- number of maintainers where reliable data exists
- package adoption
- dependency-tree size
- license metadata
- known advisories
- release anomalies

These should be presented as **individual evidence-based indicators**, not as an authoritative statement that a package is “safe” or “unsafe.”

---

# 7. Change Detection

A particularly useful feature:

```text
Scan #104
    ↓
Scan #105
    ↓
Dependency diff
```

Example:

```text
Added
+ package-a 3.1.0

Removed
- package-b 2.4.1

Changed
package-c
2.1.0 → 2.3.0

New advisory
package-d
```

This eventually becomes useful inside CI.

---

# 8. CI/CD Integration

Later:

```text
GitHub PR
    │
    ▼
GitHub Action
    │
    ▼
Dependency Intelligence
    │
    ▼
Compare against baseline
    │
    ├── no meaningful change
    │
    └── new risk detected
              │
              ▼
         PR comment
```

The tool should explain *why* it flagged something.

---

# 9. Technical Architecture

## Initial architecture

Use a modular monolith rather than microservices.

```text
                    ┌──────────────────┐
                    │   React Web UI   │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │    Go API        │
                    └────────┬─────────┘
                             │
             ┌───────────────┼───────────────┐
             ▼               ▼               ▼
        PostgreSQL      Scan Engine       Redis
                             │
                             ▼
                     Dependency Graph
                             │
                             ▼
                    Advisory Sources
```

Background processing can initially run inside the same application.

As workload increases, extract workers.

---

# 10. Recommended Tech Stack

### Backend
**Go**

Why:

- excellent for developer tooling
- strong concurrency primitives
- fast startup
- easy CLI development
- statically typed
- good fit for graph processing and network-heavy workloads

### Frontend
**React + TypeScript**

You already have substantial TypeScript experience, so this lets us spend your learning time on backend/system concepts rather than relearning frontend fundamentals.

### Database
**PostgreSQL**

Use it for:

- repositories
- scans
- packages
- package versions
- dependency relationships
- advisories
- scan results

Do not introduce a graph database initially.

A relational representation of a dependency graph is a useful engineering exercise in itself.

### Cache / job infrastructure
**Redis**

Initially optional.

Introduce it when we actually need:

- caching
- job coordination
- rate limiting
- background work

### Infrastructure
**Docker**

Everything should run locally with one command.

Eventually:

**AWS**

Potentially:

- ECS/Fargate
- RDS
- ElastiCache
- S3
- CloudWatch

We don't need all of this in v0.

### CI/CD
**GitHub Actions**

### Testing

Go:

- standard Go testing
- integration tests
- benchmark tests

Frontend:

- Vitest
- React Testing Library

End-to-end:

- Playwright

### Observability

Eventually:

- OpenTelemetry
- structured logging
- metrics
- traces

---

# 11. Core Data Model

Initial entities:

```text
Repository
    id
    owner
    name
    url

Scan
    id
    repository_id
    commit_sha
    started_at
    completed_at
    status

Package
    id
    ecosystem
    name

PackageVersion
    id
    package_id
    version

Dependency
    scan_id
    parent_package
    child_package
    version_constraint
    resolved_version
    dependency_type

Advisory
    id
    package
    affected_versions
    severity
    source
    published_at

Finding
    id
    scan_id
    advisory_id
    package_version
    dependency_path
```

This will evolve as we learn what the product actually needs.

---

# 12. Engineering Problems We Intentionally Want to Encounter

This project should force you to learn:

- directed graphs
- graph traversal
- dependency resolution
- semantic versioning
- package ecosystems
- data normalization
- API design
- database indexing
- caching
- asynchronous processing
- concurrency
- retries
- idempotency
- rate limiting
- CI/CD
- security concepts
- observability
- performance optimization

These become interview material because you'll have actually encountered the problems.

---

# 13. Long-Term Vision

Potential future capabilities:

- Python/PyPI support
- Maven
- Go modules
- Cargo
- multi-language repositories
- GitHub App
- PR comments
- automated dependency update analysis
- dependency ownership mapping
- SBOM ingestion
- historical risk trends
- organization dashboards
- policy-as-code
- public API
- CLI
- IDE integration

The project does **not** need all of these.

The six-month goal is a polished, focused product.

---

# 14. Definition of Success

By the end of the project:

- public GitHub repository
- deployed application
- working CLI
- documentation
- automated tests
- CI/CD
- architecture documentation
- benchmark results
- at least a small number of external users
- technical write-up
- demo video

The strongest outcome is not the number of features.

It is being able to explain the engineering decisions behind the system.

---

# 15. Resume Narrative

Eventually, the project should support bullets along the lines of:

> Designed and built an open-source dependency intelligence platform in Go that constructs transitive dependency graphs, analyzes security advisories, and traces affected dependency paths across application components.

Then, once actual measurements exist, we can replace generic language with evidence:

> Processed X dependencies across Y repositories while reducing scan latency from A to B through incremental graph analysis and caching.

We will **never invent those numbers**. The project will generate them.