# Nuxt Minimal Starter

## Cloudflare Workers (Nuxt 3 + Nitro cloudflare preset)

**Local:**

```bash
pnpm install
pnpm build     # builds with --preset=cloudflare -> .output/*
npx wrangler dev
```

**Deploy:**

```bash
# Requires CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID set (locally or in CI)
pnpm deploy
```

CI: Push to `main` triggers `.github/workflows/deploy.yml`.

Look at the [Nuxt documentation](https://nuxt.com/docs/getting-started/introduction) to learn more.

## Setup

Make sure to install dependencies:

```bash
# npm
npm install

# pnpm
pnpm install

# yarn
yarn install

# bun
bun install
```

## Development Server

Start the development server on `http://localhost:3000`:

```bash
# npm
npm run dev

# pnpm
pnpm dev

# yarn
yarn dev

# bun
bun run dev
```

## Production

Build the application for production:

```bash
# npm
npm run build

# pnpm
pnpm build

# yarn
yarn build

# bun
bun run build
```

Locally preview production build:

```bash
# npm
npm run preview

# pnpm
pnpm preview

# yarn
yarn preview

# bun
bun run preview
```

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.
