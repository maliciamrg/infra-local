# AGENTS.md

## Scope
This repository contains two distinct infrastructure domains:

- `infra-ubuntu/`: Ubuntu provisioning + Dockerized services (Frigate, Ollama, Paperless-ngx)
- `infra-truenas/`: TrueNAS inventory, audit scripts, and safe documentation

Treat them as separate operational areas. Do not assume one project is a generic app repository.

## Operating rules
- Prefer documentation edits and example configuration files over live secrets.
- Never commit real `.env` files, keys, tokens, or host-specific credentials.
- Keep `.env.example` files as the reference for required variables.
- Do not add destructive commands or automatic modifications to TrueNAS datasets, ZFS pools, SMB shares, ACLs, or snapshots.
- For `infra-truenas/`, favor read-only audit and inventory tasks.
- For `infra-ubuntu/`, prefer idempotent Ansible/Docker Compose changes and clearly documented local overrides.

## Project-specific guidance
### infra-ubuntu
- Ansible configures Ubuntu packages, Docker, and working directories.
- Docker Compose files are split by application under `docker/*/compose.yml`.
- Local service data should remain under `/srv/...` unless explicitly reconfigured.
- Keep PostgreSQL data out of SMB/CIFS paths; `paperless-db` remains local by design.
- When updating compose or env files, preserve example variables and document required secrets.

### infra-truenas
- This project is defensive and audit-oriented.
- Preserve the inventory and report snapshots as static evidence.
- Use `midclt`/SSH read-only flows; do not implement automatic mutation workflows.
- Do not touch protected pools/datasets (`ix-apps`, `.system`, `boot-pool`) without explicit approval.
- Treat previously captured state as observational data, not guaranteed defaults.

## Required behavior for AI changes
- Keep instructions and modifications small and explicit.
- Update README or inline comments only when required by the change.
- If a task adds configuration values, prefer examples or placeholders rather than production secrets.
- Validate the smallest relevant command, such as YAML syntax checks or `docker compose config` when applicable.
- If a change impacts both subprojects, document the distinction and avoid cross-contaminating operational assumptions.

## Safety reminder
This repository is for home-lab infrastructure and safe auditing. Use caution, prefer reversible and non-destructive changes, and avoid assuming a live system can be reset without review.
