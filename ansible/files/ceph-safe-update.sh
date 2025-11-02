#!/usr/bin/env bash
set -euo pipefail

log(){ logger -t ceph-safe-update "$*"; echo "$(date -Is) $*"; }

exec 9>/var/lock/ceph-safe-update.lock
flock -n 9 || { log "another ceph-safe-update is running on this node; exiting."; exit 0; }

if ! command -v ceph >/dev/null 2>&1; then
  log "ceph CLI not found; aborting."; exit 1
fi
if ! ceph status >/dev/null 2>&1; then
  log "ceph status failed; aborting."; exit 1
fi

HEALTH="$(ceph status --format json 2>/dev/null | python3 -c 'import sys,json; print(json.load(sys.stdin)["health"]["status"])' 2>/dev/null || echo UNKNOWN)"
if [ "$HEALTH" != "HEALTH_OK" ]; then
  log "cluster health is $HEALTH; aborting upgrade."; exit 22
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq || true
apt-get -y -o Dpkg::Options::=--force-confdef \
          -o Dpkg::Options::=--force-confold full-upgrade

log "apt full-upgrade finished successfully."
exit 0
