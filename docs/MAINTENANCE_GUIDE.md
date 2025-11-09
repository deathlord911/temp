# Maintenance & Troubleshooting

## Tägliche Checks
- `ansible-playbook 15_maintenance_verify.yml`
- Reports liegen unter `ansible/playbooks/reports/`

## SYSVOL-Sync manuell ausführen
```bash
cd /root/temp/ansible/playbooks
ansible-playbook 06_sysvol_sync.yml -e "sysvol_dry_run=false"
```

## Timer/Services prüfen
```bash
systemctl is-enabled ceph-safe-update.timer
systemctl is-enabled pve-auto-upgrades.timer
systemctl is-active  pve-auto-upgrades.timer
systemctl is-enabled unattended-upgrades.service
```

## Häufige Stolpersteine
- **Toolbox Fehlermeldung „Invalid option, exiting...“**  
  → Version unter `/root/zamba-lxc-toolbox` prüfen; unsere Playbooks rufen `-i` und `-s` korrekt.
- **rsync fehlt im CT**  
  → Playbook 06 installiert `rsync` (CT101) automatisch.
- **RootFS am falschen Storage**  
  → 03 migriert automatisch nach der Installation (sofern CTs existieren).

## Cleanup/Drift beseitigen
Nutze `scripts/cleanup_docs.sh` für konsistente Docs-Struktur.
