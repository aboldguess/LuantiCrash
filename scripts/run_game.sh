#!/usr/bin/env bash
# Mini README - scripts/run_game.sh
# Purpose: Launches Luanti/Minetest pointing to the Crash Survival prototype game for quick local testing.
# Usage: ./scripts/run_game.sh /path/to/luanti [--port 30000]
# Structure: argument parsing -> environment checks -> Luanti invocation with minimal logging flags.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/luanti [--port PORT]" >&2
  exit 1
fi

LUANTI_BIN="$1"
PORT="30000"
if [[ $# -ge 3 && "$2" == "--port" ]]; then
  PORT="$3"
fi

if [[ ! -x "$LUANTI_BIN" ]]; then
  echo "Luanti binary not executable: $LUANTI_BIN" >&2
  exit 1
fi

game_dir="$(cd "$(dirname "$0")/.." && pwd)/games/crash_survival"

exec "$LUANTI_BIN" \
  --gameid crash_survival \
  --game "$game_dir" \
  --port "$PORT" \
  --enable-console
