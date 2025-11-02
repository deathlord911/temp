#!/usr/bin/env bash
set -euo pipefail

# Konfig
LOCK="/var/lock/ceph-safe-update.lock"
MAX_OSD_PGS_DOWN=0      # optionaler Wächter
ALLOW_DEGRADED=false    # true, wenn du Update trotz DEGRADED willst (nicht empfohlen)

# flock verhindern parallele Läufe
exec 200>"$LOCK"
flock -n 200 || { echo "Already running."; exit 0; }

log() { echo "[$(date +'%F %T%z')] $*"; }

# Ceph Health Check
if ! command -v ceph >/dev/null 2>&1; then
  log "No ceph CLI on this node – proceeding as non-ceph host."
else
  HEALTH=$(ceph health -s | awk 'NR==1{print $1}')
  if [[ "$HEALTH" != "HEALTH_OK" ]]; then
    if [[ "$ALLOW_DEGRADED" != "true" ]]; then
      log "Ceph not HEALTH_OK ($HEALTH) – abort."; exit 1
    fi
    log "WARNING: Ceph=$HEALTH – proceeding due to ALLOW_DEGRADED=true."
  fi
  # Schutzflag setzen
  log "Setting 'noout' on cluster"; ceph osd set noout || true
fi

rollback() {
  if command -v ceph >/dev/null 2>&1; then
    log "Unsetting 'noout'"; ceph osd unset noout || true
  fi
}
trap rollback EXIT

# APT Update/Upgrade
log "apt-get update…"
apt-get update -qq
log "apt-get dist-upgrade…"
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold dist-upgrade

# Optional: Kernel/Service-Neustarts erkennen (Debian 'needrestart')
if command -v needrestart >/dev/null 2>&1; then
  log "needrestart summary:"
  needrestart -p || true
fi

log "Done."
