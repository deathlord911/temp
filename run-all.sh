#!/usr/bin/env bash
# run-all.sh — Orchestriert alle Ansible-Playbooks mit Logging
# kompatibel zu bash; kein zsh-Syntax mehr.

set -euo pipefail

# --- Helper -------------------------------------------------------------------
TS() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(TS)] $*"; }

# --- Pfade --------------------------------------------------------------------
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INV="$ROOT_DIR/ansible/inventory/hosts.yml"
REPORT_DIR="$ROOT_DIR/ansible/playbooks/reports"
LOG="$REPORT_DIR/run-$(date +%Y%m%d-%H%M%S).log"

# Korrekte Toolbox-Location (wie besprochen)
TOOLBOX_DIR="/root/zamba-lxc-toolbox"

# --- Vorbereitungen -----------------------------------------------------------
mkdir -p "$REPORT_DIR"
touch "$LOG"

# menschenfreundlichere Ausgabe
export ANSIBLE_STDOUT_CALLBACK=yaml
export ANSIBLE_NOCOLOR=0

# Fallback, falls ansible in einem venv liegt
if [[ -n "${VIRTUAL_ENV-}" ]]; then
  PATH="$VIRTUAL_ENV/bin:$PATH"
fi

# --- Fehlerfalle --------------------------------------------------------------
cleanup() {
  local rc=$?
  if [[ $rc -ne 0 ]]; then
    log "❌ Fehler – Abbruch. Siehe Log: $LOG" | tee -a "$LOG"
  else
    log "✅ Durchlauf beendet. Log: $LOG" | tee -a "$LOG"
  fi
  exit $rc
}
trap cleanup EXIT

# --- Startbanner --------------------------------------------------------------
log "====== One-Shot-Run gestartet ======"    | tee -a "$LOG"
log "Root: $ROOT_DIR"                         | tee -a "$LOG"
log "Inventory: $INV"                         | tee -a "$LOG"
log "Log: $LOG"                               | tee -a "$LOG"
log "Toolbox: $TOOLBOX_DIR"                   | tee -a "$LOG"

# --- Sanity: Toolbox & install.sh vorhanden? ---------------------------------
if [[ ! -d "$TOOLBOX_DIR" ]]; then
  log "❌ Toolbox-Verzeichnis nicht gefunden: $TOOLBOX_DIR" | tee -a "$LOG"
  exit 1
fi
if [[ ! -f "$TOOLBOX_DIR/install.sh" ]]; then
  log "❌ install.sh nicht gefunden unter $TOOLBOX_DIR/install.sh" | tee -a "$LOG"
  exit 1
fi
chmod a+rx "$TOOLBOX_DIR" "$TOOLBOX_DIR"/install.sh || true

# --- Helper zum Ausführen eines Playbooks -------------------------------------
run_pb() {
  local title="$1"
  local file="$2"
  log "===============================" | tee -a "$LOG"
  log "▶ Starte $file"                 | tee -a "$LOG"
  log "===============================" | tee -a "$LOG"

  ANSIBLE_STDOUT_CALLBACK=yaml \
  ansible-playbook -i "$INV" "$ROOT_DIR/ansible/playbooks/$file" 2>&1 | tee -a "$LOG"
}

# --- Reichweitentest ----------------------------------------------------------
log "Reichweitentest: ansible ping..."        | tee -a "$LOG"
ansible -i "$INV" all -m ping 2>&1 | tee -a "$LOG"

# --- Ablauf -------------------------------------------------------------------
run_pb "01" "01_destroy_old_dcs.yml"
run_pb "02" "02_create_dc_configs.yml"

# WICHTIG: Playbook 03 erwartet korrekten Toolbox-Pfad via Vars/Defaults
# (du hast den Pfad bereits im Playbook auf /root/zamba-lxc-toolbox umgestellt)
run_pb "03" "03_install_dcs_with_toolbox.yml"

run_pb "04" "04_upgrade_and_check.yml"
run_pb "05" "05_cross_dns_and_sysvol.yml"
run_pb "06" "06_sysvol_sync.yml"
run_pb "07" "07_ad_health_report.yml"
run_pb "08" "08_snapshot_and_upgrade.yml"
run_pb "09" "09_ceph_safe_update.yml"
run_pb "10" "10_pve_auto_upgrades_guard.yml"
run_pb "11" "11_preupdate_health_gate.yml"
run_pb "12" "12_pre_update_hooks.yml"
run_pb "13" "13_post_update_webhook.yml"
run_pb "14" "14_ad_backup.yml"
run_pb "15" "15_maintenance_verify.yml"
