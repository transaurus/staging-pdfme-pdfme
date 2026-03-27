#!/usr/bin/env bash
set -euo pipefail

# prepare.sh for pdfme/pdfme
# Docusaurus 3.9.2 with React 19, npm (website/ is standalone)
# Clones repo, installs deps. Does NOT run write-translations or build.

REPO_URL="https://github.com/pdfme/pdfme.git"
BRANCH="main"
REPO_DIR="source-repo"
DOCUSAURUS_PATH="website"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# --- Clone (skip if already exists) ---
if [ ! -d "${REPO_DIR}" ]; then
  git clone --depth 1 --branch "${BRANCH}" "${REPO_URL}" "${REPO_DIR}"
fi

cd "${REPO_DIR}/${DOCUSAURUS_PATH}"

# --- Install dependencies ---
npm install --legacy-peer-deps

# --- Apply fixes.json if present ---
FIXES_JSON="${SCRIPT_DIR}/fixes.json"
if [ -f "${FIXES_JSON}" ]; then
  echo "[INFO] Applying content fixes..."
  node -e "
  const fs = require('fs');
  const path = require('path');
  const fixes = JSON.parse(fs.readFileSync('${FIXES_JSON}', 'utf8'));
  for (const [file, ops] of Object.entries(fixes.fixes || {})) {
    if (!fs.existsSync(file)) { console.log('  skip (not found):', file); continue; }
    let content = fs.readFileSync(file, 'utf8');
    for (const op of ops) {
      if (op.type === 'replace' && content.includes(op.find)) {
        content = content.split(op.find).join(op.replace || '');
        console.log('  fixed:', file, '-', op.comment || '');
      }
    }
    fs.writeFileSync(file, content);
  }
  for (const [file, cfg] of Object.entries(fixes.newFiles || {})) {
    const c = typeof cfg === 'string' ? cfg : cfg.content;
    fs.mkdirSync(path.dirname(file), {recursive: true});
    fs.writeFileSync(file, c);
    console.log('  created:', file);
  }
  "
fi

echo "[DONE] Repository is ready for docusaurus commands."
