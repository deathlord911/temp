# Zamba AD-DC Deployment – Übersicht

Diese Doku beschreibt das automatisierte Setup der beiden Samba AD‑DCs (Zamba LXC Toolbox) auf Proxmox sowie die zugehörigen Playbooks:

# 📚 Ansible Playbook Übersicht

Diese Sammlung automatisiert den Aufbau, die Replikation und die Wartung der Samba-AD-Domänencontroller (Zamba-Toolbox).  
Alle Playbooks sind modular aufgebaut und können einzeln oder sequentiell ausgeführt werden.

---

## 🧱 Playbook 01 – Destroy Old DCs

Bereinigt alte oder fehlerhafte Domain Controller (Container) vor einer Neuinstallation.  
Alle relevanten CTs werden gestoppt, gelöscht und ihre Netz-Bridges entfernt.  
→ Ergebnis: saubere Ausgangsbasis ohne Restkonfigurationen.

---

## 🧩 Playbook 02 – Create DC Configs

Erzeugt frische Container-Definitionen für Zamba-AD-Controller (z. B. zmb-ad, zmb-ad-join).  
Beinhaltet grundlegende Parameter (CT-IDs, Hostnamen, IPs, Ressourcen, VLANs).  
→ Ergebnis: fertige CT-Konfigurationen in `/etc/pve/lxc/` und einsatzbereite AD-Umgebung.

---

## ⚙️ Playbook 03 – Bootstrap AD Deployment

Führt die eigentliche Bereitstellung der Domain Controller durch.  
Installiert notwendige Pakete, richtet DNS und Samba-AD ein, joint DC-B in die bestehende Domäne.  
→ Ergebnis: lauffähiges Samba-AD-Duo (Primary + Secondary).

---

## 🧠 Playbook 04 – Upgrade & Health-Checks

Führt Systemupdates (`apt full-upgrade`) und technische Prüfungen auf beiden DCs aus.  
Überprüft Replikation, SYSVOL-Verfügbarkeit und DNS-Funktionalität.  
→ Ergebnis: sicheres Update und dokumentierter Gesundheitsstatus der Domäne.

---

## 🌐 Playbook 05 – Cross-DNS & SYSVOL Health

Richtet Cross-DNS zwischen beiden DCs ein, prüft die gegenseitige Namensauflösung  
und validiert den Zustand des SYSVOL-Shares.  
→ Ergebnis: stabile, redundante DNS-Konfiguration zwischen zmb-ad und zmb-ad-join.

---

## 🧩 Playbook 06 – SYSVOL Key-Setup & Rsync

Erzeugt SSH-Schlüssel (`id_ed25519`) auf beiden DC-Containern, tauscht die öffentlichen Keys bidirektional aus  
und erlaubt ein vertrauenswürdiges Rsync-Setup für den SYSVOL-Inhalt.  
Optionaler Dry-Run zur Validierung, danach echter Sync via `rsync -a --delete`.  
→ Ergebnis: konsistentes SYSVOL-Verzeichnis zwischen primärem und sekundärem DC.

---

## 🩺 Playbook 07 – AD Health Report

Führt erweiterte Diagnose-Checks für beide AD-DCs aus:  
`drs showrepl`, `dbcheck`, `dns query`, `wbinfo`, `netlogon`.  
Alle Reports werden unter `ansible/playbooks/reports/` gespeichert und mit Timestamp versehen.  
→ Ergebnis: strukturierter Health-Report zur schnellen Zustandsbewertung des Samba-AD-Clusters.

---

## 🧱 Playbook 08 – Snapshot & Upgrade

Automatisiert Snapshots, bevor Updates eingespielt werden:  
1. Snapshot (vor Upgrade)  
2. `apt full-upgrade` + Neustart  
3. Snapshot (nach Upgrade)  
→ Ergebnis: sicheres, reversibles Upgrade mit dokumentierten Wiederherstellungspunkten.

## Voraussetzungen
- Proxmox VE mit lxc‑toolbox (bashclub) auf dem Ziel‑Node  
- CT‑IDs: DC‑A = 100, DC‑B = 101  
- Netzwerk/VLAN/Firewall: CTs haben Internet‑Zugriff  
- Git + Ansible auf dem Proxmox‑Host (Runner)  

## Schnellstart
```bash
cd /root/temp
export ANSIBLE_CONFIG=/root/temp/ansible.cfg
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/01_destroy_old_dcs.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/02_create_dc_configs.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/03_install_dcs_with_toolbox.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/04_upgrade_and_check.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/05_cross_dns_and_sysvol.yml
```

## Support
Fragen/Bugs: **info@amazonistan.de**
