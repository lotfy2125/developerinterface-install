#!/usr/bin/env bash
# Backs up the database (accounts, saved projects, the licence) to backups/developerinterface-<date>.sql.gz
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p backups
f="backups/developerinterface-$(date +%Y%m%d-%H%M%S).sql.gz"
pw=$(grep -E '^DB_ROOT_PASSWORD=' .env | cut -d= -f2-)
docker compose exec -T db mysqldump -u root -p"$pw" --single-transaction --routines developerinterface | gzip > "$f"
echo "Backup: $f"
# Keep the newest 14.
ls -1t backups/developerinterface-*.sql.gz 2>/dev/null | tail -n +15 | xargs -r rm -f
