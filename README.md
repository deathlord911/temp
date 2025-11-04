# ⚙️ Zamba / Proxmox Ansible Automation Suite

[![Ansible](https://img.shields.io/badge/Ansible-Automation-blue?logo=ansible\&logoColor=white)](https://www.ansible.com/)
[![Version](https://img.shields.io/badge/v1.5-stable-brightgreen)](docs/CHANGELOG.md)
[![License](https://img.shields.io/badge/Internal-Use%20Only-red)](#-lizenz--nutzung)
[![Platform](https://img.shields.io/badge/Platform-Proxmox%20%7C%20Zamba%20AD-orange)](https://www.proxmox.com/)

**Maintainer:** Stephan Boerner
**Stand:** November 2025
**Version:** v1.5 (latest)

---

## 🧩 Übersicht

Diese Suite automatisiert die Verwaltung einer **Zamba Active Directory Umgebung**
innerhalb eines **Proxmox-Clusters mit Ceph-Speicher**.

Ziel ist ein vollständig reproduzierbares, automatisiertes Setup mit:

* Installation & Betrieb von Samba AD Domain Controllern
* Replikation & Health Monitoring
* Ceph-sicheren Updates
* Backup- und Webhook-Automation

---

## 📁 Struktur

```bash
ansible/
 ├── ansible.cfg
 ├── group_vars/
 │   └── all.yml
 ├── playbooks/
 │   ├── 01_prepare_environment.yml
 │   ├── ...
 │   └── 14_ad_backup.yml
 └── files/
     ├── ceph-safe-update.sh
     ├── ceph-safe-update.service
     └── ceph-safe-update.timer

docs/
 ├── playbooks.md
 └── CHANGELOG.md
```

---

## 🚀 Quickstart

```bash
# Health Report erzeugen
ANSIBLE_CONFIG=ansible/ansible.cfg \
ansible-playbook ansible/playbooks/07_ad_health_report.yml

# Sicheres Cluster-Update
ANSIBLE_CONFIG=ansible/ansible.cfg \
ansible-playbook ansible/playbooks/09_ceph_safe_update.yml

# Online-Backup des AD-Controllers
ANSIBLE_CONFIG=ansible/ansible.cfg \
ansible-playbook ansible/playbooks/14_ad_backup.yml
```

---

## 🧠 Highlights

| Kategorie            | Playbook | Beschreibung                             |
| -------------------- | -------- | ---------------------------------------- |
| 🧱 Installation      | 01–03    | Aufbau & Join der DCs                    |
| 🔁 Replikation & DNS | 04–05    | DRS/DNS Health Checks                    |
| 🗝 SYSVOL Sync       | 06       | Key-Setup & Rsync zwischen DCs           |
| 🧾 Monitoring        | 07       | Markdown Health Report                   |
| 💾 Sicheres Upgrade  | 08–11    | Snapshot, Ceph-Safe Update & Health-Gate |
| 🔔 Automatisierung   | 12–13    | Hooks & Webhook-Notification             |
| 🧩 Backup            | 14       | Online-Backup mit Kerberos-Auth          |

---

## 📚 Dokumentation

📘 **Vollständige Playbook-Referenz:**
➡ [`docs/playbooks.md`](docs/playbooks.md)

🧾 **Änderungsverlauf / Versionshistorie:**
➡ [`docs/CHANGELOG.md`](docs/CHANGELOG.md)

---

## 🔄 Versionen

| Version  | Datum      | Änderungen                       |
| -------- | ---------- | -------------------------------- |
| v1.0     | 2025-10-10 | Grundstruktur, Zamba Setup       |
| v1.2     | 2025-10-20 | SYSVOL-Rsync, Health Report      |
| v1.3     | 2025-10-29 | Dokumentation & Struktur         |
| v1.4     | 2025-11-03 | Webhook, Update-Guard            |
| **v1.5** | 2025-11-04 | AD-Backup, Health-Gate, Ceph-Fix |

---

## 🧩 Lizenz & Nutzung

> © 2025 Stephan Boerner
> Nutzung ausschließlich intern für Kanzlei- und Infrastrukturzwecke
> **Keine Weitergabe oder Veröffentlichung erlaubt**

---

## 🗺️ Playbook-Flow (Übersicht)

*Visualisierte Reihenfolge aller Ansible-Playbooks (01 → 14) in logischer Ausführungsreihenfolge.*

```mermaid
flowchart TD
    subgraph Setup["🧱 Basis Setup"]
        P01["01_prepare_environment"] --> P02["02_install_dc_primary"]
        P02 --> P03["03_install_dc_join"]
    end

    subgraph AD["🧩 Active Directory & Replikation"]
        P03 --> P04["04_drs_health_check"]
        P04 --> P05["05_dns_health_check"]
        P05 --> P06["06_sysvol_sync"]
    end

    subgraph Monitoring["🧾 Monitoring & Reports"]
        P06 --> P07["07_ad_health_report"]
    end

    subgraph Update["💾 Updates & Maintenance"]
        P07 --> P08["08_snapshot_and_upgrade"]
        P08 --> P09["09_ceph_safe_update"]
        P09 --> P10["10_pve_auto_upgrades_guard"]
        P10 --> P11["11_preupdate_health_gate"]
    end

    subgraph Automation["🔔 Automatisierung & Hooks"]
        P11 --> P12["12_pre_update_hooks"]
        P12 --> P13["13_post_update_webhook"]
    end

    subgraph Backup["📦 Backup & Timer"]
        P13 --> P14["14_ad_backup"]
        P14 --> T13["13_ad_health_timer"]
    end

    classDef setup fill:#e0f7fa,stroke:#006064,color:#004d40;
    classDef ad fill:#e8f5e9,stroke:#1b5e20,color:#2e7d32;
    classDef monitor fill:#fff8e1,stroke:#ff6f00,color:#e65100;
    classDef update fill:#ede7f6,stroke:#4a148c,color:#6a1b9a;
    classDef auto fill:#fce4ec,stroke:#880e4f,color:#ad1457;
    classDef backup fill:#f3e5f5,stroke:#4a148c,color:#6a1b9a;

    class P01,P02,P03 setup;
    class P04,P05,P06 ad;
    class P07 monitor;
    class P08,P09,P10,P11 update;
    class P12,P13 auto;
    class P14,T13 backup;
```

---

🧰 *Zamba / Proxmox Automation Suite – designed for reproducible, reliable infrastructure.*
