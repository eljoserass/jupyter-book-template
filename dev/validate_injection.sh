#!/usr/bin/env bash
set -euo pipefail

HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-3111}"
LOG_FILE="${LOG_FILE:-/tmp/jb-template-start.log}"

if command -v jupyter >/dev/null 2>&1; then
  JB=(jupyter book)
elif command -v jupyter-book >/dev/null 2>&1; then
  JB=(jupyter-book)
elif test -x ".venv/bin/jupyter"; then
  JB=(".venv/bin/jupyter" "book")
elif test -x ".venv/bin/jupyter-book"; then
  JB=(".venv/bin/jupyter-book")
else
  echo "ERROR: jupyter/jupyter-book command not found in PATH or .venv/bin."
  exit 1
fi

echo "Building book..."
"${JB[@]}" build >/dev/null

echo "Starting book server on http://${HOST}:${PORT} ..."
HOST="$HOST" PORT="$PORT" "${JB[@]}" start >"$LOG_FILE" 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" >/dev/null 2>&1 || true' EXIT

for _ in $(seq 1 40); do
  if curl -fsS "http://${HOST}:${PORT}/" >/tmp/jb-template-index.html 2>/dev/null; then
    break
  fi
  sleep 0.5
done

if ! test -f /tmp/jb-template-index.html; then
  echo "ERROR: server did not come up. See $LOG_FILE"
  exit 1
fi

echo "Validating custom injection markers..."
if ! grep -q "pyscript.net/releases/2026.1.1/core.js" /tmp/jb-template-index.html; then
  echo "ERROR: PyScript script tag was not injected in rendered HTML."
  echo "This usually means jupyter-book start is not using the custom _static/js/server.js injection path."
  exit 1
fi

if ! grep -q "dynamical_systems.js" /tmp/jb-template-index.html; then
  echo "ERROR: custom _static/js script was not injected in rendered HTML."
  exit 1
fi

if ! test -f "_build/templates/site/myst/book-theme/server.js"; then
  echo "ERROR: expected generated server.js at _build/templates/site/myst/book-theme/server.js"
  exit 1
fi

if ! grep -q "executeDynSimCode" "_build/templates/site/myst/book-theme/server.js"; then
  echo "ERROR: generated server.js does not include dynsim injection code."
  exit 1
fi

echo "OK: custom server injection is active."
