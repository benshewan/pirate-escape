# Plans

Planning documents for **Pirate Escape**. This folder holds one high-level plan for the
game plus a plan per milestone. Milestone plans are written just before work starts and
updated as they progress.

## Documents

| File | Purpose |
| --- | --- |
| [`000-overview.md`](./000-overview.md) | High-level game plan: vision, core loop, milestones, cross-cutting concerns. |
| [`template.md`](./template.md) | Reusable structure for any new plan (game-level or milestone). |

The tracker below is the **single source of truth for milestone status**. Milestone plans
record their own detail and link back here; do not duplicate status tables elsewhere
(`000-overview.md` intentionally does not).

## Conventions

- **One plan per milestone.** The overview lists milestones only; details live in their
  own plan file.
- **Naming:** `NNN-slug.md` for top-level plans (`000-overview.md`), `mNN-slug.md` for
  milestone plans (`m01-player-movement.md`). `template.md` is the one deliberately
  un-numbered file.
- **Starting a plan:** copy `template.md` to the new `NNN-`/`mNN-` filename, fill it in,
  then add/fill the plan's row in the tracker.
- **Status values:** `draft` (being written) → `planned` (agreed, not started) → `active`
  (in progress) → `blocked` / `done`. New ideas that are not being scheduled go under the
  overview's "Post-v1 ideas", not into a milestone.
- **Write milestones top-down.** Each milestone plan links back to the overview and to
  the milestone it depends on.
- Keep the **Decisions log** section current — it is the record of *why*, not just *what*.
  Bump the plan's `Updated` date whenever you change it.

## Milestone tracker

| # | Milestone | Status | Depends on | Plan |
| --- | --- | --- | --- | --- |
| M0 | Foundations & web build | done | — | — |
| M1 | Player sprite & movement | planned | M0 | — |
| M2 | Platforms | planned | M1 | — |
| M3 | Items on platforms (coins & buckets) | planned | M2 | — |
| M4 | Infinite upward scroll | planned | M2, M3 | — |
| M5 | Rising water | planned | M4 | — |
| M6 | Game flow & UI | planned | M3, M5 | — |
| M7 | Juice, audio & polish | planned | M6 | — |
| M8 | Balance, optimisation & ship | planned | M7 | — |
