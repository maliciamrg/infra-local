# Ansible — Ender 3X / Klipper / Moonraker / Mainsail

Installation native Ubuntu sous `/home/klipper`. Aucun flash MCU n'est effectué.

## Préparation
- Confirmer que `/root/backup-klipper-20261106-004712.tar.gz` existe.
- Adapter `group_vars/3d_printer.yml`, surtout `moonraker_lan_subnet` (valeur initiale `192.168.1.0/24`, à vérifier).
- L'inventaire est configuré pour exécuter Ansible directement sur colossus (`ansible_connection=local`).

Installer Ansible si nécessaire : `sudo apt update && sudo apt install -y ansible`

## Vérification et exécution
```bash
cd ansible-3d-printer
ansible 3d_printer -m ping
ansible-playbook --syntax-check playbooks/site.yml
ansible-playbook playbooks/site.yml
```

## Accès après déploiement
- Mainsail : `http://IP_DE_COLLOSSUS/`
- Moonraker : `http://IP_DE_COLLOSSUS:7125` (LAN uniquement)

Vérifier :
```bash
systemctl status klipper moonraker nginx --no-pager
journalctl -u klipper -u moonraker -n 80 --no-pager
```

## Précautions
- Le playbook copie l'ancien printer.cfg en `printer.cfg.before-ansible` et ne supprime pas `/root/printer_data`.
- Il reprend le fichier `mainsail.cfg` existant s'il est présent.
- Contrôler axes, endstops, températures et sens des mouvements avant impression.
- Le Z-offset et la première couche restent à calibrer manuellement. Ne pas lancer d'impression sans contrôle.
- Ne pas exposer le port Moonraker 7125 sur Internet.
- Cette version ne migre ni gcodes ni historiques, et n'installe pas Frigate.
