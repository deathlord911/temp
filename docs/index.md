# Zamba AD-DC Deployment – Übersicht

Diese Doku beschreibt das automatisierte Setup der beiden Samba AD‑DCs (Zamba LXC Toolbox) auf Proxmox sowie die zugehörigen Playbooks:

- **01_destroy_old_dcs.yml** – optional: alte DC‑Container bereinigen  
- **02_create_dc_configs.yml** – Konfigurationsdateien generieren  
- **03_install_dcs_with_toolbox.yml** – DCs via Toolbox installieren  
- **04_upgrade_and_check.yml** – Debian 13 Upgrade & Health‑Checks  
- **05_cross_dns_and_sysvol.yml** – Cross‑DNS, Forwarder, SYSVOL‑Basics  

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
