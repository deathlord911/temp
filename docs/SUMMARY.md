# 📚 Inhaltsverzeichnis – Zamba / Proxmox Automation Suite

**Version:** v1.5  **Stand:** November 2025
**Maintainer:** Stephan Boerner

---

## 🏠 Hauptinhalte

* [Projektübersicht](../README.md)
* [Changelog](CHANGELOG.md)
* [Playbook-Referenz](playbooks.md)

---

## ⚙️ Ansible-Automatisierung

### 🔧 Basis-Setup

1. [`01_prepare_environment.yml`](../ansible/playbooks/01_prepare_environment.yml)
2. [`02_install_dc_primary.yml`](../ansible/playbooks/02_install_dc_primary.yml)
3. [`03_install_dc_join.yml`](../ansible/playbooks/03_install_dc_join.yml)

### 🔁 Replikation & DNS

4. [`04_drs_health_check.yml`](../ansible/playbooks/04_drs_health_check.yml)
5. [`05_dns_health_check.yml`](../ansible/playbooks/05_dns_health_check.yml)

### 🗝 SYSVOL & Health

6. [`06_sysvol_key_and_rsync.yml`](../ansible/playbooks/06_sysvol_key_and_rsync.yml)
7. [`07_ad_health_report.yml`](../ansible/playbooks/07_ad_health_report.yml)

---

## 💾 Updates & Wartung

8. [`08_snapshot_and_upgrade.yml`](../ansible/playbooks/08_snapshot_and_upgrade.yml)
9. [`09_ceph_safe_update.yml`](../ansible/playbooks/09_ceph_safe_update.yml)
10. [`10_pve_auto_upgrades_guard.yml`](../ansible/playbooks/10_pve_auto_upgrades_guard.yml)
11. [`11_preupdate_health_gate.yml`](../ansible/playbooks/11_preupdate_health_gate.yml)

---

## 🔔 Automatisierung & Benachrichtigung

12. [`12_pre_update_hooks.yml`](../ansible/playbooks/12_pre_update_hooks.yml)
13. [`13_post_update_webhook.yml`](../ansible/playbooks/13_post_update_webhook.yml)
    13b. [`13_ad_health_timer.yml`](../ansible/playbooks/13_ad_health_timer.yml)

---

## 🧱 Backup & Recovery

14. [`14_ad_backup.yml`](../ansible/playbooks/14_ad_backup.yml)

---

## 🧰 Zusätzliche Komponenten

| Datei                                                                                 | Zweck                                |
| ------------------------------------------------------------------------------------- | ------------------------------------ |
| [`ansible/files/ceph-safe-update.sh`](../ansible/files/ceph-safe-update.sh)           | Ceph-sicheres APT-Upgrade            |
| [`ansible/files/ceph-safe-update.service`](../ansible/files/ceph-safe-update.service) | Systemd-Service für manuelles Update |
| [`ansible/files/ceph-safe-update.timer`](../ansible/files/ceph-safe-update.timer)     | Wöchentlicher Timer (So 03:30)       |

---

📖 *Diese Übersicht bildet die offizielle Navigationsstruktur der Dokumentation (GitHub-kompatibel und Obsidian-fähig).*
