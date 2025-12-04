## 🚀 Branch Loan API – Dockerized Flask + Postgres + CI/CD (GHCR)

A fully containerized microservice for managing branch microloans.
This solution includes:

Production-ready Dockerfile (multi-stage build, non-root user, Gunicorn)

Multi-environment Docker Compose (dev, staging, production)

Secure environment variable management

CI/CD pipeline using GitHub Actions

Automated vulnerability scanning with Trivy

Container publishing to GitHub Container Registry (GHCR)

## 📌 Table of Contents

Run Application Locally

Switch Between Environments

Environment Variables Explained

CI/CD Pipeline Explained

Architecture Diagram

Design Decisions

Troubleshooting Guide

## 🧪 Run the Application Locally (Dev Environment)

1️⃣ Clone the repository
git clone https://github.com/Vaibhav979/dummy-branch-app.git
cd dummy-branch-app

2️⃣ Create certificates (only needed for dev HTTPS)
mkcert -install
mkcert -key-file certs/key.pem -cert-file certs/cert.pem branch.local

3️⃣ Start local development environment
docker compose --env-file .env.dev up --build

4️⃣ Verify the API is running

Open in browser or Postman:

https://branch.local/health

Expected response:

{ "status": "ok" }

## 🏗 Switch Between Environments

This project supports:

Environment File Use Case
Development .env.dev Local testing, debugging
Staging .env.staging Pre-production testing
Production .env.prod Real deployment, optimized

Run staging
docker compose --env-file .env.staging up --build

Run production
docker compose --env-file .env.prod up -d

### 🔧 Environment Variables Explained

| Variable          | Description                                              |
| ----------------- | -------------------------------------------------------- |
| POSTGRES_USER     | Username for the PostgreSQL database                     |
| POSTGRES_PASSWORD | Password for the PostgreSQL database                     |
| POSTGRES_DB       | Name of the database                                     |
| DB_PORT           | Port exposed by Postgres to the host                     |
| API_PORT          | Port the Flask/Gunicorn API listens on                   |
| FLASK_ENV         | Application mode: `development`, `staging`, `production` |
| DATABASE_URL      | SQLAlchemy DSN for connecting to Postgres                |
| LOG_LEVEL         | Logging verbosity (`debug`, `info`, `warning`, etc.)     |
| ENV_FILE          | Tells docker-compose which `.env` file to load           |

## 🚀 CI/CD Pipeline Overview

Every push to main triggers:

1️⃣ Build

Install dependencies

Run tests

Build Docker image using multi-stage Dockerfile

2️⃣ Security Scan

Trivy scans:

filesystem

Docker image

Only report high/critical vulnerabilities without breaking pipeline

3️⃣ Publish Image to GHCR

Tags pushed automatically:

ghcr.io/<username>/branch-loan-api:<commit-sha>
ghcr.io/<username>/branch-loan-api:latest

Meaning the production deployment always gets the newest stable image.

### 🖼 Architecture Diagram

                     ┌───────────────────────────┐
                     │     Developer Machine      │
                     │  Runs Docker Compose (env) │
                     └───────────────┬────────────┘
                                     │
                                     ▼
                        ┌─────────────────────────┐
                        │      API Container      │
                        │  Flask + Gunicorn + SSL │
                        └──────────────┬──────────┘
                                      │ SQLAlchemy
                                      ▼
                        ┌─────────────────────────┐
                        │     Postgres Database   │
                        └─────────────────────────┘

### 🚀 CI/CD Pipeline (GitHub Actions)

┌────────────────────────────────────────────────────────────┐
│ GitHub Actions │
├────────────────────────────────────────────────────────────┤
│ 1️⃣ Checkout code │
│ 2️⃣ Setup Python │
│ 3️⃣ Install dependencies │
│ 4️⃣ Run tests (pytest) │
│ 5️⃣ Build Docker image │
│ 6️⃣ Security Scan (Trivy) │
│ 7️⃣ Push verified image → GHCR (main branch only) │
└────────────────────────────────────────────────────────────┘

Deployment:

Local environments pull images from GHCR using:

---

## 🧠 Design Decisions

1️⃣ Multi-stage Dockerfile

Reduces image size

Improves security

Ensures production environment matches CI build

Trade-off:
More complex Dockerfile vs simpler single-stage image.

2️⃣ Use of docker-compose for multi-environment

Easy environment switching

Clean separation of dev/staging/prod

Centralized env variable handling

3️⃣ HTTPS support in dev (mkcert)

Simulates real-world production HTTPS

Helps prepare backend for secure deployment

Trade-off: Local certificates can confuse beginners.

4️⃣ GitHub Actions for CI/CD

Free, fast, integrated into GitHub

GHCR provides easy permission handling

With more time, I would:

Add integration tests

Add auto-deploy to Kubernetes or Docker Swarm

Implement rollback strategy

Add log aggregation with ELK/Grafana

## 🛠 Troubleshooting

❌ API not reachable

Check containers:

docker ps

Logs:

docker logs branch_api

❌ Database connection errors
docker logs branch_db

Common fix: Increase healthcheck timeout.

❌ SSL errors

If running dev mode, recreate certificates:

mkcert -install
mkcert -key-file certs/key.pem -cert-file certs/cert.pem branch.local

❌ CI/CD failing at pushing image

Make sure repo permissions allow package publishing:

Settings → Actions → Workflow permissions → Read & write

❌ PR pipeline works but main pipeline doesn’t

Check condition in workflow:

if: github.ref == 'refs/heads/main'
