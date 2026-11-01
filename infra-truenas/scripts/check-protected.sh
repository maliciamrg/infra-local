#!/usr/bin/env bash
set -euo pipefail

# Contrôle informatif uniquement : ne modifie rien.
protected=(
  "BigBoy/ix-apps"
  "Ssd1to/ix-apps"
  "Ssd1to/.system"
  "DataSafe/paperless-postgres"
)

for dataset in "${protected[@]}"; do
  if zfs list -H -o name "$dataset" >/dev/null 2>&1; then
    printf 'OK      %s\n' "$dataset"
  else
    printf 'ABSENT  %s\n' "$dataset"
  fi
done

for pool in boot-pool; do
  if zpool list -H -o name "$pool" >/dev/null 2>&1; then
    printf 'PROTÉGÉ %s\n' "$pool"
  else
    printf 'ABSENT  %s\n' "$pool"
  fi
done
