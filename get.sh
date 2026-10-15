#!/usr/bin/env bash
# Developer Interface in one line (Linux, macOS, or Git Bash on Windows; Docker must be installed):
#   curl -fsSL https://raw.githubusercontent.com/lotfy2125/developerinterface-install/main/get.sh | bash
#   … | bash -s -- --domain di.acme.com --email it@acme.com    on the internet, with HTTPS
# Downloads the newest install files into ./developerinterface and runs ./install.sh.
set -euo pipefail
export MSYS_NO_PATHCONV=1
REPO="${DI_INSTALL_REPO:-lotfy2125/developerinterface-install}"
DIR="${DI_DIR:-developerinterface}"
if ! command -v docker >/dev/null || ! docker info >/dev/null 2>&1; then
  echo "Docker isn't installed or isn't running."
  echo "  Linux:            curl -fsSL https://get.docker.com | sh"
  echo "  Windows / macOS:  install Docker Desktop (docker.com), start it, then run this again."
  exit 1
fi
mkdir -p "$DIR"
cd "$DIR"
if [ -f .env ]; then
  echo "Developer Interface is already installed in $(pwd). To update it: cd $(pwd) && ./update.sh"
  exit 0
fi
echo "Downloading Developer Interface's install files into $(pwd)…"
curl -fsSL "https://github.com/$REPO/releases/latest/download/developerinterface-install.tar.gz" | tar xz --strip-components=1
chmod +x ./*.sh
exec ./install.sh "$@" </dev/tty
