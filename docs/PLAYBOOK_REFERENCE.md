# Playbook-Referenz 01–15

> Diese Referenz ist die maßgebliche Beschreibung der Playbooks.
> Benutze sie zum Verstehen, Ausführen und Debuggen.

## 01_destroy_old_dcs.yml
- Entfernt alte CTs `100/101` clusterweit (node-aware), inkl. HA, Snapshots, `mp0` & defekter `unused*`-Zeilen.
- Sicher gegen „nicht gefunden“.

## 02_create_dc_configs.yml
- Erzeugt `zmb-ad.conf` und `zmb-ad-join.conf` unter `/root/zamba-conf/`.

## 03_install_dcs_with_toolbox.yml
- Führt Toolbox-Install für `CT100` (zmb-ad, **raidpool**) und `CT101` (zmb-ad-join, **ceph-rbd**).
- Erkennt Fehlerdialoge der Toolbox (z.B. „Invalid option, exiting...“).
- Prüft nach Installation, migriert RootFS falls nötig (nur wenn CT vorhanden).

## 04_upgrade_and_check.yml
- Non-interactive Apt-Update/Dist-Upgrade (Demo) in beiden CTs.
- `samba-ad-dc` Status-Tail.

## 05_cross_dns_and_sysvol.yml
- Stellt Fallback-DNS/Suchdomäne via `pct set` ein und rebootet CTs.

## 06_sysvol_sync.yml
- Pull-Sync: CT101 ⟵ CT100 (`/var/lib/samba/sysvol`), per `rsync` via SSH-Key.
- Dry-Run steuerbar: `-e sysvol_dry_run=true|false`.

## 07_ad_health_report.yml
- Sammelt DRS/Netlogon/SYSVOL Health und schreibt Report in `reports/`.

## 08_snapshot_and_upgrade.yml
- Snapshot-Retention (3), Apt-Update/Upgrade, Tail auf AD-Dienst.

## 09_ceph_safe_update.yml
- Installiert `ceph-safe-update` Script + Timer (deaktiviert WARN-Durchläufe standardmäßig).

## 10_pve_auto_upgrades_guard.yml
- Deaktiviert/Maskiert `unattended-upgrades` & `pve-auto-upgrades*`, aktiviert ceph-safe Timer.

## 11_preupdate_health_gate.yml
- Health Gate vor Upgrades: APT/DPKG busy + Locks eliminieren.

## 12_pre_update_hooks.yml
- Führt lokale Pre-Update Hooks sequentiell aus.

## 13_post_update_webhook.yml
- Optionaler Webhook (überspringt ohne URL).

## 14_ad_backup.yml
- Online-Backup aus CT100 mit Rotation; optionales Rsync-Ziel.

## 15_maintenance_verify.yml
- Vollständiger Maintenance-Report inkl. Ceph/Timer/Locks/AD/Backups.
- Failt nur, wenn Issues gefunden wurden (Gate).
