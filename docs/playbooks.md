# 📘 Playbook-Referenz (Zamba / Proxmox Automation Suite)

**Version:** v1.5  **Stand:** November 2025
**Maintainer:** Stephan Boerner

---

## 🧱 01–03: Setup & Installation

| Nr.    | Playbook                     | Zweck                               | Hauptaufgaben                                            |
| ------ | ---------------------------- | ----------------------------------- | -------------------------------------------------------- |
| **01** | `01_prepare_environment.yml` | Basisumgebung & Verzeichnisstruktur | Vorbereitung von SSH, Ansible-Verzeichnis, lokale Checks |
| **02** | `02_install_dc_primary.yml`  | Installation des ersten Samba-DC    | Provisionierung, DNS-Setup, Basiskonfiguration           |
| **03** | `03_install_dc_join.yml`     | Beitritt des zweiten DC             | Domain Join, Synchronisation, Test der Replikation       |

---

## 🧩 04–06: Replikation & SYSVOL

| Nr.    | Playbook                      | Zweck                  | Hauptaufgaben                                                 |
| ------ | ----------------------------- | ---------------------- | ------------------------------------------------------------- |
| **04** | `04_drs_health_check.yml`     | DRS-Status prüfen      | Führt `samba-tool drs showrepl` und Health Checks aus         |
| **05** | `05_dns_health_check.yml`     | DNS- und SRV-Tests     | Überprüft interne und externe DNS-Auflösung                   |
| **06** | `06_sysvol_key_and_rsync.yml` | SYSVOL Synchronisation | SSH-Key-Verteilung, Rsync (dry-run & real), Known-Hosts Setup |

---

## 🧾 07: Monitoring

| Nr.    | Playbook                  | Zweck                          | Hauptaufgaben                                                                                           |
| ------ | ------------------------- | ------------------------------ | ------------------------------------------------------------------------------------------------------- |
| **07** | `07_ad_health_report.yml` | Erzeugt Markdown-Health-Report | Führt AD-Prüfungen (DRS, DNS, DB-Check, wbinfo) aus, speichert Berichte in `ansible/playbooks/reports/` |

---

## 💾 08–11: Updates & Wartung

| Nr.    | Playbook                         | Zweck                | Hauptaufgaben                                                                                                      |
| ------ | -------------------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **08** | `08_snapshot_and_upgrade.yml`    | Snapshot + Upgrade   | Erstellt Container-Snapshots und führt `apt full-upgrade` durch                                                    |
| **09** | `09_ceph_safe_update.yml`        | Ceph-sicheres Update | Installiert Script & Timer `/usr/local/sbin/ceph-safe-update.sh`, führt wöchentliche Updates nur bei HEALTH_OK aus |
| **10** | `10_pve_auto_upgrades_guard.yml` | Update-Wächter       | Deaktiviert `unattended-upgrades` & `pve-auto-upgrades.timer`, aktiviert stattdessen den Ceph-Safe-Timer           |
| **11** | `11_preupdate_health_gate.yml`   | Health-Gate          | Stoppt APT-Dienste, prüft Locks, validiert Cluster-/Ceph-Status vor Upgrades                                       |

---

## 🔔 12–13: Hooks & Automation

| Nr.    | Playbook                     | Zweck                    | Hauptaufgaben                                                                   |
| ------ | ---------------------------- | ------------------------ | ------------------------------------------------------------------------------- |
| **12** | `12_pre_update_hooks.yml`    | Lokale Hooks ausführen   | Führt ausführbare Dateien in `/etc/ansible/pre_update_hooks/` aus               |
| **13** | `13_post_update_webhook.yml` | Webhook-Benachrichtigung | Sendet JSON-Webhook nach erfolgreichem Update (URI-Modul, reine JSON-Nachricht) |

---

## 📦 14: Backup & Health-Timer

| Nr.     | Playbook                 | Zweck                         | Hauptaufgaben                                                                                                   |
| ------- | ------------------------ | ----------------------------- | --------------------------------------------------------------------------------------------------------------- |
| **13b** | `13_ad_health_timer.yml` | Zeitgesteuerter Health-Report | Systemd-Timer für wöchentliche Ausführung von `07_ad_health_report.yml`                                         |
| **14**  | `14_ad_backup.yml`       | Samba AD Online-Backup        | Führt `samba-tool domain backup online` per Kerberos-Keytab aus, legt Backups unter `/var/backups/samba-ad/` ab |

---

## 🧰 Zusatzdateien

| Datei                                    | Beschreibung                                      |
| ---------------------------------------- | ------------------------------------------------- |
| `ansible/files/ceph-safe-update.sh`      | Script für Ceph-sicheres APT-Update               |
| `ansible/files/ceph-safe-update.service` | Systemd-Service für manuelle Ausführung           |
| `ansible/files/ceph-safe-update.timer`   | Systemd-Timer (So 03:30) für wöchentliche Updates |

---

## 🧭 Abhängigkeiten

| Komponente         | Voraussetzung                                           |
| ------------------ | ------------------------------------------------------- |
| `Ceph-safe Update` | Ceph-CLI installiert & HEALTH_OK                        |
| `AD Backup`        | gültiger Kerberos-Keytab vorhanden (`/etc/krb5.keytab`) |
| `SYSVOL Sync`      | SSH-Schlüsselpaar A ↔ B eingerichtet                    |
| `Webhook`          | Internetzugang und gültige URL                          |
| `Health Report`    | `samba-tool`, `jq`, `dnsutils`, `wbinfo` verfügbar      |

---

## 🧩 Pflege & Entwicklung

```bash
# Neues Playbook anlegen
ansible-playbook --syntax-check ansible/playbooks/<name>.yml

# Dokumentation aktualisieren
git add docs/playbooks.md
git commit -m "docs: update playbook reference"
git push
```

---

📚 *Siehe auch:*

* [`README.md`](../README.md) – Übersicht & Flowchart
* [`CHANGELOG.md`](CHANGELOG.md) – Versionshistorie
