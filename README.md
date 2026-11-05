# Home-lab infrastructure

This repository keeps the TrueNAS and Ubuntu automation in one Ansible project
while keeping their host-specific playbooks and tasks separate.

## Repository layout

- `ansible/` contains the shared inventory, playbooks, templates, and required
  Ansible collections.
- `docker/` contains the Frigate, Ollama, and Paperless Compose projects and
  their example environment files.

## Host separation and run order

The shared inventory defines three host groups:

- `truenas`: runs only the TrueNAS backup, maintenance, and audit playbooks.
- `ubuntu`: runs only the Ubuntu install and application-deployment playbooks.
- `3d_printer`: runs only the Klipper, Moonraker, and Mainsail playbook.

The combined `site.yml` runs all six playbooks in this order:

1. TrueNAS backup
2. TrueNAS maintenance
3. TrueNAS audit
4. Ubuntu install
5. Ubuntu application deployment
6. 3D printer setup

Each playbook targets only its corresponding inventory group. The 3D printer
has its own inventory entry and does not receive the TrueNAS or Ubuntu plays.

## Configure and run

Install Ansible and the collections declared by this project:

```bash
ansible-galaxy collection install -r ansible/requirements.yml
```

Create the local inventory from the example (do this only if
`ansible/inventory/hosts.yml` does not already exist), then edit it with the
correct SSH details for the TrueNAS, Ubuntu, and printer hosts:

```bash
cp ansible/inventory/hosts.example.yml ansible/inventory/hosts.yml
```

From the repository root, run the complete workflow:

```bash
ansible-playbook ansible/playbooks/site.yml --ask-vault-pass
```

The Ubuntu install playbook loads
`ansible/group_vars/ubuntu-server/vault.yml`; Ansible prompts for its Vault
password. Keep local inventory and plaintext credentials out of Git. Use
Ansible Vault for secrets. Update the SSH user and address for all three hosts,
including `colossus`, before running the combined playbook.

## Operational safety

Review the inventory and the TrueNAS maintenance playbook before running the
full workflow. Maintenance can create datasets and shares and enable or start
SMB/NFS services. The preceding inventory backup and following audit do not
make those changes reversible.

The Ubuntu deployment playbook currently copies the Compose files to the
Ubuntu host; starting Frigate remains disabled by default. Review each
application's `.env.example` and Compose configuration before deploying.
Keep application data under `/srv` as configured, and keep Paperless
PostgreSQL data off SMB/CIFS storage.

The printer playbook installs the software but does not create a
machine-specific `printer.cfg`. Add the correct configuration at
`/home/klipper/printer_data/config/printer.cfg` on the printer, including its
MCU serial path. Klipper will remain stopped until that file exists; rerun the
playbook after adding it. Moonraker is configured for the `lan_subnet` in
`ansible/group_vars/3d_printer.yml`; keep the printer on a trusted LAN and do
not expose its web interface or API directly to the internet.
