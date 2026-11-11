# Fresno Arcade Implementation Plan

> For agentic workers: Execute one component at a time with failing tests before code.

**Goal:** Keyboard-only and controller-only operation on current HaxeFlixel.
**Architecture:** Preserve existing Actions and states, extend pause navigation, retain private AxolAPI through a pinned submodule.
**Tech Stack:** Haxe 4.3.7, Flixel 6.2.1, Lime 8.3.2, OpenFL 9.5.2, flixel-addons 4.0.2, hxcpp 4.3.2.
**Spec:** docs/superpowers/specs/2026-11-11-fresno-arcade-design.md

## Global constraints
- Windows build; HTML5 compatibility check.
- No publication or deployment; no Lewton use.
- No private dependency copied into public sources.
- Workflow success is not test certification; inspect per-stage JSON.

## Review focus
- Jump works with held and released keyboard/gamepad controls.
- Back never confirms a destructive option.
- Pause, restart, title return and cabinet quit remain accessible.
- Ending and failed network requests do not trap the player.
- New game and retry retain correct score/state behavior.

## Tasks
- [x] Read current source and identify isolated branch from main 24d70dd5.
- [x] Verify seven source contracts fail on unchanged source.
- [ ] Add input bindings, dedicated confirm/back and pause menu.
- [ ] Adapt game and private historical AxolAPI snapshot to current Flixel.
- [ ] Add native automated input/menu regressions and telemetry isolation.
- [ ] Compile actual Windows/HTML5 game and run native tests through private hosted CI.
- [ ] Review exact final diff, inspect JSON/logs, report remaining physical-device tests.
