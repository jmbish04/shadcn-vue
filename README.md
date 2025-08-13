# Cloudflare Worker MCP Tool

This repo contains a Nuxt 3 single-page application and a Cloudflare Worker built with Hono. The Worker serves the UI as static assets and exposes a small API, forming a minimal MCP-style tool that can run entirely on Cloudflare's edge.

## Setup

```bash
pnpm install
```

## Development

```bash
pnpm -C packages/ui-nuxt dev      # run the Nuxt dev server
pnpm -C packages/worker dev       # develop the Worker
```

## Build

```bash
pnpm -C packages/ui-nuxt build    # generate static assets
pnpm -C packages/worker build     # bundle worker with wrangler
```

## Deployment

```bash
pnpm deploy                       # build UI then deploy worker
```

## Testing

```bash
pnpm -C packages/worker test
```

The Worker is configured via `packages/worker/wrangler.toml` and uses Node 22 and Wrangler v4.
