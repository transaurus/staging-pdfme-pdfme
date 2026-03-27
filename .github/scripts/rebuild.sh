#!/usr/bin/env bash
set -euo pipefail

# rebuild.sh for pdfme/pdfme
# Runs on existing source tree (no clone). Installs deps and builds.
# Current directory must be the docusaurus root (website/).

# --- Node version ---
# Node 20+ required for Docusaurus 3.x
export NVM_DIR="${HOME}/.nvm"
if [ -f "${NVM_DIR}/nvm.sh" ]; then
  # shellcheck source=/dev/null
  source "${NVM_DIR}/nvm.sh"
  nvm use 20 || nvm install 20
fi

node --version
npm --version

# --- Install dependencies ---
npm install --legacy-peer-deps

# --- Build ---
npm run build

echo "[DONE] Build complete."
