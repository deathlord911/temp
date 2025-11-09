#!/usr/bin/env bash
set -euo pipefail
START="${1:-04_upgrade_and_check.yml}"
ALL=(
  01_destroy_old_dcs.yml
  02_create_dc_configs.yml
  03_install_dcs_with_toolbox.yml
  04_upgrade_and_check.yml
  05_cross_dns_and_sysvol.yml
  06_sysvol_sync.yml
  07_ad_health_report.yml
  08_snapshot_and_upgrade.yml
  09_ceph_safe_update.yml
  10_pve_auto_upgrades_guard.yml
  11_preupdate_health_gate.yml
  12_pre_update_hooks.yml
  13_post_update_webhook.yml
  14_ad_backup.yml
  15_maintenance_verify.yml
)
flip=0
for pb in "${ALL[@]}"; do
  [[ "$pb" == "$START" ]] && flip=1
  [[ $flip -eq 1 ]] && ansible-playbook -i ansible/inventory/hosts.yml "ansible/playbooks/$pb" || true
done

