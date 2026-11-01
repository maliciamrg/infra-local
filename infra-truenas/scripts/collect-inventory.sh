#!/usr/bin/env bash
set -euo pipefail

# À exécuter localement sur TrueNAS. Lecture seule.
# Les résultats peuvent contenir des détails internes : ne pas les publier
# sans vérification et ne pas les committer automatiquement.

if ! command -v midclt >/dev/null 2>&1; then
  echo "Erreur : midclt introuvable. Exécute ce script sur TrueNAS." >&2
  exit 1
fi

run_query() {
  local label="$1"
  local method="$2"
  printf '\n===== %s (%s) =====\n' "$label" "$method"
  midclt call "$method"
}

run_query "Pools" "pool.query"
run_query "Datasets ZFS" "pool.dataset.query"
run_query "Partages SMB" "sharing.smb.query"
run_query "Disques" "disk.query"

printf '\n===== État ZFS =====\n'
zpool status

printf '\n===== Capacité des datasets =====\n'
zfs list -o name,used,avail,mountpoint
