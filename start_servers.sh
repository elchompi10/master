#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$ROOT/.server_pids"
BACKEND_DIR="$ROOT/backend"
FRONTEND_DIR="$ROOT/frontend"
VENV="$BACKEND_DIR/.venv"
BACK_LOG="$ROOT/backend.log"
FRONT_LOG="$ROOT/frontend.log"

if [ -f "$PID_FILE" ]; then
  echo "Ya hay un servidor en ejecución. Ejecuta stop_servers.sh primero o borra $PID_FILE si estás seguro."
  exit 1
fi

if [ -d "$VENV" ]; then
  # shellcheck source=/dev/null
  source "$VENV/bin/activate"
else
  echo "Advertencia: no se encontró el virtualenv en $VENV. Se usará python del sistema."
fi

cd "$BACKEND_DIR"
nohup uvicorn app:app --host 0.0.0.0 --port 8000 --reload > "$BACK_LOG" 2>&1 &
BACK_PID=$!

echo "Backend arrancado (PID $BACK_PID), log en $BACK_LOG"

cd "$FRONTEND_DIR"
nohup python3 -m http.server 8080 > "$FRONT_LOG" 2>&1 &
FRONT_PID=$!

echo "Frontend arrancado (PID $FRONT_PID), log en $FRONT_LOG"

echo "$BACK_PID $FRONT_PID" > "$PID_FILE"

echo "URLs:
  Backend: http://127.0.0.1:8000
  Frontend: http://127.0.0.1:8080"
