# 🧾 CHANGELOG – Zamba / Proxmox Automation Suite

**Maintainer:** Stephan Boerner
**Stand:** November 2025
**Repository:** `deathlord911/temp`

---

## 🧱 v1.0 – Initial Setup (2025-10-10)

**Erstveröffentlichung der Suite**

* Grundstruktur für Ansible (`ansible/`, `docs/`)
* Basis-Playbooks 01 – 03 (Setup und Join der Domain Controller)
* Einführung von `group_vars/all.yml` mit Cluster-Variablen
* Einrichtung von SSH-Kommunikation und Umgebungs-Bootstrap

---

## 🔁 v1.1 – Replikation & Health (2025-10-14)

* Playbooks 04 & 05 für DRS- und DNS-Health Check
* Integration von `samba-tool drs showrepl`, `wbinfo` und `dig`-Tests
* Erste Markdown-Reports unter `reports/`

---

## 🗝 v1.2 – SYSVOL Sync & Health Report (2025-10-20)

* Playbooks 06 – 08

  * `06_sysvol_key_and_rsync.yml`: SSH-Key-basierter SYSVOL-Sync
  * `07_ad_health_report.yml`: Markdown-Health-Report
  * `08_snapshot_and_upgrade.yml`: VM/CT-Snapshots + Upgrade
* `group_vars/all.yml` um Report- und Rsync-Parameter ergänzt
* `docs/playbooks.md` angelegt

---

## 💾 v1.3 – Docs & Refactoring (2025-10-29)

* Neue Dokumentationsstruktur unter `docs/`
* Konsolidierte Playbook-Übersichten 01–08
* Syntax-Checks und idempotente Handler
* Markdown-Linting für GitHub-Anzeige

---

## 🧩 v1.4 – Webhook & Ops Automation (2025-11-03)

* Playbooks 09 – 13 hinzugefügt:

  * `09_ceph_safe_update.yml`: Ceph-sicheres Update mit Timer (`So 03:30`)
  * `10_pve_auto_upgrades_guard.yml`: Deaktiviert unattended Upgrades / PVE-Timer
  * `11_preupdate_health_gate.yml`: APT/Ceph-Health-Gate vor Upgrades
  * `12_pre_update_hooks.yml`: Lokale Hook-Verarbeitung
  * `13_post_update_webhook.yml`: Webhook via URI-Modul (ersetzt Shell-Variante)
* `files/ceph-safe-update.*` neu angelegt (Script + Systemd Units)
* `docs/README.md` entfernt → neues Root-README mit Mermaid-Flow

---

## 🧠 v1.5 – AD Backup & Health-Timer (2025-11-04)

* Playbook `14_ad_backup.yml` – Samba AD-Online-Backup mit Kerberos-Keytab
* Playbook `13_ad_health_timer.yml` – wöchentlicher Health-Report-Timer
* Robuste `ceph-safe-update.sh` (Health-Prüfung per JSON)
* Erweiterte `11_preupdate_health_gate.yml` mit Lock-Cleanup
* Neues `README.md` mit Badges und Mermaid-Diagramm
* Neue `docs/playbooks.md` (kompakte Referenz aller Playbooks)

---

## 🔖 Tag-Übersicht

| Tag    | Datum      | Inhalt                           |
| ------ | ---------- | -------------------------------- |
| `v1.0` | 2025-10-10 | Initial release                  |
| `v1.1` | 2025-10-14 | Health & Replication             |
| `v1.2` | 2025-10-20 | SYSVOL Sync + Reports            |
| `v1.3` | 2025-10-29 | Docs + Refactoring               |
| `v1.4` | 2025-11-03 | Webhook + Ops Automation         |
| `v1.5` | 2025-11-04 | Backup + Health-Timer + Ceph Fix |

---

🧰 *Zamba / Proxmox Automation Suite – Change History v1.0 → v1.5 (Stand November 2025)*
