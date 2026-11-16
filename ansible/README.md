# Printer Ansible roles

The printer playbook installs Klipper, Moonraker, and Mainsail on the host in
the `3d_printer` inventory group. It does not flash the MCU or create a printer
hardware configuration.

## Configure and run

From the repository root, set the printer host's SSH details in
`ansible/inventory/hosts.yml` and review `ansible/group_vars/3d_printer.yml`,
including the trusted LAN subnet. Install the collections listed in
`ansible/requirements.yml` with
`ansible-galaxy collection install -r ansible/requirements.yml`, then run:

```bash
ansible-playbook ansible/playbooks/3d-printer.yml --syntax-check
ansible-playbook ansible/playbooks/3d-printer.yml --limit 3d_printer
```

If neither the current nor legacy config exists, the playbook creates a starter
`printer.cfg` containing the configured `printer_serial` and comments for the
missing hardware sections. This is not a complete printer config. Fill in and
verify the exact board and hardware settings, then set
`printer_config_approved: true` in `ansible/group_vars/3d_printer.yml` before
expecting Klipper and Moonraker to start. The approval defaults to false, so
even an existing config is not started without explicit operator approval.
Existing files are preserved. If the legacy
`/root/printer_data/config/printer.cfg` exists and the new path does not, the
playbook copies it to the new path but does not approve or start it.

Mainsail is served by Nginx on port 80. Moonraker listens on localhost only;
access it through Mainsail's Nginx proxy, not directly on port 7125. Restrict
access to the Mainsail web server to the trusted LAN using the host/network
firewall, and do not expose it to the Internet.

Before printing, verify the MCU serial, board and wiring settings, axes,
endstops, temperatures, and movement direction. Calibrate Z-offset and the
first layer manually. The playbook does not migrate gcodes or history.
