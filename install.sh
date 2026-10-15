#!/usr/bin/env bash
# Developer Interface installer: writes .env with fresh secrets and starts everything.
#   ./install.sh                                         this network (office or home), at http://<this server>:8080
#   ./install.sh --domain di.acme.com --email it@acme.com   on the internet at that DNS name, with HTTPS
# Other options: --port 8080  --image NAME  --version TAG  --image-file developerinterface.tar (no internet)
set -euo pipefail
export MSYS_NO_PATHCONV=1
cd "$(dirname "$0")"

DOMAIN="" EMAIL="" PORT=8080 IMAGE="" VERSION="" IMAGE_FILE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --domain) DOMAIN="$2"; shift ;;
    --email) EMAIL="$2"; shift ;;
    --port) PORT="$2"; shift ;;
    --image) IMAGE="$2"; shift ;;
    --version) VERSION="$2"; shift ;;
    --image-file) IMAGE_FILE="$2"; shift ;;
    -h|--help) sed -n '2,6p' "$0"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

say() { printf '\n\033[1m%s\033[0m\n' "$*"; }
secret() { if command -v openssl >/dev/null; then openssl rand -hex "${1:-32}"; else head -c "${1:-32}" /dev/urandom | od -An -tx1 | tr -d ' \n'; fi; }
lan_ip() {
  local ip=""
  case "$(uname -s)" in
    MINGW* | MSYS* | CYGWIN*) ip=$(powershell.exe -NoProfile -Command "(Get-NetIPConfiguration | Where-Object { \$_.IPv4DefaultGateway -ne \$null -and \$_.NetAdapter.Status -eq 'Up' } | Select-Object -First 1).IPv4Address.IPAddress" 2>/dev/null | tr -d '\r ' | head -1) ;;
    Darwin) ip=$(ipconfig getifaddr "$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')" 2>/dev/null || true) ;;
    *) ip=$(ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "src") print $(i + 1)}' | head -1)
      [ -n "$ip" ] || ip=$(hostname -I 2>/dev/null | awk '{print $1}') ;;
  esac
  echo "${ip:-localhost}"
}
# Lets Developer Interface see which machine it runs on (the host's /etc/machine-id), so its licence only works on
# this server: a copy of this folder, its data or a backup on another machine needs its own licence. Linux only.
machine_id_mount() {
  [ -f docker-compose.override.yml ] && return 0
  case "$(uname -s)" in Linux) ;; *) return 0 ;; esac
  [ -f /etc/machine-id ] || return 0
  cat > docker-compose.override.yml <<'YML'
# Made by install.sh: lets Developer Interface see which machine it runs on, so its licence only works on this server.
services:
  app:
    volumes:
      - /etc/machine-id:/host/machine-id:ro
YML
}

say "Developer Interface install"
command -v docker >/dev/null || { echo "Docker isn't installed. On Ubuntu/Debian: curl -fsSL https://get.docker.com | sh   then run this again."; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "Docker Compose (the 'docker compose' plugin) is missing. Install docker-compose-plugin, then run this again."; exit 1; }

if [ -f .env ]; then
  echo "This folder already has settings (.env). Starting Developer Interface with them; edit .env to change anything."
else
  cp .env.example .env
  set_env() { sed -i.bak "s#^$1=.*#$1=$2#" .env && rm -f .env.bak; }
  set_env DB_PASSWORD "$(secret 24)"
  set_env DB_ROOT_PASSWORD "$(secret 24)"
  set_env JWT_SECRET "$(secret 48)"
  set_env APP_PORT "$PORT"
  [ -n "$IMAGE" ] && set_env DI_IMAGE "$IMAGE"
  [ -n "$VERSION" ] && set_env DI_VERSION "$VERSION"
  if [ -n "$DOMAIN" ]; then
    [ -n "$EMAIL" ] || { echo "Add --email it@yourcompany.com (for the HTTPS certificate)."; rm -f .env; exit 2; }
    set_env APP_URL "https://$DOMAIN"
    set_env DOMAIN "$DOMAIN"
    set_env ACME_EMAIL "$EMAIL"
    set_env COMPOSE_PROFILES https
  else
    set_env APP_URL "http://$(lan_ip):$PORT"
  fi
  chmod 600 .env
  echo "Settings written to .env (keep it private: it holds the passwords)."
fi

machine_id_mount
if [ -n "$IMAGE_FILE" ]; then docker load -i "$IMAGE_FILE"; else docker compose pull; fi
docker compose up -d

URL=$(grep -E '^APP_URL=' .env | cut -d= -f2-)
say "Developer Interface is starting (about a minute the first time)."
echo "Open:  $URL"
echo "The first person to sign up becomes the admin. Then open the Licence screen and send the activation request."
echo "Keep this address fixed: it's part of this server's Activation ID."
