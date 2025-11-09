# Maintenance & Recovery Guide

## 1) Routinewartung
```bash
./run-all.sh
```
führt sämtliche Checks inkl. Backup & Verify.

## 2) Einzelchecks
```bash
ansible-playbook ansible/playbooks/07_ad_health_report.yml
ansible-playbook ansible/playbooks/15_maintenance_verify.yml
```

## 3) SYSVOL Sync
```bash
ansible-playbook ansible/playbooks/06_sysvol_sync.yml -e "sysvol_dry_run=false"
```

## 4) Upgrade-Sicherheit
Nur updaten, wenn `15_maintenance_verify.yml` ohne Issues durchläuft.

**Timer prüfen**
```bash
systemctl is-enabled ceph-safe-update.timer
systemctl is-active  ceph-safe-update.timer
```

## 5) Backup prüfen
```bash
pct exec 100 -- ls -lh /backup/samba-ad
```

## 6) Troubleshooting

| Problem | Ursache | Lösung |
|:--|:--|:--|
| Toolbox „Invalid option“ | Aufruf ohne `-s`/`-i` | Fix im Playbook 03 vorhanden |
| rsync not found | Paket fehlt im CT | Playbook 06 installiert automatisch |
| ceph-rbd not found | Poolname falsch | `ceph osd pool ls` prüfen |
| DRS Fehler | Replikationsproblem | `samba-tool drs showrepl` |
| Ceph Warnungen | unbalancierte PGs | `ceph health detail` |

## 7) Recovery AD
1. Letztes Backup ermitteln (CT100)  
2. Restore via Proxmox (Snapshot/Archiv)  
3. `samba-tool drs replicate` triggern  
4. SYSVOL erneut synchronisieren  

## 8) Nützliche Befehle
| Zweck | Befehl |
|-------|--------|
| AD Replikation | `samba-tool drs showrepl` |
| SYSVOL Dry-Run | `rsync -av --dry-run` |
| Ceph Status | `ceph -s` |
| DC Status | `systemctl status samba-ad-dc` |
