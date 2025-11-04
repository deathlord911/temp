# Diagrams – Zamba / Proxmox Automation Suite

> GitHub-kompatible Mermaid-Diagramme ohne Parserfehler.  
> Enthält Flows, Ops-Pipeline und AD-/Backup-Übersicht.

---

## 1) Gesamtübersicht: Playbooks 01–14

```mermaid
flowchart TD
  P01["01_bootstrap_dc<br/>(DC-Init)"]
  P02["02_join_dc<br/>(2. DC beitreten)"]
  P03["03_netlogon_seed<br/>(NETLOGON vorbereiten)"]
  P04["04_dns_forwarder<br/>(DNS Forwarder setzen)"]
  P05["05_cross_dns_and_sysvol<br/>(DNS/SYSVOL Fix)"]
  P06["06_sysvol_key_and_rsync<br/>(SSH-Key + Rsync)"]
  P07["07_ad_health_report<br/>(Health Report)"]
  P08["08_snapshot_and_upgrade<br/>(CT Snapshot + Upgrade)"]
  P09["09_ceph_safe_update<br/>(Ceph-safe Timer/Script)"]
  P10["10_pve_auto_upgrades_guard<br/>(Auto-Updates Guard)"]
  P11["11_preupdate_health_gate<br/>(APT/DPKG Gate)"]
  P12["12_pre_update_hooks<br/>(optionale Hooks)"]
  P13["13_post_update_webhook<br/>(Webhook)"]
  P14["14_ad_backup<br/>(Online-Backup + Rotation)"]

  P01 --> P02 --> P03 --> P04 --> P05 --> P06 --> P07 --> P08
  P09 --> P10 --> P11 --> P12 --> P13 --> P14
```

---

## 2) Update- & Wartungspipeline

```mermaid
flowchart LR
  U09["09_ceph_safe_update<br/>(Timer/Script)"]
  U10["10_pve_auto_upgrades_guard<br/>(disable unattended/PVE)"]
  U11["11_preupdate_health_gate<br/>(APT/DPKG frei + Checks)"]
  U12["12_pre_update_hooks<br/>(optional)"]
  U08["08_snapshot_and_upgrade<br/>(Snapshot + Upgrade)"]
  U13["13_post_update_webhook<br/>(optional)"]

  U09 --> U10 --> U11 --> U12 --> U08 --> U13
```

---

## 3) AD-Health & Backup

```mermaid
sequenceDiagram
  autonumber
  participant DC_A as DC-A (CT 100)
  participant DC_B as DC-B (CT 101)
  participant Ansible as Ansible (localhost)
  participant Repo as reports/
  participant Backup as /backup/samba-ad

  Ansible->>DC_A: 07_ad_health_report (samba-tool, wbinfo, DNS, drs)
  Ansible->>DC_B: 07_ad_health_report (samba-tool, wbinfo, DNS, drs)
  Ansible->>Repo: schreibt ad-health-YYYYMMDD-HHMMSS.md

  Ansible->>DC_A: 06_sysvol_key_and_rsync (SSH Keys, rsync SYSVOL)
  DC_A-->>DC_B: rsync SYSVOL (dry-run/real)

  Ansible->>DC_A: 14_ad_backup (online backup, Kerberos CCACHE)
  DC_A-->>Backup: tar.bz2 + Rotation (optional rsync)
```

---

## 4) Hinweise

- **Kompatibel mit GitHub und Obsidian (Mermaid >=10.4)**  
- `<br/>` wird als Zeilenumbruch unterstützt  
- **IDs stehen immer vor Labels** (z. B. `U11["Text"]`)

---

