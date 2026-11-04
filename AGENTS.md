# AGENTS.md

## Scope
This repository contains two distinct infrastructure domains managed from one
root-level Ansible project:

- `ansible/`: shared inventory, ordered playbooks, templates, and collections
- `docker/`: Ubuntu Compose services (Frigate, Ollama, Paperless-ngx)

Treat TrueNAS and Ubuntu as separate operational areas. TrueNAS plays must
target only the `truenas` inventory group; Ubuntu plays must target only
`ubuntu`. Keep their workflow order: TrueNAS backup, maintenance, audit;
Ubuntu install, then application deployment.

## Operating rules
- Prefer documentation edits and example configuration files over live secrets.
- Never commit real `.env` files, keys, tokens, or host-specific credentials.
- Keep `.env.example` files as the reference for required variables.
- Do not add destructive commands or automatic modifications to TrueNAS datasets, ZFS pools, SMB shares, ACLs, or snapshots.
- Favor read-only TrueNAS audit and inventory tasks. The maintenance playbook
  can create datasets and shares and enable/start services, so review and obtain
  explicit authorization before running or changing it.
- Prefer idempotent Ubuntu Ansible/Docker Compose changes and clearly
  documented local overrides.

## Ubuntu and Docker guidance
- Ansible configures Ubuntu packages, Docker, and working directories.
- Docker Compose files are split by application under `docker/*/compose.yml`.
- Local service data should remain under `/srv/...` unless explicitly reconfigured.
- Keep PostgreSQL data out of SMB/CIFS paths; `paperless-db` remains local by design.
- When updating compose or env files, preserve example variables and document required secrets.

## TrueNAS guidance
- This project is defensive and audit-oriented.
- Preserve the inventory and report snapshots as static evidence.
- Use `midclt`/SSH read-only flows for audit. Do not add automatic mutation
  workflows beyond explicitly authorized maintenance tasks.
- Do not touch protected pools/datasets (`ix-apps`, `.system`, `boot-pool`) without explicit approval.
- Treat previously captured state as observational data, not guaranteed defaults.

## Required behavior for AI changes
- Keep instructions and modifications small and explicit.
- Update README or inline comments only when required by the change.
- If a task adds configuration values, prefer examples or placeholders rather than production secrets.
- Validate the smallest relevant command, such as YAML syntax checks or `docker compose config` when applicable.
- If a change impacts both infrastructure domains, document the distinction and avoid cross-contaminating operational assumptions.

## Safety reminder
This repository is for home-lab infrastructure and safe auditing. Use caution, prefer reversible and non-destructive changes, and avoid assuming a live system can be reset without review.
