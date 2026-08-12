# 🎧 DJ Song Match
![Lint](https://github.com/ChicoState/djsongmatch/actions/workflows/lint.yml/badge.svg)
![Type Check](https://github.com/ChicoState/djsongmatch/actions/workflows/typecheck.yml/badge.svg)
[![Deploy to Production](https://github.com/ChicoState/djsongmatch/actions/workflows/deploy_to_home_server.yml/badge.svg)](https://github.com/ChicoState/djsongmatch/actions/workflows/deploy_to_home_server.yml)

DJ Song Match is a web application that helps DJs build harmonically compatible playlists using music theory and machine learning.

Recommendations are generated using:
- Camelot wheel harmonic compatibility
- BPM / tempo compatibility
- Approximate Nearest Neighbor (ANN) search with FAISS

## Tech Stack

**Backend**
- Python
- Flask
- SQLAlchemy
- PostgreSQL

**Frontend**
- Next.js
- TypeScript
- Tailwind CSS

**Other**
- FAISS
- Docker & Docker Compose

---

## Features

Users can:

- Search for songs
- Generate harmonic recommendations
- Fine-tune recommendations with audio feature sliders
- Build and export playlists
- Toggle dark mode

---

# Getting Started

## Prerequisites

- Install [Docker](https://www.docker.com/)
- Make sure Docker is **running**

---

## Run the Full Application with Docker Compose (Recommended)

From the repository root, run:
```bash
docker compose up --build
```

This starts:

- PostgreSQL
- Flask backend
- Next.js frontend
- nginx

Available services:

- Frontend: [http://localhost:3000](http://localhost:3000)  
- Backend: [http://localhost:5001](http://localhost:5001)
- Nginx: [http://localhost](http://localhost)
- Postgres: `localhost:5432`

### Optional `.env`
For local development, a root `.env` file is optional. If you want to override the default Docker database or add Firebase credentials, copy `.env-example` to `.env` and edit the values.

## Managing the Containers

**Pause containers:**
```bash
docker compose stop
```

**Resume paused containers:**
```bash
docker compose start
```

Restart running containers:
```bash
docker compose restart
```

**Stop/restart individual containers:**
```bash
docker compose stop frontend
docker compose restart backend
```

Remove containers while **keeping** the PostgreSQL database:
```bash
docker compose down
```

Remove containers **and** the PostgreSQL database volume:
```bash
docker compose down -v
```
> **Warning**
>
> `docker compose down -v` permanently removes the local PostgreSQL database volume.
> Use it only if you intentionally want to recreate and reseed the database.

---

## Viewing Logs

Frontend:
```bash
docker compose logs --tail=120 frontend
```

Backend:
```bash
docker compose logs --tail=120 backend
```

Database:
```bash
docker compose logs --tail=120 db
```

---

## Run Only the Frontend

```bash
docker build -t djsongmatch ./frontend
docker run -p 3000:3000 djsongmatch
```

---

## Run Only the Backend

```bash
docker build -t flask-backend -f backend/Dockerfile .
docker run -p 5001:5001 flask-backend
```

---

## VS Code Dev Container

The development container uses the `frontend` service defined in `docker-compose.yml` and runs against the same local PostgreSQL-backed stack as the application. 

If you make changes to the Docker configuration, rebuild the development container before continuing development.

---

# Deployment Notes

DJ Song Match consists of two services:

- A Next.js frontend
- A Flask backend

Both services require access to the same PostgreSQL database.

The frontend also requires the backend API URL and, if Firebase authentication is enabled, the Firebase client configuration.

### Deployment Requirements

Any hosting solution should provide:

- A PostgreSQL database
- A host for the Flask backend
- A host for the Next.js frontend
- The required environment variables

### Production Environment Variables

Frontend:

```bash
DATABASE_URL=postgresql://...
NEXT_PUBLIC_API_URL=https://your-backend.example.com

NEXT_PUBLIC_FIREBASE_API_KEY=
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=
NEXT_PUBLIC_FIREBASE_PROJECT_ID=
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=
NEXT_PUBLIC_FIREBASE_APP_ID=
```

Backend:

```bash
DATABASE_URL=postgresql://...
FLASK_ENV=production
```

---

## Backend Script Usage (Optional Development Workflow)

### Set Up Virtual Environment

If you plan to run backend scripts outside Docker, create and activate a virtual environment from the repository root.

```bash
python3 -m venv venv
```

macOS/Linux:
```bash
source venv/bin/activate
```

Windows:
```powershell
venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r backend/requirements.txt
```

### Backend Script CLI

The project includes a unified CLI for common data-management tasks.

View available commands:
```bash
python -m backend.scripts.manage_data --help
```

Current commands include:
- `process`
- `seed`
- `update`
- `index`
- `all`

The underlying operations can also be run individually as Python modules:

Example (from root level):
```bash
python3 -m backend.scripts.operations.pre_process
```

Deactivate the virtual environment when finished:
```bash
deactivate
```
