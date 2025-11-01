#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
INV="ansible/inventory/hosts.ini"
ansible-playbook -i "$INV" ansible/playbooks/01_destroy_old_dcs.yml || true
ansible-playbook -i "$INV" ansible/playbooks/02_create_dc_configs.yml
ansible-playbook -i "$INV" ansible/playbooks/03_install_dcs_with_toolbox.yml
