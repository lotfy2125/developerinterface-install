#!/usr/bin/env bash
# Restores a backup made by backup.sh:  ./restore.sh backups/developerinterface-20261014-090000.sql.gz
# A backup restored on another server needs that server's own licence (send the activation request from there).
set -euo pipefail
cd "$(dirname "$0")"
[ -f "${1:-}" ] || { echo "Which backup? ./restore.sh backups/<file>.sql.gz"; exit 1; }
pw=$(grep -E '^DB_ROOT_PASSWORD=' .env | cut -d= -f2-)
gunzip -c "$1" | docker compose exec -T db mysql -u root -p"$pw" developerinterface
docker compose restart app
echo "Restored $1."
