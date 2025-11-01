# temp – Proxmox + Zamba AD Infra (Step 1)

Dieses Repo enthält Ansible-Playbooks, um zwei Samba-AD-DCs per zamba-lxc-toolbox zu installieren:

- CT 100: zmb-ad (Primary)
- CT 101: zmb-ad-join (Secondary)

Ablauf (von pve3 aus, SSH-Key-Login):
1) optional alte DCs entfernen
2) DC-Konfigs generieren
3) Toolbox-Installationsläufe starten

```bash
cd /root/temp
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/01_destroy_old_dcs.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/02_create_dc_configs.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/03_install_dcs_with_toolbox.yml
```
