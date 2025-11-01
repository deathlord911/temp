#!/usr/bin/env bash
set -euo pipefail
export ANSIBLE_STDOUT_CALLBACK=default
export ANSIBLE_CALLBACKS_ENABLED=profile_tasks

# immer relativ zum Repo-Root ausführen
cd "$(dirname "$0")/.."

INV="ansible/inventory/hosts.ini"
LOGDIR="reports/logs"
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"

mkdir -p "$LOGDIR"

# kleine Helper-Funktion: führt ein Playbook aus und loggt alles
run() {
  local playbook="$1"
  local name
  name="$(basename "$playbook" .yml)"

  local logfile="${LOGDIR}/${TIMESTAMP}_${name}.log"

  echo ">>> RUN ${playbook}"
  # - ANSIBLE_STDOUT_CALLBACK=yaml für gut lesbare Ausgabe
  # - pipefail sorgt dafür, dass Fehler in ansible-playbook den Exitcode erhalten
  # - tee schreibt live und in die Datei
  ANSIBLE_STDOUT_CALLBACK=yaml \
  ansible-playbook -i "$INV" "$playbook" 2>&1 | tee "$logfile"

  echo ">>> DONE ${playbook}  (log: ${logfile})"
  echo
}

# 01 ist optional – Fehler hier bewusst tolerieren (z. B. wenn es keine alten DCs mehr gibt)
{
  run ansible/playbooks/01_destroy_old_dcs.yml
} || {
  echo ">>> WARN: 01_destroy_old_dcs.yml ist fehlgeschlagen, wird ignoriert."
}

# Ab hier ist alles „kritisch“ – Fehler brechen das Skript ab
run ansible/playbooks/02_create_dc_configs.yml
run ansible/playbooks/03_install_dcs_with_toolbox.yml
run ansible/playbooks/04_upgrade_and_check.yml
run ansible/playbooks/05_cross_dns_and_sysvol.yml

# (Optional) Mini-Rotation: nur die letzten 50 Logfiles behalten
ls -1t "$LOGDIR"/*.log 2>/dev/null | tail -n +51 | xargs -r rm -f

