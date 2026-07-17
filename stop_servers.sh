#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$ROOT/.server_pids"

if [ ! -f "$PID_FILE" ]; then
  echo "No hay servidores registrados para detener."
  exit 1
fi

read -r BACK_PID FRONT_PID < "$PID_FILE"

for PID in "$BACK_PID" "$FRONT_PID"; do
  if [ -n "$PID" ] && kill -0 "$PID" >/dev/null 2>&1; then
    echo "Deteniendo PID $PID..."
    kill "$PID"
    sleep 1
    if kill -0 "$PID" >/dev/null 2>&1; then
      echo "PID $PID no respondió, forzando stop..."
      kill -9 "$PID"
    fi
  else
    echo "PID $PID no está en ejecución." 
  fi
done

rm -f "$PID_FILE"
echo "Servidores detenidos."
