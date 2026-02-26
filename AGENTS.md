# AGENTS.md

## Cursor Cloud specific instructions

### Project Overview

Meow Meow Bank (喵喵金幣屋) is a children's financial literacy app built with Next.js 15 (App Router), TypeScript, and Tailwind CSS v4.

### Key Commands

| Task | Command |
|------|---------|
| Dev server | `pnpm dev` (default port 3000) |
| Build | `pnpm build` |
| Lint | `pnpm lint` |
| Unit tests | `pnpm test` |
| Watch tests | `pnpm test:watch` |

### Architecture

- **Pages** (Next.js App Router):
  - `/` — Main recording page (Lucky Cat, building scene, transaction form)
  - `/stats` — Income/expense statistics with charts
  - `/dream-tree` — Wish list with visual tree progress
  - `/accessories` — Achievement and cat accessory collection
  - `/parent` — Parent dashboard (review, hearts, virtual interest)
- **State**: `useReducer` + React Context in `src/lib/context.tsx`, persisted to `localStorage`
- **Data Models**: `src/lib/types.ts` (Transaction, Wish, Accessory, BuildingLevel, ParentConfig, AppState)
- **Business Logic**: Pure functions in `src/lib/store.ts` (immutable state updates)
- **Constants**: Categories, accessories, building thresholds in `src/lib/constants.ts`
- **Components**: `src/components/` — LuckyCat (CSS art), BuildingScene, TabBar, TransactionForm, TransactionList, CoinDrop

### Gotchas

- pnpm requires `pnpm.onlyBuiltDependencies` in `package.json` for `esbuild`, `sharp`, `unrs-resolver`.
- React 19 / Next.js 15 enforces strict `react-hooks/set-state-in-effect` rule. Animation state must be driven from event handlers, not `useEffect`. Use `useReducer` for context state initialization instead of `useState` + `useEffect`.
- All state is client-side (localStorage). Server-side rendering shows a loading spinner until hydration completes.
- `next lint` is deprecated in Next.js 16+; the current `eslint.config.mjs` uses FlatCompat.
