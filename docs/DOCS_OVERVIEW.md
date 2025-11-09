# Systemarchitektur & Ablaufbeschreibung

## 1. Clusterstruktur
| Komponente | Funktion | Node / Storage |
|-------------|-----------|----------------|
| CT100 – zmb-ad | Primary Domain Controller | pve3 / raidpool |
| CT101 – zmb-ad-join | Secondary Domain Controller | pve3 / ceph-rbd |

## 2. Netz & Kommunikation
- VLAN100 (192.168.100.0/24) → Domain Network
- VLAN5 (192.168.5.0/24) → Cluster/Management

## 3. Werkzeugkette
- **Proxmox VE 8.x**
- **Zamba-LXC-Toolbox** (Bashclub) unter `/root/zamba-lxc-toolbox`
- **Ansible** – Automatisierung sämtlicher Tasks
- **Ceph RBD & CephFS** – Storage-Verteilung
- **ZFS Raidpool** – schnelle lokale Volumes

## 4. Ablaufkette
1. Vorhandene Container löschen  
2. Neue Konfigurationen generieren  
3. DCs via Toolbox installieren (CT100→raidpool, CT101→ceph-rbd)  
4. Upgrade + DNS + SYSVOL prüfen  
5. Health & Backup  
6. Ceph-safe-update aktivieren  
7. Maintenance-Gate kontrollieren  

## 5. Report-Struktur
Alle Reports liegen unter:
```
ansible/playbooks/reports/
├── run-YYYYMMDD-HHMMSS.log
├── ad-health-YYYYMMDD-HHMMSS.md
└── maintenance-YYYYMMDD-HHMMSS.md
```

## 6. Sonderkomponenten
- `includes/find_ct_nodes.yml` → universelles Include für Node Detection  
- `run-all.sh` → orchestriert alle Schritte  
- `ceph-safe-update.timer` → sicheres Ceph-Upgrade via systemd  
