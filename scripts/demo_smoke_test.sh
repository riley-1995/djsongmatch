#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FRONTEND_URL="${FRONTEND_URL:-http://localhost:3000}"
BACKEND_URL="${BACKEND_URL:-http://localhost:5001}"

log() {
  printf "\n[%s] %s\n" "$(date +"%H:%M:%S")" "$1"
}

fail() {
  printf "\n[FAIL] %s\n" "$1" >&2
  exit 1
}

log "Checking Docker Compose services"
compose_services="$(docker compose ps --services --status running || true)"
printf "%s\n" "$compose_services"

if ! printf "%s\n" "$compose_services" | grep -qx 'frontend'; then
  fail "Frontend service is not running. Start the stack with: docker compose up --build -d"
fi
if ! printf "%s\n" "$compose_services" | grep -qx 'backend'; then
  fail "Backend service is not running. Start the stack with: docker compose up --build -d"
fi
if ! printf "%s\n" "$compose_services" | grep -qx 'db'; then
  fail "Database service is not running. Start the stack with: docker compose up --build -d"
fi

log "Checking frontend availability at $FRONTEND_URL"
frontend_html="$(curl -fsSL "$FRONTEND_URL" || true)"
if [[ -z "$frontend_html" ]]; then
  fail "Frontend did not respond. Inspect logs with: docker compose logs --tail=120 frontend"
fi
if ! printf "%s" "$frontend_html" | grep -qi "<html"; then
  fail "Frontend response does not look like HTML. Check frontend container logs."
fi

echo "[PASS] Frontend is reachable"

log "Checking backend song endpoint at $BACKEND_URL/api/songs/?limit=1"
song_payload="$(curl -fsSL "$BACKEND_URL/api/songs/?limit=1" || true)"
if [[ -z "$song_payload" ]]; then
  fail "Backend song endpoint is empty or unreachable."
fi
if ! printf "%s" "$song_payload" | grep -q '"songId"'; then
  fail "Backend returned no songs. Seed data with: docker compose exec backend python -m backend.scripts.manage_data seed"
fi

echo "[PASS] Backend songs endpoint returned data"

normalized_song_payload="$(printf "%s" "$song_payload" | tr -d '\n\r\t ')"
song_id="$(printf "%s" "$normalized_song_payload" | sed -n 's/.*"songId":\([0-9][0-9]*\).*/\1/p' | head -n1)"
if [[ -z "$song_id" ]]; then
  fail "Could not parse songId from backend response."
fi

log "Checking recommendations for songId=$song_id"
recommendations_payload="$(curl -fsSL "$BACKEND_URL/api/songs/$song_id/recommendations?limit=5" || true)"
if [[ -z "$recommendations_payload" ]]; then
  fail "Recommendations endpoint did not respond."
fi
if ! printf "%s" "$recommendations_payload" | grep -q '"songId"'; then
  fail "Recommendations endpoint returned no songs. Verify FAISS assets and logs."
fi

echo "[PASS] Recommendations endpoint returned data"

log "Demo environment is ready"
echo "Open $FRONTEND_URL in your browser and start recording."
