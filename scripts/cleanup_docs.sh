#!/usr/bin/env bash
set -euo pipefail

# ===== Settings =====
# Dry run? (0 = löschen, 1 = nur anzeigen)
DRY_RUN="${DRY_RUN:-0}"

# Repo-Root ermitteln (fällt auf PWD zurück, falls kein Git-Repo)
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DOCS_DIR="$REPO_ROOT/docs"

# Dateien/Liste: alte, inkonsistente Doku-Dateien, die raus sollen
# (idempotent: falls schon weg, passiert nichts)
DOCS_TO_REMOVE=(
  "CEPH_AND_STORAGE_NOTES.md"
  "CHANGELOG.md"
  "diagram.md"
  "HA_AND_RECOVERY_GUIDE.md"
  "index.md"
  "playbooks.md"
  "README_ops.md"
  "SUMMARY.md"
  "TROUBLESHOOTING_RECIPES.md"
  "VARIABLES_MATRIX.md"
)

# Root-Level Markdown, die (falls vorhanden) entfernt werden dürfen.
# -> bewusst LEER gelassen; trage hier gezielt Dateien ein, wenn nötig.
ROOT_MD_TO_REMOVE=(
  # Beispiel: "OLD_README.md"
)

# ===== Helpers =====
in_git() {
  git -C "$REPO_ROOT" ls-files --error-unmatch -- "$1" >/dev/null 2>&1
}

say() { printf '%b\n' "$*"; }

do_git_rm() {
  local path="$1"
  if in_git "$path"; then
    if [[ "$DRY_RUN" == "1" ]]; then
      say "  [git rm] (DRY) $path"
    else
      say "  [git rm] $path"
      git -C "$REPO_ROOT" rm -f -- "$path" >/dev/null 2>&1 || true
    fi
  fi
}

do_rm() {
  local path="$1"
  if [[ -e "$path" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      say "  [rm] (DRY) $path"
    else
      say "  [rm] $path"
      rm -f -- "$path" || true
    fi
  fi
}

# ===== Start =====
say "[i] Canonical cleanup starting in: $REPO_ROOT"

# --- docs/ säubern ---
if [[ -d "$DOCS_DIR" ]]; then
  say "[i] Cleaning docs/ ..."
  for f in "${DOCS_TO_REMOVE[@]}"; do
    abs="$DOCS_DIR/$f"
    do_git_rm "$abs"
    do_rm "$abs"
  done
else
  say "[i] docs/ not found, skipping."
fi

# --- Root-Level Markdown gezielt entfernen (Allowlist) ---
say "[i] Cleaning root-level markdown files ..."
for f in "${ROOT_MD_TO_REMOVE[@]}"; do
  abs="$REPO_ROOT/$f"
  do_git_rm "$abs"
  do_rm "$abs"
done

say "[i] Cleanup complete."

# Optional: Git-Status zeigen
if command -v git >/dev/null 2>&1; then
  say ""
  say "[i] git status:"
  git -C "$REPO_ROOT" status --short || true
fi
