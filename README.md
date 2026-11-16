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

The Ubuntu deployment playbook copies the Compose files to the Ubuntu host and
seeds `/srv/frigate/config/config.yml` from its example without replacing a
local config. Frigate is configured for the four listed cameras, with NVIDIA
GPU decoding and TensorRT-backed detection for an RTX 4060. Detection requires
a compatible ONNX model at `/srv/frigate/config/model_cache/yolo.onnx`; install
NVIDIA drivers and the NVIDIA Container Toolkit on Ubuntu first. Follow the
[Frigate ONNX detector guide](https://docs.frigate.video/configuration/object_detectors/#onnx)
to prepare a compatible model.

The Ubuntu install playbook can install the recommended NVIDIA driver and
NVIDIA Container Toolkit and configure Docker's NVIDIA runtime. This is
disabled by default; enable it explicitly with:

```bash
ansible-playbook ansible/playbooks/install.yml --limit ubuntu --ask-vault-pass -e install_nvidia_container_toolkit=true
```

This runs the Ubuntu install playbook, including its existing package and
network-share setup. Docker is restarted if its NVIDIA runtime configuration
changes. The playbook does not reboot the host; reboot Ubuntu manually if the
new driver is not active after installation.

Before deploying, create `/opt/infra-ubuntu/docker/frigate/.env` from
`.env.example`, set each camera's account credentials, and URL-encode special
characters in passwords. Then enable Frigate explicitly:

```bash
ansible-playbook ansible/playbooks/deploy-apps.yml --limit ubuntu -e deploy_frigate=true
```

The camera URLs in the config use RTSP, not the cameras' HTTPS administration
pages. Verify RTSP is enabled and test the stream paths for each camera; paths
can vary by camera firmware or settings. The initial recording policy retains
motion recordings for seven days. Review it and each application's
`.env.example` and Compose configuration before deploying. Keep application
data under `/srv` as configured, and keep Paperless PostgreSQL data off
SMB/CIFS storage.

If neither config exists, the printer playbook creates an incomplete starter
`printer.cfg` using `printer_serial` from
`ansible/group_vars/3d_printer.yml`; it does not guess the printer's hardware
settings. Fill in and verify the exact machine configuration at
`/home/klipper/printer_data/config/printer.cfg`. An existing file is preserved;
if a legacy config exists at
`/root/printer_data/config/printer.cfg`, the playbook copies it to the new
location. Set `printer_config_approved: true` in
`ansible/group_vars/3d_printer.yml` only after verifying the file for this
printer. The default is false, so Klipper and Moonraker remain stopped and
disabled until the config is approved and the playbook is rerun. Moonraker
listens on localhost only and is reached through the Mainsail Nginx proxy.
Restrict web access to the trusted LAN using the host/network firewall; do not
expose the interface to the internet.
