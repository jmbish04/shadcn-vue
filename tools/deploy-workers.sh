#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Nuxt 3 → Cloudflare Workers local helper
# - Installs deps (no frozen lockfile)
# - Ensures nitro preset 'cloudflare'
# - Writes wrangler.toml if missing/misaligned
# - Builds and runs wrangler dev or deploy
# ------------------------------------------------------------

APP_NAME="${APP_NAME:-shadcn-vue}"
WRANGLER_VERSION="${WRANGLER_VERSION:-^4}"
COMPAT_DATE="${COMPAT_DATE:-2024-11-01}"
MAIN_ENTRY="./.output/server/index.mjs"
ASSETS_DIR="./.output/public"
ASSETS_BINDING="ASSETS"

MODE="${1:-dev}"   # dev | deploy | build | check | clean

bold() { printf "\033[1m%s\033[0m\n" "$*"; }
info() { printf "ℹ️  %s\n" "$*"; }
ok()   { printf "✅ %s\n" "$*"; }
warn() { printf "⚠️  %s\n" "$*"; }
err()  { printf "❌ %s\n" "$*" >&2; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "Missing required command: $1"; exit 1; }
}

ensure_corepack() {
  if ! command -v pnpm >/dev/null 2>&1; then
    if command -v corepack >/dev/null 2>&1; then
      info "Enabling pnpm via corepack…"
      corepack enable >/dev/null 2>&1 || true
      corepack prepare pnpm@latest --activate
    else
      err "pnpm not found and corepack missing. Install Node 18+ (includes corepack) or install pnpm."
      exit 1
    fi
  fi
}

ensure_wrangler() {
  if ! npx --yes wrangler@"$WRANGLER_VERSION" --version >/dev/null 2>&1; then
    info "Preparing wrangler $WRANGLER_VERSION via npx (no global install needed)…"
  fi
}

ensure_nuxt_present() {
  if ! npx --yes nuxi --version >/dev/null 2>&1 && ! grep -q '"nuxt"' package.json; then
    err "Nuxt not detected. Are you in the repo root with package.json containing nuxt?"
    exit 1
  fi
}

ensure_nitro_cloudflare_preset() {
  local cfg="nuxt.config.ts"
  if [[ ! -f "$cfg" ]]; then
    warn "$cfg not found; creating minimal config with cloudflare preset."
    cat > "$cfg" <<'EOF'
export default defineNuxtConfig({
  nitro: { preset: 'cloudflare', minify: true }
})
EOF
    ok "Created $cfg with cloudflare preset."
    return
  fi

  if ! grep -q "preset: *['\"]cloudflare['\"]" "$cfg"; then
    warn "cloudflare preset not found in $cfg; adding minimal nitro block (non-destructive append)."
    cat >> "$cfg" <<'EOF'

// Added by deploy-workers.sh to target Cloudflare Workers
if (!globalThis.__added_cloudflare_preset) {
  globalThis.__added_cloudflare_preset = true;
  // @ts-ignore
  export default defineNuxtConfig({
    nitro: { preset: 'cloudflare', minify: true }
  })
}
EOF
    ok "Injected cloudflare preset into $cfg."
  else
    ok "Found cloudflare preset in $cfg."
  fi
}

write_wrangler_toml() {
  local toml="wrangler.toml"
  local desired=$(cat <<EOF
name = "${APP_NAME}"
main = "${MAIN_ENTRY}"
compatibility_date = "${COMPAT_DATE}"
compatibility_flags = ["nodejs_compat"]

[assets]
directory = "${ASSETS_DIR}"
binding = "${ASSETS_BINDING}"
EOF
)
  if [[ -f "$toml" ]]; then
    # Basic sanity checks
    if grep -q 'main = ' "$toml" && grep -q '\[assets\]' "$toml"; then
      ok "Existing wrangler.toml looks present; ensuring core fields…"
      # Replace main/compat/asset lines to be safe
      tmp="$(mktemp)"
      awk -v main="$MAIN_ENTRY" \
          -v date="$COMPAT_DATE" \
          -v dir="$ASSETS_DIR" \
          -v bind="$ASSETS_BINDING" '
        BEGIN { in_assets=0 }
        {
          if ($0 ~ /^main =/) {$0="main = \"" main "\""}
          if ($0 ~ /^compatibility_date =/) {$0="compatibility_date = \"" date "\""}
          if ($0 ~ /^\[assets\]/) { in_assets=1 }
          if (in_assets && $0 ~ /^directory =/) {$0="directory = \"" dir "\""}
          if (in_assets && $0 ~ /^binding =/) {$0="binding = \"" bind "\""}
          print
        }' "$toml" > "$tmp"
      mv "$tmp" "$toml"
    else
      warn "wrangler.toml exists but missing fields; rewriting minimal config."
      printf "%s\n" "$desired" > "$toml"
    fi
  else
    info "Creating wrangler.toml…"
    printf "%s\n" "$desired" > "$toml"
  fi
  ok "wrangler.toml ready."
}

install_deps() {
  ensure_corepack
  info "Installing dependencies (no frozen lockfile)…"
  pnpm install --no-frozen-lockfile
  ok "Dependencies installed."
}

build_nuxt() {
  ensure_nuxt_present
  info "Building Nuxt for Cloudflare (nuxi build --preset=cloudflare)…"
  npx --yes nuxi build --preset=cloudflare
  [[ -f "$MAIN_ENTRY" ]] || { err "Build missing server entry: $MAIN_ENTRY"; exit 1; }
  [[ -d "$ASSETS_DIR" ]] || { warn "Assets directory not found at ${ASSETS_DIR} (SSR may still work)."; }
  ok "Nuxt build complete."
}

run_dev() {
  info "Starting Wrangler dev…"
  npx --yes wrangler@"$WRANGLER_VERSION" dev
}

run_deploy() {
  : "${CLOUDFLARE_ACCOUNT_ID:?Set CLOUDFLARE_ACCOUNT_ID in env}"
  : "${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN in env}"
  info "Deploying with Wrangler…"
  npx --yes wrangler@"$WRANGLER_VERSION" deploy
  ok "Deploy finished."
}

clean_output() {
  info "Removing .output/…"
  rm -rf .output
  ok "Cleaned."
}

case "$MODE" in
  check)
    bold "Checking prerequisites…"
    need_cmd node
    need_cmd npx
    ensure_corepack
    ensure_wrangler
    ensure_nuxt_present
    ok "All checks passed."
    ;;
  clean)
    clean_output
    ;;
  build)
    install_deps
    ensure_nitro_cloudflare_preset
    write_wrangler_toml
    build_nuxt
    ;;
  dev)
    install_deps
    ensure_nitro_cloudflare_preset
    write_wrangler_toml
    build_nuxt
    run_dev
    ;;
  deploy)
    install_deps
    ensure_nitro_cloudflare_preset
    write_wrangler_toml
    build_nuxt
    run_deploy
    ;;
  *)
    err "Usage: $0 [check|clean|build|dev|deploy]"
    exit 2
    ;;
esac
