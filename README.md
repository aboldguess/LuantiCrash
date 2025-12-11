# Luanti Crash Survival Prototype

## Overview
A lightweight Luanti (Minetest fork) game prototype that demonstrates procedural, destructible voxel terrain with chunk-based generation. Players spawn with starter tools, can walk the world with standard WASD + space controls, and the map generates dynamically as you explore.

## Quick Start (All Platforms)
1. Install Luanti/Minetest 5.8+ from [https://www.minetest.net/downloads/](https://www.minetest.net/downloads/).
2. Clone this repository: `git clone <repo-url>` and `cd LuantiCrash`.
3. Launch the game:
   - Linux/macOS: `./scripts/run_game.sh /path/to/luanti --port 30000`
   - Windows (PowerShell): `bash scripts/run_game.sh "C:/Program Files/luanti/bin/luanti.exe" --port 30000`
   - Raspberry Pi: ensure OpenGL drivers are enabled, then run the Linux command above pointing to your Luanti binary.
4. In the Luanti UI, choose the `Crash Survival Prototype` game and start a new world.

### Local Development Setup
- Recommended: use a Python virtual environment for tooling (optional for Lua code):
  - Linux/macOS: `python3 -m venv .venv && source .venv/bin/activate`
  - Windows: `py -3 -m venv .venv; .venv\\Scripts\\Activate.ps1`
- Lint Lua with `luacheck` if available: `luacheck games/crash_survival/mods`.
- Debug logging: set `crash_world_debug = true` or `crash_player_debug = true` in `minetest.conf`.

### Deployment Notes
- The project is ready for local hosting via the Luanti binary. For hosted play (e.g., Render.com), deploy a headless Luanti server pointing to `games/crash_survival` and expose the chosen port.
- Use the `--port` flag in `scripts/run_game.sh` to change the server port for local or hosted environments.

## Features Implemented
- Dynamic chunk-based terrain using Perlin noise (stone, dirt, grass layers) with destructible/buildable voxels.
- Player spawn helper ensuring safe landing and starter builder pick for resource gathering.
- Debug-friendly logging toggles via `minetest.conf` flags.
- Portable launcher script to simplify testing on any platform.

## Roadmap
- [x] Procedural chunk terrain with destructible/buildable voxels (branch: main).
- [x] Player spawn logic with starter tools and physics tuning (branch: main).
- [ ] Collar damage system with safe/danger zones.
- [ ] Inventory UI and crafting prototype.
- [ ] Portable safe-zone transmitter items and placement.
- [ ] Server-side persistence for land ownership and economy hooks.
- [ ] Web-facing admin and monetization layers (subscriptions, Stripe) for future versions.

## Major Features Log
1. Added procedural chunk terrain generator and base nodes — branch: main.
2. Added player spawn defaults and starter gear — branch: main.
3. Added cross-platform launcher helper script — branch: main.

## Repository Structure
- `games/crash_survival/` — Game definition and bundled mods.
  - `mods/crash_world/` — Terrain, nodes, and map generation.
  - `mods/crash_player/` — Player defaults and spawn handling.
- `scripts/` — Utility scripts for running the game.

## Troubleshooting
- Missing textures: Luanti will auto-apply a placeholder; add PNGs to `mods/crash_world/textures/` as needed.
- Performance tuning: lower view range in settings or reduce `scale` in `noise_def` inside `crash_world/init.lua`.
- If the world fails to generate, ensure no other game is selected and that `--gameid crash_survival` is passed.
