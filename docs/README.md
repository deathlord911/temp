# Zamba AD-DC Playbooks – README

Dieses Repository automatisiert die Bereitstellung von zwei Samba‑basierten Active‑Directory Domain Controllern (Zamba LXC Toolbox) auf Proxmox.

## Playbooks

### 01_destroy_old_dcs.yml
Optional: Entfernt alte DC‑Container (Stop + Destroy).

### 02_create_dc_configs.yml
Erzeugt `zmb-ad.conf` (erster DC) und `zmb-ad-join.conf` (zweiter DC) für die Toolbox.

### 03_install_dcs_with_toolbox.yml
Installiert beide DC‑Container über die Zamba‑Toolbox (100 = Primary, 101 = Join).

### 04_upgrade_and_check.yml
- Temporäre `resolv.conf` für Internet‑DNS  
- Umstellung auf Debian 13 „Trixie“ (falls nötig)  
- `apt update` / `full-upgrade` **non‑interactive**, Lock‑Handling, `needrestart`‑Auto  
- Health‑Checks: DRS, `wbinfo`, SYSVOL vorhanden etc.  

### 05_cross_dns_and_sysvol.yml
- Cross‑DNS:
  - **mit systemd-resolved:** `/etc/systemd/resolved.conf` (Peer + Fallback)
  - **ohne systemd-resolved:** statische `/etc/resolv.conf` (Peer + Fallback, idempotent)
- Setzt `dns forwarder = 1.1.1.1` in `/etc/samba/smb.conf` (idempotent; Handler‑Restart)
- Tests: Recursion (`dig @127.0.0.1 deb.debian.org A`), DNS via Peer, `getent hosts deb.debian.org`

## Typische Stolpersteine
- APT/DPKG‑Locks → Playbook 04 räumt automatisch auf  
- Fehlende `/etc/resolv.conf` in Minimal‑CTs → Playbook 05 erzeugt sie  
- Samba‑„dns recursive“‑Warnung → unkritisch, Recursion‑Test maßgeblich  

## Support
Fragen/Bugs: **info@amazonistan.de**
