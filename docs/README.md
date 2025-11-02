# Zamba AD-DC Playbooks – README

Dieses Repository automatisiert die Bereitstellung von zwei Samba‑basierten Active‑Directory Domain Controllern (Zamba LXC Toolbox) auf Proxmox.

# 🧰 Zamba-AD Automation Playbooks

Diese Dokumentation beschreibt die Aufgaben, Abläufe und Parameter der acht Playbooks,  
die den vollständigen Lebenszyklus der Zamba-basierten Samba-AD-Controller automatisieren.

---

### 🧱 Playbook 01 – `01_destroy_old_dcs.yml`

**Ziel:**  
Saubere Ausgangsbasis durch Entfernen alter oder fehlerhafter DC-Container.  

**Vorgänge:**  
- Stoppen laufender DC-Container (per `pct stop`)  
- Löschen der Container inkl. Netz-Bridges und Volumes  
- Aufräumen temporärer DNS- und Ansible-Dateien  

**Resultat:**  
System ist bereit für Neuinstallation ohne Konflikte.

---

### 🧩 Playbook 02 – `02_create_dc_configs.yml`

**Ziel:**  
Automatische Erstellung neuer Container-Definitionen für die AD-Controller.  

**Vorgänge:**  
- Erzeugen von LXC-Konfigurationsdateien unter `/etc/pve/lxc/`  
- Setzen von Hostnamen, Domain, IP, VLAN und Ressourcenzuweisungen  
- Validierung der Basisumgebung  

**Resultat:**  
Beide DC-Container sind definiert, aber noch nicht gestartet.

---

### ⚙️ Playbook 03 – `03_bootstrap_ad.yml`

**Ziel:**  
Bereitstellung der AD-Domäne inklusive Join des zweiten Controllers.  

**Vorgänge:**  
- Installation von Samba-Paketen und Tools  
- Ausführen von `samba-tool domain provision` auf DC-A  
- Join des zweiten DCs (`samba-tool domain join`)  
- DNS-Bootstrap und Basis-SYSVOL-Struktur  

**Resultat:**  
Fertiges AD-Duo (Primary + Secondary) mit Grundkonfiguration.

---

### 🧠 Playbook 04 – `04_upgrade_and_check.yml`

**Ziel:**  
Systempflege und Funktionsprüfung der DCs.  

**Vorgänge:**  
- `apt update` + `full-upgrade` ohne Interaktion  
- Health-Check von Replikation, SYSVOL und DNS  
- Prüfen von `wbinfo`, `drs showrepl` und `getent`  

**Resultat:**  
Aktualisierte, fehlerfreie DC-Container.

---

### 🌐 Playbook 05 – `05_cross_dns_and_sysvol.yml`

**Ziel:**  
Sicherstellung funktionierender Cross-DNS-Konfiguration zwischen DC-A und DC-B.  

**Vorgänge:**  
- Temporärer Bootstrap-DNS (Cloudflare 1.1.1.1)  
- Setzen von `resolved.conf` oder direkter `resolv.conf`  
- DNS-Tests beider Richtungen (A→B / B→A)  
- Prüfung der SYSVOL-Erreichbarkeit und DRS-Replikation  

**Resultat:**  
Stabile, redundante DNS- und SYSVOL-Verbindung zwischen beiden Controllern.

---

### 🧩 Playbook 06 – `06_sysvol_key_and_rsync.yml`

**Ziel:**  
Sichere Synchronisierung des SYSVOL-Verzeichnisses über SSH.  

**Vorgänge:**  
- Installation von `openssh-client` und `rsync` in beiden DCs  
- Generierung von `id_ed25519` (ohne Passphrase) falls nicht vorhanden  
- Austausch der öffentlichen Keys zwischen DC-A und DC-B  
- Aufbau einer vertrauenswürdigen SSH-Verbindung (`known_hosts`)  
- Rsync des SYSVOL-Verzeichnisses (inkl. Dry-Run-Option)

**Parameter (aus group_vars/all.yml):**  
```yaml
sysvol_path: /var/lib/samba/sysvol
direction: push   # oder pull
dry_run: false    # true = nur Testlauf
```

**Resultat:**  
Einheitlicher SYSVOL-Stand auf beiden DCs, vollautomatisch über SSH synchronisiert.

---

### 🩺 Playbook 07 – `07_ad_health_report.yml`

**Ziel:**  
Erstellung eines strukturierten AD-Gesundheitsberichts für beide DCs.

**Vorgänge:**  
- `samba-tool drs showrepl` → Replikationsstatus  
- `samba-tool dbcheck` → Konsistenzprüfung  
- `host`, `dig`, `wbinfo`, `netlogon` → DNS/Anmelde-Tests  
- Konsolidierung der Ergebnisse in `reports/`

**Dateiablage:**  
```
ansible/playbooks/reports/
├── ad_health_zmb-ad_2025-11-02T12-00.log
└── ad_health_zmb-ad-join_2025-11-02T12-00.log
```

**Resultat:**  
Zentraler Sammelbericht für Monitoring und Debugging.

---

### 🧱 Playbook 08 – `08_snapshot_and_upgrade.yml`

**Ziel:**  
Sicheres Upgrade der AD-Container mit automatischer Snapshot-Erstellung.

**Vorgänge:**  
1. Snapshot vor dem Upgrade (`pre-upgrade`)  
2. System-Upgrade (`apt update && apt full-upgrade`)  
3. Snapshot nach dem Upgrade (`post-upgrade`)  
4. Optionale Prüfung auf laufende Dienste (z. B. Samba)

**Beispielkonfiguration:**  
```yaml
snapshot_prefix: "ad-maint"
perform_upgrade: true
```

**Resultat:**  
Rücksetzbare Upgrade-Prozedur mit vollständiger Versionshistorie und Dokumentation.

## Support
Fragen/Bugs: **info@amazonistan.de**
