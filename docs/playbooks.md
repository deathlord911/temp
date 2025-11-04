# 🧩 Ansible Playbook Suite – Zamba / Proxmox Automation

**Stand:** November 2025
**Version:** v1.4 → v1.5 (in Entwicklung)
**Maintainer:** Stephan Boerner

---

## 📘 Zweck

Diese Playbook-Sammlung automatisiert das Management einer **Zamba Active Directory Umgebung**
in Verbindung mit einem **Proxmox-Cluster (Ceph Storage)**.
Sie deckt den vollständigen Lebenszyklus ab – von Installation über Health-Checks bis Backup und Upgrades.

---

## 🗂 Struktur

```bash
ansible/
 ├── ansible.cfg
 ├── group_vars/
 │   └── all.yml
 ├── playbooks/
 │   ├── 01_prepare_environment.yml
 │   ├── 02_install_zamba.yml
 │   ├── 03_join_domain.yml
 │   ├── 04_replicate_drs.yml
 │   ├── 05_dns_health.yml
 │   ├── 06_sysvol_key_and_rsync.yml
 │   ├── 07_ad_health_report.yml
 │   ├── 08_snapshot_and_upgrade.yml
 │   ├── 09_ceph_safe_update.yml
 │   ├── 10_pve_auto_upgrades_guard.yml
 │   ├── 11_preupdate_health_gate.yml
 │   ├── 12_pre_update_hooks.yml
 │   ├── 13_post_update_webhook.yml
 │   ├── 14_ad_backup.yml
 │   └── reports/.gitkeep
 └── files/
     ├── ceph-safe-update.sh
     ├── ceph-safe-update.service
     └── ceph-safe-update.timer
```

---

## ⚙️ Globale Variablen (`group_vars/all.yml`)

| Variable                                                      | Beschreibung                                          |
| ------------------------------------------------------------- | ----------------------------------------------------- |
| `dc_a`, `dc_b`                                                | Container-IDs oder Hostnamen der Domain Controller    |
| `sysvol_path`                                                 | Pfad zum SYSVOL-Verzeichnis (`/var/lib/samba/sysvol`) |
| `backup_dir`                                                  | Zielpfad für AD-Backups (`/var/backups/samba-ad`)     |
| `direction`                                                   | Sync-Richtung für SYSVOL (`push` oder `pull`)         |
| `dry_run`                                                     | Nur Testlauf bei Rsync                                |
| `reports_dir`                                                 | Pfad für generierte Reports                           |
| `updates.gate.apt_lock_timeout`                               | Timeout für APT-Lock-Check                            |
| `webhook_url`, `webhook_method`, `webhook_headers`, `message` | Optionen für Webhook-Playbook                         |

---

## 🧩 Playbooks

### **01_prepare_environment**

Basis-Vorbereitung: Pakete, SSH-Zugang, Verzeichnisstruktur, Dependencies.

### **02_install_zamba**

Installation und Basiskonfiguration des ersten Zamba Domain Controllers (AD DC).

### **03_join_domain**

Einbindung eines zweiten DC in die bestehende AD-Domäne (Replikationspartner).

### **04_replicate_drs**

Test und Validierung der AD-Replikation (`samba-tool drs showrepl`, `ldapcmp`).

### **05_dns_health**

Überprüfung des DNS-Subsystems:

* Forward/Reverse-Lookups
* interner Samba-DNS-Status
* Vergleich der Zonen zwischen DCs

---

### **06_sysvol_key_and_rsync**

Synchronisation des SYSVOL-Inhalts über SSH + Rsync:

1. SSH-Key-Paare (ed25519) erstellen
2. gegenseitigen Keyaustausch automatisieren
3. `known_hosts` pflegen
4. Rsync je nach `direction` ausführen

---

### **07_ad_health_report**

Automatisierter Systembericht:

* `samba-tool drs showrepl`
* `samba-tool dbcheck --cross-ncs`
* `wbinfo -t`
* `host`/`dig` DNS-Checks
  Ergebnis als Markdown unter `ansible/playbooks/reports/`.

---

### **08_snapshot_and_upgrade**

* Erstellt LXC-Snapshots via `pct snapshot`
* Führt `apt update && apt full-upgrade` aus
* Post-Snapshot nach erfolgreichem Upgrade
* Rollback-Hinweise werden protokolliert

---

### **09_ceph_safe_update**

Sicheres Update mit Cluster-Awareness:

**Mechanismus:**

* Script `/usr/local/sbin/ceph-safe-update.sh`
* prüft `ceph status --format json`
* führt APT-Upgrade nur bei `HEALTH_OK` durch
* schreibt Logeinträge über `logger`

**Systemd Integration:**

* `ceph-safe-update.service`
* `ceph-safe-update.timer` (Sonntag 03:30 Uhr)

---

### **10_pve_auto_upgrades_guard**

Deaktiviert PVE-/Debian-Autoupdate-Mechanismen:

* `unattended-upgrades`
* `apt-daily*`
* `pve-auto-upgrades`
  Aktiviert und prüft stattdessen den `ceph-safe-update.timer`.

---

### **11_preupdate_health_gate**

Sperrt Upgrades bei ungünstigen Bedingungen:

* prüft APT/Dpkg-Locks
* stoppt automatische Upgrades
* bricht bei Ceph- oder Lock-Problemen kontrolliert ab
  → sorgt dafür, dass Updates nur bei stabilem System laufen.

---

### **12_pre_update_hooks**

Führt lokale Pre-Hooks aus:

```
/etc/ansible/hooks/pre-update.d/*
```

z. B. für Backups, Notifications, Systemflags.

---

### **13_post_update_webhook**

Benachrichtigt nach Updates via Webhook (JSON über `uri`):

```bash
ansible-playbook ansible/playbooks/13_post_update_webhook.yml \
  -e 'webhook_url=https://example.com/hook message="Update OK"'
```

**Beispiel-Payload:**

```json
{
  "host": "pve3.amazonistan.intranet",
  "message": "Update OK on pve3",
  "time": "2025-11-03T23:59:00+01:00"
}
```

Mit Headern:

```bash
-e 'webhook_headers={"X-Token":"abc123","X-Env":"prod"}'
```

---

### **14_ad_backup**

Online-Backup des Samba AD über Kerberos-Authentifizierung:

**Kernbefehl:**

```bash
samba-tool domain backup online \
  --server="zmb-ad.amazonistan.intranet" \
  --targetdir="/var/backups/samba-ad" \
  --use-krb5-ccache=/root/ccache
```

**Voraussetzungen:**

* Host-Keytab `/etc/krb5.keytab`
* Kerberos-Ticket `zmb-ad$@REALM`
* mind. 2 GB RAM + 1 GB Swap

**Ergebnis:**

```
/var/backups/samba-ad/samba-backup-amazonistan.intranet-YYYY-MM-DDTHH-MM-SS.tar.bz2
```

---

## 🧩 Zusatzdateien

**`ceph-safe-update.sh`**

* führt APT-Upgrade nur bei Ceph `HEALTH_OK` aus
* sichert gegen parallele Läufe (`flock`)
* loggt via `syslog`

**`ceph-safe-update.service`**

```ini
[Unit]
Description=Ceph-safe APT upgrade
After=network-online.target
[Service]
Type=oneshot
ExecStart=/usr/local/sbin/ceph-safe-update.sh
```

**`ceph-safe-update.timer`**

```ini
[Timer]
OnCalendar=Sun *-*-* 03:30:00
Persistent=true
```

---

## 🔄 Empfohlene Reihenfolge

```
01_prepare_environment
02_install_zamba
03_join_domain
04_replicate_drs
05_dns_health
06_sysvol_key_and_rsync
07_ad_health_report
08_snapshot_and_upgrade
09_ceph_safe_update
10_pve_auto_upgrades_guard
11_preupdate_health_gate
12_pre_update_hooks
13_post_update_webhook
14_ad_backup
```

---

## 🧾 Versionen

| Version | Datum      | Änderungen                            |
| ------- | ---------- | ------------------------------------- |
| v1.0    | 2025-10-10 | Grundaufbau (Zamba Setup)             |
| v1.2    | 2025-10-20 | SYSVOL-Rsync, Health Report           |
| v1.3    | 2025-10-29 | Dokumentation & Struktur              |
| v1.4    | 2025-11-03 | Webhook, Auto-Update-Guard            |
| v1.5    | 2025-11-04 | AD-Backup, Health-Gate, Ceph-Safe Fix |

---

> © 2025 Stephan Boerner
> **Lizenz:** intern / nicht zur Weitergabe an Dritte
