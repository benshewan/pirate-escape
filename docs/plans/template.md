<!--
Reusable plan template. Copy to `NNN-slug.md` (top-level) or `mNN-slug.md` (milestone) and
fill in. Keep the shape so plans stay comparable: if a section genuinely does not apply,
keep the heading and write `n/a` plus one line of why, rather than deleting it. Section
numbers are referenced from other plans, so append new sections at the end instead of
renumbering. Keep it short — a plan that nobody reads is worse than none.
-->

# <Plan title>

| Field | Value |
| --- | --- |
| Status | draft / planned / active / blocked / done |
| Owner | |
| Created | YYYY-MM-DD |
| Updated | YYYY-MM-DD |
| Milestone | M<N> — <name> |
| Depends on | <plan / milestone> |
| Blocks | <plan / milestone> |

## 1. Summary

One paragraph: what this plan delivers and why it matters. A reader should be able to stop
here and know the point.

## 2. Background

The minimum context needed to understand the work: current state of the codebase, the
problem being solved, prior decisions that constrain the approach. Link to files with
`path:line` where useful.

## 3. Goals & scope

- Bullet list of what success looks like at the feature level.

### In scope

- What this plan actually builds. Keep it to the milestone's remit.

### Non-goals

- Explicitly out of scope, deferred to a later milestone, or never.

### Post-v1 / parking lot

- Ideas that surfaced but are not scheduled. They live here (or in the overview's
  Post-v1 ideas) so they are neither lost nor silently pulled into this milestone.

## 4. Success criteria

Concrete, checkable statements. These become the acceptance test for the milestone.

- [ ] Criterion 1
- [ ] Criterion 2

## 5. Approach

The chosen design at a level just above code. Note alternatives considered and why the
selection was made (or point at the Decisions log).

## 6. Work breakdown

Ordered tasks. Small enough to each be a commit or a short session.

- [ ] Task 1
- [ ] Task 2

## 7. Dependencies & assumptions

- Depends on: …
- Assumes: … (call out anything that would invalidate the plan if wrong)

## 8. Risks & mitigations

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| | | | |

## 9. Verification

How we know it works. Cover whichever of these apply:

- **Manual:** play-through / interaction steps a human performs.
- **Automated:** tests or checks that run in CI (state the command).
- **Budget:** any limit this work must respect — wasm bundle size, load time, frame time —
  plus the command used to measure it (`trunk build --release --cargo-profile wasm-release`).
- **Determinism:** if the work consumes the seeded RNG, the seed(s) that reproduce it.

## 10. Open questions

Each question stays open until resolved; its resolution goes in the Decisions log.

- [ ] Question — owner — needed by <when> (and the default if left unresolved)

## 11. Decisions log

| Date | Decision | Rationale |
| --- | --- | --- |

## 12. References

- Links to docs, issues, prior plans, relevant source files.
