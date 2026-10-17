# Installing Developer Interface

Developer Interface runs on your own server with Docker. Your projects, entities and people stay on your servers; the
licence is checked there, offline.

## What you need

- A server: Linux (Ubuntu 22.04 or 24.04, Debian 12), or Windows or macOS with Docker Desktop.
- 2 CPUs and 4 GB of memory are enough for a team of 10.
- A fixed address for it (a DNS name, or a fixed IP address on your network). The address is part of the server's
  Activation ID, so the licence is made for it.

## Install

1. Install Docker, if it isn't installed:

   ```bash
   curl -fsSL https://get.docker.com | sh
   ```

2. Install Developer Interface:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/lotfy2125/developerinterface-install/main/get.sh | bash
   ```

   That's for your office network: it opens at `http://<this server>:8080`. To run it at a DNS name with HTTPS
   (Let's Encrypt), add your name and an email for the certificate:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/lotfy2125/developerinterface-install/main/get.sh | bash -s -- --domain di.acme.com --email it@acme.com
   ```

   **On Windows:** run these in **Git Bash** (it comes with Git for Windows), with Docker Desktop running. Not in
   PowerShell, and not in Docker Desktop's own WSL shell (`docker-desktop`).

   **Port 8080 already in use** (another app or container on this server)? The installer says so and suggests a free
   port. Run it again with that port:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/lotfy2125/developerinterface-install/main/get.sh | bash -s -- --port 8085
   ```

3. Open the address it prints. The first start takes about a minute; if the page doesn't load yet, wait and reload. The
   first person to sign up becomes the admin.

## Activate

1. The admin opens **Licence**. The activation request is filled in already, with this server's **Activation ID** (a
   one-way code that reveals nothing about the server or your data). Check it and select **Send activation request**.
2. LotfyTech sends the invoice. Once it's paid, you receive your licence file (`.dilicence`).
3. The admin opens **Licence → Open licence file**. It works at once; no restart.
4. The admin adds the developers on **Team**. Each one takes a place on the licence; switching someone off frees it.

Until a licence is added, everyone can sign in and open what they saved, but no new projects can be generated.

## Everyday tasks

| Task | Command (in the `developerinterface` folder) |
|---|---|
| Update to the newest version (backs up first) | `./update.sh` |
| Update to a given version | `./update.sh 2.0.5` |
| Back up (accounts, saved projects, the licence) | `./backup.sh` |
| Restore a backup | `./restore.sh backups/<file>.sql.gz` |
| See the logs | `docker compose logs -f app` |
| Stop / start | `docker compose stop` / `docker compose up -d` |

Installed with version 2.0.4 or older? Name the version the first time you update (`./update.sh 2.0.5`). From then
on, `./update.sh` finds the newest version by itself.

## Email (optional)

Developer Interface can email password reset links. Add your mail server to `.env`, then `docker compose up -d`:

```
MAIL_HOST=smtp.acme.com
MAIL_PORT=465
MAIL_USERNAME=noreply@acme.com
MAIL_PASSWORD=...
MAIL_FROM=Developer Interface <noreply@acme.com>
```

Without it, admins give people a new password on **Team → New password**.

## Servers without internet

Download `developerinterface-image-<version>-amd64.tar.gz` and `developerinterface-install-<version>.tar.gz` from the
releases page on a computer with internet, copy both to the server, then:

```bash
tar xzf developerinterface-install-<version>.tar.gz && cd developerinterface
./install.sh --image-file ../developerinterface-image-<version>-amd64.tar.gz
```

## Moving to another server

A licence works on one server. After moving (restore a backup on the new server), the admin sends the activation request
from the new server's Licence screen, and we send a licence for it.

## If something goes wrong

| What you see | What to do |
|---|---|
| `port is already allocated` | Another app uses the port. Set a free one: `APP_PORT=8085` in `.env` (and the port in `APP_URL`), then `docker compose up -d`. |
| The page says "isn't working" or "didn't send any data" | It's still starting. Wait a minute and reload; `docker compose logs app` shows its progress. |
| `cannot stop container … did not receive an exit event` (Windows) | A Docker Desktop hiccup. Restart Docker Desktop, then `docker compose up -d`. |
| `Docker isn't installed or isn't running` | Start Docker Desktop (Windows, macOS), or install Docker (Linux, step 1). |

## Help

Email sayed@lotfytech.com.
