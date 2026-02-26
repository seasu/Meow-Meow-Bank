# AGENTS.md

## Cursor Cloud specific instructions

### Project Overview

Meow Meow Bank (喵喵金幣屋) is a children's financial literacy app built with Next.js 15 (App Router), TypeScript, Tailwind CSS v4, and Vitest.

### Key Commands

| Task | Command |
|------|---------|
| Dev server | `pnpm dev` (default port 3000) |
| Build | `pnpm build` |
| Lint | `pnpm lint` |
| Unit tests | `pnpm test` |
| Watch tests | `pnpm test:watch` |

### Architecture Notes

- **Frontend**: Next.js App Router with client components in `src/components/`
- **API**: Next.js Route Handlers in `src/app/api/`
- **State**: In-memory store in `src/lib/transactions.ts` (resets on server restart)
- **Styling**: Tailwind CSS v4 via `@tailwindcss/postcss` plugin
- **Testing**: Vitest + React Testing Library + jsdom

### Gotchas

- pnpm requires `pnpm.onlyBuiltDependencies` in `package.json` to allow native build scripts for `esbuild`, `sharp`, and `unrs-resolver`. This is already configured.
- `next lint` is deprecated in Next.js 16+; the ESLint flat config in `eslint.config.mjs` uses `@eslint/eslintrc` FlatCompat for the `next/core-web-vitals` preset.
- The transaction store is in-memory and resets when the dev server restarts.
