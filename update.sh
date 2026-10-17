#!/usr/bin/env bash
# Update Developer Interface: backs up first, then downloads and starts the new version.
#   ./update.sh            the newest version (downloads its install files too; .env and backups stay)
#   ./update.sh 2.1.0      a given version (saved in .env)
#   ./update.sh --image-file developerinterface-2.1.0.tar   from a file (servers without internet)
set -euo pipefail
export MSYS_NO_PATHCONV=1
cd "$(dirname "$0")"
# All in one function, so bash has read it whole before the newest install files replace this script.
main() {
[ -f .env ] || { echo "No .env here: run ./install.sh first."; exit 1; }
FILE=""
if [ "${1:-}" = "--image-file" ]; then FILE="$2"; shift 2; fi
set_version() { sed -i.bak "s/^DI_VERSION=.*/DI_VERSION=$1/" .env && rm -f .env.bak; }
if [ -n "${1:-}" ]; then
  set_version "$1"
elif [ -z "$FILE" ]; then
  # The newest release: its install files (compose file and these scripts) and its version. Your .env and backups stay.
  REPO="${DI_INSTALL_REPO:-lotfy2125/developerinterface-install}"
  TMP=$(mktemp -d)
  if curl -fsSL "https://github.com/$REPO/releases/latest/download/developerinterface-install.tar.gz" | tar xz -C "$TMP" --strip-components=1; then
    NEW=$(grep -E '^DI_VERSION=' "$TMP/.env.example" | cut -d= -f2-)
    OLD=$(grep -E '^DI_VERSION=' .env | cut -d= -f2-)
    rm -f "$TMP/.env"
    cp -R "$TMP"/. .
    chmod +x ./*.sh
    if [ -n "$NEW" ]; then set_version "$NEW"; echo "Version: ${OLD:-?} -> $NEW"; fi
  else
    echo "Couldn't download the newest install files; updating to the version in .env (${DI_VERSION:-$(grep -E '^DI_VERSION=' .env | cut -d= -f2-)})."
  fi
  rm -rf "$TMP"
fi
echo "Backing up first…"
./backup.sh
if [ -n "$FILE" ]; then docker load -i "$FILE"; else docker compose pull; fi
docker compose up -d
docker image prune -f >/dev/null
echo "Updated. The database is brought up to date when the app starts (docker compose logs app)."
}
main "$@"
exit
