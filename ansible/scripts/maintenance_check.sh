#!/usr/bin/env bash
set -euo pipefail

echo "Running maintenance verification…"

ANS_CFG="/root/temp/ansible/ansible.cfg"
PLAY="/root/temp/ansible/playbooks/15_maintenance_verify.yml"

ANSIBLE_CONFIG="$ANS_CFG" \
ansible-playbook "$PLAY"

# Jüngsten Report zeigen (Issues-Abschnitt)
REPODIR="/root/temp/ansible/playbooks/reports"
LATEST="$(ls -1t "$REPODIR"/maintenance-*.md | head -n1 || true)"

if [ -n "${LATEST:-}" ] && [ -f "$LATEST" ]; then
  echo
  echo "== Issues from $(basename "$LATEST") =="
  sed -n '/^## Issues/,/^## Details/p' "$LATEST" || true
else
  echo "No maintenance report found."
fi
