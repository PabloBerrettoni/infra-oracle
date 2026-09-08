# AGENTS.md

Guide for AI agents and developers working in this repository.

## What this is

Infrastructure-as-code for a personal project on **Oracle Cloud Infrastructure (OCI)**
using Terraform. Everything is designed to run inside the OCI **Always Free** tier — do
not push changes that would exceed the free limits (see below).

Remote state lives in OCI Object Storage (bucket `terraform-state`, namespace
`grutjt8nmecj`, region `sa-saopaulo-1`). GitHub Actions (`.github/workflows/terraform.yml`)
runs `terraform plan` on PRs and `terraform apply` on pushes to `main`.

## Account / identity cheat-sheet

- **Tenancy (cloud account) name:** `clep0`
- **Tenancy OCID:** `ocid1.tenancy.oc1..aaaaaaaaebyaeey7fj3lyct6xxdvmtspn5dbh5cxtcxmlp5ppxsgxpz5jfkq`
- **User OCID / API fingerprint / SSH pubkeys:** NOT stored in the repo. They live in the
  gitignored `.env` (with `TF_VAR_*` names) and in GitHub Actions secrets
  (`OCI_TENANCY_OCID`, `OCI_USER_OCID`, `OCI_FINGERPRINT`, `OCI_PRIVATE_KEY`, `SSH_PUBLIC_KEYS`).
- **Console sign-in:** https://cloud.oracle.com → cloud account `clep0` → username
  `pablo_berrettoni@hotmail.com` + password (recovery email = the same Hotmail).
- **Local tooling** (installed without sudo, in `~/.local/bin`): `terraform`, `oci`, `gh`.
  The `oci` CLI reads `~/.oci/config` + `~/.oci/oci_api_key.pem`. Docker is available locally.

## Resources deployed (Always Free)

| VM | Shape | Role | Discover IP |
|----|-------|------|-------------|
| `pablo-web-vps` | `VM.Standard.E2.1.Micro` | Live site `pabloberrettoni.com` (docker + nginx + certbot) | `terraform output portfolio_public_ip` |
| `openvpn-vps` | `VM.Standard.E2.1.Micro` | OpenVPN (UDP 1194) | `terraform output vpn_public_ip` |
| `minecraft-vps` | `VM.Standard.A1.Flex` (2 OCPU / 12 GB) | Crafty + PaperMC; web UI `https://crafty.pabloberrettoni.com` (Caddy + Let's Encrypt in front) | `terraform output minecraft_public_ip` |

Also: OCI DNS zone `pabloberrettoni.com` (A records for the apex, `www`, and `crafty`),
one VCN (`10.0.0.0/16`) + public subnet, and the remote-state bucket.

**Crafty admin credentials are auto-generated per container** (change after login):

```bash
ssh ubuntu@<minecraft-ip>
sudo docker exec crafty cat /crafty/app/config/default-creds.txt   # username "admin", random password
```

## Always Free limits — do not exceed

- **Compute:** max **2 AMD micros** AND max **2 OCPU / 12 GB of ARM** (A1.Flex) total.
- **Storage:** **200 GB TOTAL** across all boot + block volumes in the tenancy.
  Rebuilding an instance without deleting its boot volume leaves billable orphans — check
  `oci bv boot-volume list -c "$TF_VAR_tenancy_ocid" --availability-domain <AD>` and delete
  detached volumes (`oci bv boot-volume delete --force`).
- The only recurring charge is the **OCI DNS zone** (~$0.005/month). Everything else must stay $0.
- **Idle A1 instances get reclaimed** after ~7 days below 20% CPU/NET/MEM — keep the box busy.

## Terraform gotchas (learned the hard way)

1. **`metadata` is ForceNew** in the OCI provider — changing `ssh_authorized_keys` OR
   `user_data` (cloud-init) destroys & recreates the VM. All compute modules therefore use
   `lifecycle { ignore_changes = [metadata] }`. Apply instance-level changes (keys,
   cloud-init) manually on the OS — Terraform will NOT pick them up anymore.
2. **Pin images.** Modules used to resolve the newest image, so every new Oracle build
   forced a rebuild. Image OCIDs are stored in `variable "image_ocid"` defaults; bump
   deliberately when you actually want a new OS image.
3. **cloud-init YAML: no multi-line backslash continuations.** cloud-init folds multiline
   `runcmd` entries into one line, leaving literal `\ ` which breaks docker/console
   (exit 125). Keep every `runcmd` item on **one line**; write multi-line files via
   `printf '%s\n' ...` or a YAML block-scalar heredoc (`- |`), never backslash folds.
4. **SSH keys are immutable on OCI** after creation — the update API rejects changes.
   Rotate keys on the OS or via a console connection.
5. **State lock collisions:** pushes to `main` auto-apply; concurrent pushes collide with
   `412 IfNoneMatchFailed` on the lock object. The workflow has a `concurrency` group
   (group: `terraform-apply`, `cancel-in-progress: false`), and **related changes must go
   in ONE commit** so CI never applies a partial state.
6. **`apply -target=<resource>` pulls in dependencies** — targeting a DNS record can drag
   in (and recreate) the compute instance it points to.
7. **DNS record lifecycle:** if a record is removed from config, the next apply deletes it
   from the zone. Deleting and re-adding DNS in separate commits breaks the site in between
   (and breaks Caddy's ACME cert issuance → NXDOMAIN).
8. **Crafty behind a reverse proxy needs HTTP/1.1 WebSockets.** Tornado (Crafty) rejects
   WebSockets over HTTP/2. Use Crafty's documented nginx recipe (`proxy_http_version 1.1`,
   `proxy_set_header Upgrade $http_upgrade; Connection $http_connection`, buffering off,
   3600s timeouts). Caddy `:2` cannot force h1.1 (`protocols` is not a recognized option).

## Repo layout

- `modules/compute_portfolio/` — x86 micro hosting the portfolio site (cloud-init: docker
  pull, nginx reverse proxy, certbot).
- `modules/compute_openvpn/` — micro running angristan's openvpn-install script.
- `modules/compute_arm/` — A1.Flex box: Docker + **Crafty Controller** (PaperMC UI).
  Cloud-init (single-line items + YAML block-scalar heredocs) also runs an **nginx**
  HTTPS proxy (Crafty's documented WebSocket-safe recipe: `proxy_http_version 1.1`,
  `Upgrade`/`Connection` headers, buffering off) with **certbot** (Let's Encrypt) and a
  weekly renew cron. Data persists at `/opt/crafty` and `/opt/nginx-shared` on the host.
- `modules/network/` — VCN, IGW, route table, default security list
  (ports: 22, 80, 443, 1194/UDP, 25565, 8000, 8443).
- `modules/dns/` — zone + A records (apex, `www`, `crafty`).
- `projects/prod/` — environment composition; secrets supplied via `.env` (gitignored).

## Common commands

```bash
source .env && cd projects/prod
terraform init   # backend-config needs the OCIDs, fingerprint, key path
terraform plan   # read-only
terraform apply  # only after reviewing the plan!
terraform output minecraft_public_ip
oci compute instance list -c "$TF_VAR_tenancy_ocid" --all
oci bv boot-volume list -c "$TF_VAR_tenancy_ocid" --availability-domain <AD>
```

- SSH user is `ubuntu`, key `~/.ssh/id_ed25519` (comment `clepo-wsl2`).
- Docker Hub user for the portfolio image: `clepo123`.