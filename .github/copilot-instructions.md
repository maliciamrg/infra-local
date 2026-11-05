# GitHub Copilot instructions

This repository manages a home lab using one root-level Ansible project and
Docker Compose configurations. Treat it as a safe, documentation-first
deployment project.

## High-level guidance
- Keep host-specific behavior separate within `ansible/`: TrueNAS plays target
  only `truenas`, Ubuntu plays target only `ubuntu`, and printer plays target
  only `3d_printer`.
- Keep the combined playbook order: TrueNAS backup, maintenance, audit, then
  Ubuntu install and application deployment, then 3D printer setup.
- Keep the application Compose projects under root `docker/`, isolated by
  service (`frigate`, `ollama`, `paperless`).
- Do not commit real secrets or local environment files.
- Prefer `.env.example` patterns and placeholders over live values.
- Avoid destructive operations against TrueNAS storage or network shares.

## Ansible and Docker
- Favor Ansible and Docker Compose files that are idempotent and reproducible.
- Preserve local `/srv/...` layouts unless the user explicitly requests a change.
- Keep PostgreSQL data out of SMB/CIFS paths; Paperless's `paperless-db`
  remains local by design.
- Klipper requires an operator-provided, machine-specific `printer.cfg` and
  MCU serial; do not generate hardware settings from assumptions.
- Keep Moonraker restricted to the configured trusted LAN; do not expose its
  API directly to the internet.
- Validate YAML/Compose structure when editing deployment files.

## TrueNAS safety
- Treat TrueNAS inventory and audit as read-only by default.
- The maintenance playbook can create configured datasets and shares and
  enable/start SMB/NFS services; review and obtain explicit authorization
  before running or changing these operations.
- Never add automatic pool or ACL changes, or changes to protected datasets
  (`ix-apps`, `.system`, `boot-pool`) without explicit approval.
- Treat snapshots and reports as evidence, not as the source of truth for
  mutating actions.

## Safety rules
- Never insert real credentials into code, docs, or examples.
- Prefer generic configuration examples and explicit warnings.
- If a change could affect production behavior, explain the risk and the minimal safe option.

## Preferred workflow
1. Inspect the relevant root-level Ansible or Docker scope.
2. Make the smallest safe change.
3. Validate with the narrowest relevant check.
4. Keep documentation aligned with changed behavior.
