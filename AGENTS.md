# AGENTS.md

## Cursor Cloud specific instructions

### Project Overview

Meow Meow Bank (喵喵金幣屋) — Children's financial literacy app (ages 4-10) built with Next.js 15, TypeScript, Tailwind CSS v4.

### Key Commands

| Task | Command |
|------|---------|
| Dev server | `pnpm dev` (port 3000) |
| Build | `pnpm build` |
| Lint | `pnpm lint` |
| Unit tests | `pnpm test` |

### Architecture

- **Pages** (App Router): `/` (drag+form recording), `/stats`, `/dream-tree`, `/accessories`, `/parent`
- **State**: `useReducer` + Context → `localStorage`. Pure functions in `src/lib/store.ts`.
- **Components**: LuckyCat (CSS art), BuildingScene, DragCoin/CoinTray (pointer-event drag-and-drop), CoinDrop, TabBar, TransactionForm/List
- **Sound**: Web Audio API synth in `src/lib/sounds.ts` (no external files)

### Gotchas

- `pnpm.onlyBuiltDependencies` in `package.json` allows native builds for `esbuild`, `sharp`, `unrs-resolver`.
- React 19 strict `react-hooks/set-state-in-effect` rule: drive animation state from event handlers, not effects. Use `useReducer` for context init.
- Drag-and-drop uses pointer events (not HTML5 DnD API) with `useRef` for real-time position tracking; state closures are stale during drag.
- All data is client-side `localStorage`. SSR shows a loading spinner until hydration.
