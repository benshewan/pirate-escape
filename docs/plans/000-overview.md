# Pirate Escape — High-Level Plan

| Field | Value |
| --- | --- |
| Status | active |
| Owner | Ben |
| Created | 2026-10-17 |
| Updated | 2026-10-17 |
| Depends on | — |
| Milestone | — (game-level) |
| Blocks | all milestone plans |

## 1. Summary

Pirate Escape is a **2D vertical-scrolling arcade platformer** in Bevy, targeting the
browser via WebAssembly. The player is a pirate climbing an endless stack of randomly
placed platforms above a **rising water level**. Coins scattered on the platforms raise the
score; buckets can be collected to push the water back down. There is no finish line — the
run ends only when the water catches the player. This document is the high-level plan; each
milestone in §5 gets its own detailed plan using [`template.md`](./template.md).

## 2. Background

The repo is a greenfield Bevy 0.20 scaffold (see `src/main.rs:1`) with a working Nix/devenv
dev environment and Trunk web build already in place — that tooling is milestone **M0** and
is done. Nothing gameplay-related exists yet: no camera, no sprites, no input mapping, no
game states; `src/main.rs:8` is a bare `DefaultPlugins`. Bevy 0.20 is pinned with
`default-features = false, features = ["2d","ui","audio"]` (`Cargo.toml:9-10`).

M0 already settled several things worth not re-deciding:

- **Feature set.** `["2d","ui","audio"]` transitively pulls in `bevy_winit`,
  `bevy_window`, `bevy_render` and `bevy_gilrs`, so windows, rendering and gamepad input
  are compiled in — but any *other* subsystem must be opted into explicitly.
- **wasm plumbing.** `.cargo/config.toml` sets `getrandom_backend="wasm_js"` for
  `wasm32-unknown-unknown` (required before `rand`/`getrandom`-based RNG will compile for
  the browser); the devenv provides `wasm-opt` via `binaryen` on PATH (Trunk auto-detects
  it); and `console_error_panic_hook` + `tracing-wasm` are already wired for the wasm target.
- **Bundling.** `Trunk.toml` copies `assets/` into the web root, and `Cargo.toml` defines a
  `wasm-release` profile built with `trunk build --release --cargo-profile wasm-release`
  (see the `web-build` script in `devenv.nix`).

Because the milestones build strictly on each other (you cannot collect from a platform
that does not exist), the plan is sequenced so every milestone leaves a playable build.

## 3. Vision & core loop

> Rise, collect, bail out the water, keep rising.

The core loop, which every milestone should strengthen rather than distract from:

1. **Climb** — hop between platforms, always gaining (or losing) height.
2. **Collect** — grab coins for score, grab buckets to lower the water.
3. **Evade** — the water rises continuously and accelerates; buckets are the only relief.
4. **Fail forward** — death is inevitable; the score is how far you got. Instant restart.

Design pillars:

- **Endless and readable.** Every screenful is generated; the player always sees enough
  ahead to plan a route.
- **Two-resource tension.** Coins and buckets compete for the same attention, so greed is
  punished by the water.
- **Arcade feel.** Snappy controls, short runs, one-more-go restart loop, persistent high
  score.

## 4. Scope

### In scope (v1)

- Endless upward platform generation, collision and recycling.
- Player movement (run, jump, gravity, coyote-time/buffered jump as polish).
- Coins (score) and buckets (water mitigation) spawned on platforms.
- Continuously rising water with escalating difficulty, and a death/respawn flow.
- Persistent high score, HUD, pause, game-over/restart.
- Playable in a browser with a reasonable bundle size.

### Out of scope (v1)

- Enemies, combat, power-ups beyond buckets.
- Multiple characters, levels/level select, narrative.
- Procedural art, multiplayer, leaderboards, mobile/touch controls (revisit later).
- Save systems beyond a single high-score value.

### Post-v1 ideas

A parking lot, not a schedule. New ideas land here (or in a milestone plan's own
Non-goals) instead of being pulled into the current milestone; an item moves up into
"In scope" only with a decisions-log entry.

- Daily-run mode seeded by date (see the seeded-RNG decision in §6).
- Additional hazards, enemies, or biomes.
- Mobile/touch controls and gamepad layout tuning.
- Cosmetic unlocks / meta-progression.

## 5. Milestones

Ordered by dependency. Each becomes its own plan when work starts.

| # | Milestone | Goal | Exit criteria (summary) | Depends on |
| --- | --- | --- | --- | --- |
| **M0** | **Foundations & web build** ✅ | Runnable Bevy app on native and wasm, sane dev loop. | `cargo run` and `trunk serve` both show a window/canvas; dev shell, wasm target and Trunk build work. | — |
| **M1** | **Player sprite & movement** | A controllable pirate in a fixed-size world. | Window/camera/pixel-scale config in place (nearest filtering); sprite rendered; gravity, run, and jump feel good; input mapped for keyboard; camera framing decided. | M0 |
| **M2** | **Platforms** | Solid ground to stand and jump on. | Platforms spawn, collide, and support standing/jumping; a hand-authored test layout is playable. | M1 |
| **M3** | **Items on platforms (coins & buckets)** | Collectibles that give the loop its two resources. | Coins/buckets spawn on platforms, are picked up on contact, score increments, bucket effect is stubbed/tunable. | M2 |
| **M4** | **Infinite upward scroll** | The world never ends; the camera tracks the climb. | Platforms generate ahead of the player and recycle behind; camera follows upward only; runs are effectively endless. | M2, M3 |
| **M5** | **Rising water** | The pressure and the fail state. | Water level rises over time and accelerates with height; buckets lower it; contact ends the run. | M4 |
| **M6** | **Game flow & UI** | A complete arcade session. | Start screen, HUD (score, height, water warning), game over, instant restart, persistent high score. | M3, M5 |
| **M7** | **Juice, audio & polish** | Make it feel good. | Pickup/feedback VFX, sfx, screen shake, animation, tuning pass; no functional gaps. | M6 |
| **M8** | **Balance, optimisation & ship** | Something worth playing, fast in a browser. | Difficulty curve tuned by playtesting; wasm bundle/profiling budget met; static deploy pipeline. | M7 |

> Live status lives in [`README.md`](./README.md#milestone-tracker); the ✅ here only marks
the single completed milestone.

> Milestones M1–M5 are a thin **vertical slice**: at the end of M5 the full core loop exists
> in a rough form, and M6–M8 turn it into a game.

### Milestone summaries

Each entry is the seed for a full milestone plan; details (tasks, risks, criteria) belong
there, not here.

- **M0 — Foundations.** Done: Bevy scaffold, dev shell, Trunk build, wasm/`getrandom`
  plumbing, `wasm-release` profile. It deliberately stops at a bare `DefaultPlugins`; the
  window/camera/pixel-scale setup M0's original criteria implied now belongs to M1.
- **M1 — Player sprite & movement.** Spawn a sprite with a `Transform`, add a kinematic
  player component, gravity + horizontal control + jump, and settle the camera's framing of
  the play area. Establishes the movement "feel" everything else is judged against.
- **M2 — Platforms.** Introduce a platform component and collision so the player can stand
  on and jump between surfaces. Start with a fixed test layout, then the shape of a single
  "screen" of platforms that M4 will tile.
- **M3 — Items on platforms.** Coins and buckets as collectibles attached to platform
  surfaces with pickup detection. Score for coins; a bucket triggers a (yet-to-be-wired)
  water-lowering event. Introduces the score event/state that M6's HUD consumes.
- **M4 — Infinite upward scroll.** A chunk/screen generator that spawns platform groups
  ahead of the player and despawns those behind, plus an upward-tracking camera. Turns the
  finite test layout into an endless climb.
- **M5 — Rising water.** A water entity/level that rises on a timer (and accelerates with
  altitude). Buckets apply a downward correction. Player–water contact triggers the failure
  state that M6 surfaces.
- **M6 — Game flow & UI.** Bevy `States` for menu/playing/game-over, the HUD, restart, and
  high-score persistence (local storage under wasm). Makes it a complete, replayable session.
- **M7 — Juice, audio & polish.** Feedback and feel: pickup pops, splash, screen shake,
  sfx/music, sprite animation, and a difficulty tuning pass.
- **M8 — Balance, optimisation & ship.** Playtest-driven difficulty tuning, wasm size/perf
  budget, and a build/deploy path for static hosting.

## 6. Cross-cutting concerns

Decisions that cut across milestones and should be settled early (M1–M2) so later
milestones do not fight them.

- **Physics vs hand-rolled collision.** A simple AABB kinematic platformer likely needs less
  than a full physics engine, and `bevy_rapier2d` (0.37) is the only major 2D physics crate
  currently on Bevy 0.20. Leaning toward **hand-rolled AABB/swept collision** to keep the
  wasm bundle small and the feel tunable; revisit if collision complexity grows.
- **Coordinate system & camera.** Bevy is y-up. Fix a **logical resolution** (e.g.
  `Camera2d` + `ScalingMode::Fixed`) and drive all layout/generation from that, so gameplay
  is resolution-independent.
- **Crisp pixel art.** `ScalingMode` alone does not make pixel art sharp: use
  `ImagePlugin::default_nearest()` (nearest-neighbour filtering) and keep the scale integer
  (`ScalingMode::Fixed` with an integer factor, or `ScalingMode::Integer`). Decide this in
  M1, before art exists, because it changes `DefaultPlugins` configuration.
- **RNG & determinism.** All random placement the player sees should come from a **seeded
  RNG resource**, so generation is reproducible for debugging and future daily-run modes.
- **World layout & recycling.** One "screen/chunk" is the unit of generation and despawning
  (M4). M2's platform layout should be written with that unit in mind.
- **Assets.** Pixel-art sprites under `assets/` loaded as texture atlases via Bevy's
  built-in `TextureAtlasLayout`; no external animation crate.
- **Dev iteration loop.** Native (`cargo dev`, which builds Bevy as a dylib) is the
  iteration target; wasm is for verification only. Cold `cargo check` is dominated by
  proc-macro codegen, so `[profile.dev.package."*"] opt-level = 3` is kept for smooth
  runtime at the cost of slower cold checks. See [`AGENTS.md`](../../AGENTS.md).
- **Performance budget.** wasm is the primary target; keep plugin count low, reuse
  components, and measure bundle size from M1 onward rather than at the end. Record the
  baseline in M1 with `trunk build --release --cargo-profile wasm-release` (the profile in
  `Cargo.toml`); that same command is what M8's budget is enforced against. For reference,
  the empty M0 scaffold is ~28 MB raw / ~7.7 MB gzipped, so essentially all of the budget
  work still lies ahead.

## 7. Risks & mitigations

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Bevy 0.20 ecosystem lag (plugins still on 0.19) | Medium | Medium | Prefer built-ins; hand-roll the few systems needed; only add crates verified on 0.20. |
| Procedural generation feels unfair / unwinnable routes | Medium | High | Seeded RNG + reachability rules (max jump gap) enforced at generation time; playtest in M4/M8. |
| wasm build/iteration slowness | Medium | Medium | Keep native iteration fast: `cargo dev` (`bevy/dynamic_linking`, ~3.7x faster relinks) instead of wasm; guard bundle size early. |
| Scope creep (enemies, biomes, meta-progression) | High | Medium | Non-goals in §4; new ideas go to **Post-v1 ideas** (§4), not the current milestone. |
| Difficulty tuning squeezed to the end | Medium | Medium | Expose tuning constants from M2 onward; start rough balancing in M3/M5, not only M8. |

## 8. Open questions

Each question uses the template format `Question — owner — needed by <when>`; whoever owns
it resolves it and adds a Decisions-log entry.

- [ ] Physics engine or hand-rolled collision? — Ben — start of M2 (see §6 and Decisions log).
- [ ] Fixed logical resolution, pixel scale and filtering (nearest vs linear)? — Ben — start of M1.
- [ ] Does the camera move only on upward progress (classic) or scroll continuously? — Ben — start of M4.
- [ ] Water behaviour: strictly timer-based, or partially coupled to climb height? — Ben — start of M5.
- [ ] Bucket effect: fixed drop, percentage drop, or pause? — Ben — start of M5.
- [ ] Input targets: keyboard only, or gamepad too? (`bevy_gilrs` is already compiled in via
  the `2d`/`ui` feature set, so gamepad needs mapping work only.) — Ben — start of M1.
- [ ] High-score persistence: `localStorage` vs. none? — Ben — start of M6.

## 9. Verification

Per-milestone plans define their own checks; at the game level, "done" means:

- A full run is playable end-to-end in a desktop browser and on native.
- **Seeded generation is reproducible:** the same seed yields the same layout, so layout
  bugs are reproducible. This is a claim about *generation* only — Bevy's ECS schedule and
  float timing make full-simulation replay non-deterministic, so do not rely on that.
- Bundle stays within the wasm budget established in M1, measured with
  `trunk build --release --cargo-profile wasm-release` plus the gzipped size of `dist/`.

## 10. Decisions log

| Date | Decision | Rationale |
| --- | --- | --- |
| 2026-10-17 | Milestones M1–M5 form a vertical slice; polish/ship deferred to M7–M8. | Proves the core loop early; avoids polishing mechanics that may change. |
| 2026-10-17 | Plan template lives in `docs/plans/template.md`; one plan per milestone. | Keeps the overview readable and milestone plans independently scoped. |
| 2026-10-17 | `README.md` milestone tracker is the single source of truth for status; the overview does not duplicate a status table. | Two status tables would drift; one authoritative list keeps links simple. |
| 2026-10-17 | Window/camera/pixel-scale setup moved from M0's exit criteria to M1. | M0 stops at a bare `DefaultPlugins`, so its original criteria overstated "done". |
| 2026-10-17 | Browser bundles are built with `trunk build --release --cargo-profile wasm-release`. | Trunk has no `--profile` flag, so the `wasm-release` profile was previously dead config. |
| 2026-10-17 | New ideas go to "Post-v1 ideas" (§4) rather than being scheduled ad hoc. | Keeps scope creep out of the current milestone while preserving the idea. |
| 2026-10-17 | Native iteration uses `cargo dev` (`bevy/dynamic_linking`) rather than a static link. | Measured ~3.7x faster warm rebuilds (0.9 s vs 3.3 s); keeps edit-run loops short as the codebase grows. |
| 2026-10-17 | Keep `[profile.dev.package."*"] opt-level = 3` despite doubling cold `cargo check` (~63 s → ~151 s). | Cargo resolves `package."*"` ahead of `build-override`, so proc-macros still compile at 3; warm checks are unaffected, and dependency optimization keeps the game at a playable framerate while iterating. |

## 11. References

- [`README.md`](./README.md) — plans index and milestone tracker.
- [`template.md`](./template.md) — reusable plan structure.
- `src/main.rs`, `Cargo.toml`, `Trunk.toml`, `devenv.nix`, `.cargo/config.toml` — current
  scaffold.
- [`AGENTS.md`](../../AGENTS.md) — how to enter the dev shell and run builds.
