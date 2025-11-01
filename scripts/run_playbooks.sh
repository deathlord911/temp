#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
INV="ansible/inventory/hosts.ini"
ansible-playbook -i "$INV" ansible/playbooks/01_destroy_old_dcs.yml || true
ansible-playbook -i "$INV" ansible/playbooks/02_create_dc_configs.yml
ansible-playbook -i "$INV" ansible/playbooks/03_install_dcs_with_toolbox.yml
ansible-playbook -i "$INV" ansible/playbooks/04_upgrade_and_check.yml
ansible-playbook -i ansible/hosts ansible/playbooks/05_cross_dns_and_sysvol.yml || exit 1
