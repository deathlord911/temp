
# 🛠️ Operations Handbook

**Version:** v1.6  
**Stand:** November 2025  
**Gültig für:** `Proxmox Cluster + Zamba AD + Ansible Playbooks 10–15`

---

## 📘 Übersicht

Dieses Dokument beschreibt den technischen Ablauf und die manuelle Nutzung aller operativen Playbooks, die zur Wartung und Stabilisierung des Systems dienen.  
Sie decken ab:

- **APT/Upgrade-Kontrolle**  
- **Ceph-Safety-Timer**  
- **Pre/Post-Update-Hooks & Webhooks**  
- **Active Directory-Health & Backup**  
- **Wartungs-Gate für Ceph/APT/AD**

---

## 🔢 Playbook-Reihenfolge

| # | Playbook | Zweck | Trigger |
|:-:|:--|:--|:--|
| 10 | `10_pve_auto_upgrades_guard.yml` | Deaktiviert PVE-Auto-Upgrades & Unattended Upgrades; aktiviert Ceph-Safe-Timer | einmalig oder nach PVE-Update |
| 11 | `11_preupdate_health_gate.yml` | Prüft, ob Ceph/Cluster vor Update stabil ist | manuell vor Upgrade |
| 12 | `12_pre_update_hooks.yml` | Führt lokale Skripte vor Updates aus (z. B. Backup, Snapshot) | optional |
| 13 | `13_post_update_webhook.yml` | Sendet JSON-Webhook nach erfolgreichem Update | optional |
| 14 | `14_ad_backup.yml` | Erstellt Online-Backup des AD (Container 100) | via Cron oder manuell |
| 15 | `15_maintenance_verify.yml` | Führt Gesamt-Health-Check (Ceph + APT + AD + Backups) durch | via `maintenance_check.sh` oder Cron |

---

## 🧩 Zentrale Komponenten

| Komponente | Zweck | Status prüfen |
|:--|:--|:--|
| `ceph-safe-update.timer` | Serielle, sichere Upgrades im Cluster | `systemctl list-timers | grep ceph-safe` |
| `pve-auto-upgrades.timer` | Muss **deaktiviert** sein | `systemctl is-enabled pve-auto-upgrades.timer` |
| `unattended-upgrades.service` | Muss **maskiert** sein | `systemctl status unattended-upgrades` |
| `AD Backup (LXC 100)` | Sicherung unter `/backup/samba-ad/` | `ls -lh /backup/samba-ad` |
| `AD Health Report` | Markdown-Berichte in `ansible/playbooks/reports/` | `ls -lh ansible/playbooks/reports/ad-health-*` |

---

## ⚙️ Regelmäßige Aufgaben

### 1️⃣ AD-Health-Check manuell

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg \
ansible-playbook ansible/playbooks/07_ad_health_report.yml
```

→ erstellt Bericht `ad-health-YYYYMMDD-HHMMSS.md`

---

### 2️⃣ AD-Backup manuell

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg \
ansible-playbook ansible/playbooks/14_ad_backup.yml \
  -e 'do_rsync=false keep=7 backup_dir=/backup/samba-ad'
```

→ erzeugt Backup `samba-backup-<domain>-<timestamp>.tar.bz2`

---

### 3️⃣ Vollständige Maintenance-Prüfung

```bash
/root/temp/ansible/scripts/maintenance_check.sh
```

oder direkt:

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg \
ansible-playbook ansible/playbooks/15_maintenance_verify.yml
```

→ Ergebnis: `maintenance-YYYYMMDD-HHMMSS.md`  
→ Bei Fehlern wird `fatal: Maintenance Gate failed: <n> issues` ausgegeben.

---

## 🩺 Interpretation des Maintenance-Reports

### Abschnitt `## Issues`
Liste aller erkannten Abweichungen (Timer, Locks, AD, Ceph usw.)

Beispiel:
```text
## Issues (2)
- pve-auto-upgrades.timer is enabled (should be disabled)
- APT lock files present: /var/lib/dpkg/lock ...
```

### Abschnitt `## Details`
Zeigt für jede geprüfte Kategorie die ausführliche Diagnose (Systemctl-Ausgaben, AD-DRS-Status, letzte Backups, Ceph-Health JSON).

---

## 📈 Logs & Reports

| Typ | Speicherort | Beschreibung |
|:--|:--|:--|
| AD-Health | `ansible/playbooks/reports/ad-health-*.md` | Ergebnisse von Playbook 07 |
| AD-Backup | `/backup/samba-ad/` | Archivierte Online-Backups |
| Maintenance-Gate | `ansible/playbooks/reports/maintenance-*.md` | Gesamtauswertung Ceph/APT/AD |
| Cron-Logs | `ansible/playbooks/reports/cron-*.log` | Logrotation via Cron |

---

## 🧾 Git-Workflow

Alle Änderungen an Playbooks oder Scripts:

```bash
cd /root/temp
git add ansible/playbooks/... ansible/scripts/...
git commit -m "fix(...): <Beschreibung>"
git push
```

→ Repository: [github.com/deathlord911/temp](https://github.com/deathlord911/temp)

---

## ✅ Wartungs-Ziel

Ein **grüner Gate-Report** zeigt:
- kein aktiver oder aktivierter Auto-Upgrade-Timer  
- keine APT-Locks  
- saubere Ceph-Health (`HEALTH_OK`)  
- letzter AD-Backup < 7 Tage  
- DRS & NETLOGON OK  

Ergebnis:

```
PLAY RECAP ********************************************************************
localhost : ok=XX changed=0 failed=0
Maintenance Gate passed: 0 issues.
```

---

**Letzter Stand:**  
Alles getestet (v1.6) – *Maintenance-Gate green ✅, AD-Backup stable, Reports valid.*

```
© 2025 – Ops Framework by Stephan Boerner
```
