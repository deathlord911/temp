#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCS_DIR="$ROOT_DIR/docs"

echo "[i] Canonical cleanup starting in: $ROOT_DIR"

# Canonical lists
ROOT_ALLOWED=("README.md" ".gitignore")
DOCS_ALLOWED=("DOCS_OVERVIEW.md" "PLAYBOOK_REFERENCE.md" "MAINTENANCE_GUIDE.md")

# Ensure docs dir exists
mkdir -p "$DOCS_DIR"

# 1) Remove stray files under docs/ (keep only allowed)
echo "[i] Cleaning docs/ ..."
shopt -s nullglob dotglob
for f in "$DOCS_DIR"/*; do
  base="$(basename "$f")"
  keep=0
  for a in "${DOCS_ALLOWED[@]}"; do
    [[ "$base" == "$a" ]] && keep=1 && break
  done
  if [[ $keep -eq 0 ]]; then
    if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      echo "  [git rm] $f"
      git rm -rq --cached "$f" || true
    fi
    echo "  [rm] $f"
    rm -rf -- "$f"
  fi
done

# 2) Remove empty dirs in docs/
find "$DOCS_DIR" -type d -empty -delete || true

# 3) Remove stray root-level docs that are not allowed (only Markdown files)
echo "[i] Cleaning root-level markdown files ..."
for f in "$ROOT_DIR"/*.md; do
  base="$(basename "$f")"
  keep=0
  for a in "${ROOT_ALLOWED[@]}"; do
    [[ "$base" == "$a" ]] && keep=1 && break
  done
  if [[ $keep -eq 0 ]]; then
    if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
      echo "  [git rm] $f"
      git rm -q "$f" || true
    fi
    echo "  [rm] $f"
    rm -f -- "$f"
  fi
done

echo "[✓] Cleanup complete. Review changes with: git status
Then commit:
  git add -A
  git commit -m 'docs: purge legacy files and keep canonical docs set'
