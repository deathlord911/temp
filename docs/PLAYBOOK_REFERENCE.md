# Playbook Referenz (01–15)

## 01_destroy_old_dcs.yml
- Entfernt alte DCs, Snapshots, HA-Einträge, defekte Konfigs.
- Idempotent: ja
- Output: Cluster ohne CT100/CT101

## 02_create_dc_configs.yml
- Erzeugt neue Toolbox-Konfigurationen (`/root/zamba-conf/*.conf`)
- Input: keine
- Output: zmb-ad.new.conf, zmb-ad-join.new.conf

## 03_install_dcs_with_toolbox.yml
- Automatisierte DC-Erstellung via Toolbox
- CT100 → raidpool, CT101 → ceph-rbd
- Prüft Storages & erzwingt Storage-Zuordnung vor Installation
- Output: Container erzeugt (CTIDs 100/101)

## 04_upgrade_and_check.yml
- Führt `apt update/dist-upgrade` aus (noninteractive)
- Prüft `samba-ad-dc` Status pro CT

## 05_cross_dns_and_sysvol.yml
- DNS & Resolver auf beiden DCs prüfen/setzen
- Fallback-DNS (1.1.1.1, 9.9.9.9), Suchdomäne
- Reboot der CTs für sicheren Resolver-Reload

## 06_sysvol_sync.yml
- rsync von CT100→CT101 (Pull auf CT101)
- Parameter: `sysvol_dry_run=true|false` (Default: true)
- Installiert automatisch `rsync`/`openssh-client` im Ziel-CT
- Output: Sync-Log

## 07_ad_health_report.yml
- Prüft Replikation & FSMO-Rollen
- Output: `reports/ad-health-YYYYMMDD.md`

## 08_snapshot_and_upgrade.yml
- Snapshot + apt Upgrade pro CT
- Retention: 3 Snapshots
- Output: `pre-upgrade-YYYYMMDD-HHMMSS`

## 09_ceph_safe_update.yml
- Installiert ceph-safe-update Script + Timer
- Startet/Enabelt den Timer

## 10_pve_auto_upgrades_guard.yml
- Deaktiviert unattended-upgrades (masked) und pve-auto-upgrades (Timer/Service)
- Stellt sicher, dass ceph-safe-update.timer aktiv ist

## 11_preupdate_health_gate.yml
- Fail, wenn APT/DPKG busy oder Locks existieren
- Säubert vorab stale locks

## 12_pre_update_hooks.yml
- Führt ausführbare Skripte in `./hooks.d` aus (falls vorhanden)

## 13_post_update_webhook.yml
- Optionaler Webhook (`-e "webhook_url=..."`)

## 14_ad_backup.yml
- Samba Online Backup in CT100 (`/backup/samba-ad`)
- Rotation: keep=7
- Optionales Rsync-Ziel

## 15_maintenance_verify.yml
- Health Gate (Ceph, APT, Timer, AD, Backup)
- Output: `maintenance-*.md`
- Bricht ab bei „Issues found > 0“ (Gate)
