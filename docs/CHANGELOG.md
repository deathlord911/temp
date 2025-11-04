# 🧾 CHANGELOG – Zamba / Proxmox Automation Suite

**Repository:** `deathlord911/temp`
**Maintainer:** Stephan Boerner
**Stand:** November 2025

---

## 🧩 v1.5 — Robust AD-Backup & Health-Gate (2025-11-04)

**Neu:**

* `14_ad_backup.yml`:
  → Vollständiges Online-Backup des Zamba AD DC über `samba-tool domain backup online`
  → Nutzt Kerberos-Authentifizierung (`zmb-ad$@REALM`)
  → Sicherung nach `/var/backups/samba-ad`
  → Fehlerhandling, Memory-/Swap-Checks, Keytab-Automation

* `11_preupdate_health_gate.yml`:
  → Wartet auf freie APT/Dpkg-Locks
  → Stoppt Auto-Upgrades & Daily-Timer
  → Bricht bei Ceph- oder Lock-Problemen sauber ab

* `10_pve_auto_upgrades_guard.yml`:
  → Maskiert `unattended-upgrades` & `pve-auto-upgrades.timer`
  → Reaktiviert `ceph-safe-update.timer`

* `12_pre_update_hooks.yml`:
  → Führt lokale Hooks unter `/etc/ansible/hooks/pre-update.d/` aus

**Verbessert:**

* Stabilität beim `ceph-safe-update` (bessere JSON-Health-Checks)
* Memory Limits in Samba AD Backup Playbook angepasst
* Alle Tasks nutzen konsistente Pfadvariablen und Logging-Ausgabe

**Fixes:**

* Keytab-Handling bei Samba Backup korrigiert
* Webhook-Task ohne rekursive Variablen (keine YAML-Heredoc-Probleme mehr)

---

## 🧩 v1.4 — Webhook + Ops Automation (2025-11-03)

**Neu:**

* `13_post_update_webhook.yml`: JSON-basierte Benachrichtigung via `uri` Modul
  → kein Shell-/Heredoc-Parsen
  → Header per `webhook_headers`-Variable setzbar
  → Beispiel:

  ```bash
  -e 'webhook_url=https://example.com/hook message="Update OK"'
  ```

* `10_pve_auto_upgrades_guard.yml`:
  → deaktiviert unbeaufsichtigte Upgrades, aktiviert Ceph-Timer

* `12_pre_update_hooks.yml`:
  → Lauf lokaler Scripts vor Upgrade

**Fixes:**

* Endlosschleife bei rekursivem Template-Aufruf beseitigt

---

## 🧩 v1.3 — Consolidated Documentation (2025-10-29)

**Neu:**

* `docs/playbooks.md`:
  → Vollständige technische Übersicht zu allen Playbooks 01–09
  → Einheitliche Variablen-Referenz (`group_vars/all.yml`)
  → Struktur für CI/CD-Pipeline vorbereitet

**Fixes:**

* Ansible-Kompatibilität (`ansible-core >= 2.16`)
* Shell-Scripts aus Playbooks ausgelagert in `files/`

---

## 🧩 v1.2 — SYSVOL Rsync & AD Health (2025-10-20)

**Neu:**

* `06_sysvol_key_and_rsync.yml`: automatischer Key-Setup + Rsync zwischen DCs
* `07_ad_health_report.yml`: Markdown-Bericht mit DRS-, DNS-, DB-Check
* `08_snapshot_and_upgrade.yml`: Snapshot vor/ nach Upgrade

**Fixes:**

* DRS-Replikationscheck stabilisiert
* DNS Health Report erweitert um Forward-Lookups

---

## 🧩 v1.0 — Initial Release (2025-10-10)

**Inhalt:**

* Basis-Setup für Zamba-AD mit 2 DCs
* DNS, Replikation, Basis-Health
* Proxmox Container-Build-Automation

---

### 📦 Versionen

| Version | Datum      | Hauptfeatures                     |
| ------- | ---------- | --------------------------------- |
| v1.0    | 10.10.2025 | Grundgerüst, Zamba DC Setup       |
| v1.2    | 20.10.2025 | SYSVOL Sync, Health Reports       |
| v1.3    | 29.10.2025 | Doku + Struktur                   |
| v1.4    | 03.11.2025 | Webhook + Ops Automation          |
| v1.5    | 04.11.2025 | AD Backup, Health Gate, Ceph-Safe |

---

> © 2025 Stephan Boerner
> Verwendung ausschließlich für interne Kanzlei- und Infrastrukturzwecke
> Nicht zur Weitergabe an Dritte
