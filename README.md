# Proxmox Zamba AD Deployment & Maintenance mit Ansible

Dieses Repository automatisiert die vollständige Bereitstellung, Überprüfung und Wartung
einer Zamba Active Directory Infrastruktur innerhalb eines Proxmox VE Clusters.

## Schnellstart

```bash
cd /root/temp
./run-all.sh
```

### Voraussetzungen
- Cluster: pve1, pve2, pve3
- Python venv: /opt/ansible-venv
- Toolbox: /root/zamba-lxc-toolbox
- Storages: raidpool (CT100) + ceph-rbd (CT101)
- Ansible ≥ 2.16, Python ≥ 3.10

### Struktur
```text
ansible/playbooks/01_destroy_old_dcs.yml
...
ansible/playbooks/15_maintenance_verify.yml
```

### Hauptkommandos
| Ziel | Befehl |
|------|--------|
| Vollständiger Lauf | `./run-all.sh` |
| Einzel-Playbook | `ansible-playbook ansible/playbooks/06_sysvol_sync.yml -e "sysvol_dry_run=false"` |

Weitere Informationen in [`DOCS_OVERVIEW.md`](DOCS_OVERVIEW.md)
