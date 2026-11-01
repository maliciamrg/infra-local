# GitHub Copilot instructions

This repository manages home-lab infrastructure and should be treated as a safe, documentation-first deployment project.

## High-level guidance
- Keep the two subprojects separate: `infra-ubuntu/` and `infra-truenas/`.
- Do not commit real secrets or local environment files.
- Prefer `.env.example` patterns and placeholders over live values.
- Avoid destructive operations against TrueNAS storage or network shares.

## For `infra-ubuntu/`
- Favor Ansible and Docker Compose files that are idempotent and reproducible.
- Preserve local `/srv/...` layouts unless the user explicitly requests a change.
- Keep app configurations isolated per service (`frigate`, `ollama`, `paperless`).
- Validate YAML/Compose structure when editing deployment files.

## For `infra-truenas/`
- This is read-only audit and inventory work by default.
- Do not propose or implement automatic dataset, pool, or ACL changes.
- Treat snapshots and reports as evidence, not source of truth for mutating actions.
- Avoid modifying protected systems or datasets without explicit authorization.

## Safety rules
- Never insert real credentials into code, docs, or examples.
- Prefer generic configuration examples and explicit warnings.
- If a change could affect production behavior, explain the risk and the minimal safe option.

## Preferred workflow
1. Inspect the relevant subproject and file scope.
2. Make the smallest safe change.
3. Validate with the narrowest relevant check.
4. Keep documentation aligned with changed behavior.
