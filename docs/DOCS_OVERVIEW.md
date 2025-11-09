# Dokumentations-Überblick

Diese Sammlung fasst **alle** relevanten Themen zusammen (Architektur, Variablen, CLI-Flows).
Für Details zu einzelnen Playbooks: siehe `docs/PLAYBOOK_REFERENCE.md`.

## Komponenten
- **Ansible**: Orchestrierung der Proxmox-Hosts & LXC-Container
- **Zamba LXC Toolbox**: Installation der AD-Container (zmb-ad, zmb-ad-join)
- **Ceph & Guard**: sicheres Updatefenster/Timer
- **AD-Wartung**: SYSVOL-Sync, DRS/NETLOGON-Prüfungen, Backups

## Lebenszyklus
1. Zerstören alter DCs (optional)
2. Configs generieren
3. Installation (inkl. Storage-Zuweisung/Migration)
4. Post-Checks, Health, Backups, Snapshots
5. Maintenance-Gate & Reports

## Storage-Regeln (wichtig)
- `CT100` ⇒ **raidpool**
- `CT101` ⇒ **ceph-rbd**
Die Tooling-Tasks setzen/migrieren das RootFS entsprechend.
