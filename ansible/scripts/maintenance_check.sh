#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

: "${ANSIBLE_CONFIG:=ansible/ansible.cfg}"

echo "Running maintenance verification…"
ansible-playbook ansible/playbooks/15_maintenance_verify.yml "$@"

echo
echo "Done."
