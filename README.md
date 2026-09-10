# OCI Always Free — Terraform Infrastructure as Code

[![Terraform CI/CD](https://github.com/PabloBerrettoni/infra-oracle/actions/workflows/terraform.yml/badge.svg)](https://github.com/PabloBerrettoni/infra-oracle/actions/workflows/terraform.yml)

Infrastructure as Code for [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/) built with
[Terraform](https://www.terraform.io/). It deploys a small but complete platform — web hosting,
VPN, and a game server — entirely inside OCI's **Always Free** tier ($0.00/month), with remote
state and fully automated CI/CD through GitHub Actions.

Every module is written to be **tenant-agnostic**: no names, domains, ports, or credentials are
hardcoded inside the modules — they are all declared at the composition layer
(`projects/prod/main.tf`), so you can fork the repo and deploy your own stack unchanged.

---

## Features

- **Modular Terraform** — reusable, parameterized modules for compute (x86 / ARM), networking,
  DNS, and remote state backend.
- **CI/CD** — `terraform plan` (commented on PRs) and automatic `apply` on `main`, with a
  concurrency guard that serializes applies against the state lock.
- **Remote state + locking** — state lives in an OCI Object Storage bucket; concurrent applies
  are rejected with `412` instead of corrupting state.
- **HTTPS out of the box** — nginx reverse proxy + Let's Encrypt (certbot), including Crafty's
  documented WebSocket-safe proxy recipe.
- **Zero-cost by design** — resources sized to fit Oracle's Always Free limits.

---

## What it deploys

```
                            OCI VCN 10.0.0.0/16 · public subnet 10.0.1.0/24
                          ┌──────────────────────────────────────────────────┐
   internet ──── IGW ─────┤  web-vps    VM.Standard.E2.1.Micro (AMD, 1/1)    │
        │                 │             docker + nginx + certbot → your app  │
        │                 ├──────────────────────────────────────────────────┤
        │                 │  vpn-vps    VM.Standard.E2.1.Micro               │
        │                 │             OpenVPN (UDP 1194, auto-configured)  │
        │                 ├──────────────────────────────────────────────────┤
        │                 │  arm-vps    VM.Standard.A1.Flex (2 OCPU/12 GB)   │
        │                 │             Crafty Controller + PaperMC server,  │
        │                 │             HTTPS UI via nginx + certbot         │
        └─────────────────┴──────────────────────────────────────────────────┘
                                        ▲
                     OCI DNS managed zone ─ A records for apex / www / any subdomain
```

| Resource | Shape | Role |
|---|---|---|
| **web-vps** | `VM.Standard.E2.1.Micro` | Runs any Docker image behind nginx with automatic Let's Encrypt certs (apex + `www`) |
| **vpn-vps** | `VM.Standard.E2.1.Micro` | OpenVPN server (UDP 1194) installed non-interactively via [angristan's openvpn-install](https://github.com/angristan/openvpn-install) |
| **arm-vps** | `VM.Standard.A1.Flex` (2 OCPU / 12 GB) | [Crafty Controller](https://craftycontrol.com) (Minecraft server manager) + reverse-proxy HTTPS UI; data persisted under `/opt/crafty` |
| **network** | — | VCN, Internet Gateway, default route table + security list (configurable open ports) |
| **dns** | — | OCI managed DNS zone + A records (generic record list) |
| **backend** | — | Object Storage bucket for Terraform remote state with locking |

---

## Project structure

```
├── modules/
│   ├── backend/             # Remote-state bucket (OCI Object Storage)
│   ├── compute_portfolio/   # Generic x86 web VPS: docker + nginx + certbot
│   ├── compute_openvpn/     # x86 VPN VPS (OpenVPN, UDP 1194)
│   ├── compute_arm/         # ARM A1.Flex: Crafty + Minecraft + HTTPS proxy
│   ├── compute_translate/   # Generic x86 web-service variant (optional, not wired into prod)
│   ├── dns/                 # DNS zone + configurable A records
│   └── network/             # VCN, subnet, IGW, route table, security list
├── projects/
│   └── prod/                # The composition: your names, domains, ports live HERE
├── .github/
│   └── workflows/           # Terraform CI/CD (plan on PRs, apply on main)
├── .env.example             # Template for local credentials
└── README.md
```

> **Personal configuration lives only in `projects/prod/main.tf`** (and in `.env` / GitHub
> secrets). The modules themselves contain no tenant-specific values.

---

## Module reference

### `modules/compute_portfolio` — x86 web VPS

Boots an Ubuntu micro that pulls a Docker image, runs it, fronts it with nginx and issues
Let's Encrypt certificates with retry logic.

| Variable | Type | Default | Description |
|---|---|---|---|
| `availability_domain` | string | — | AD to launch in |
| `compartment_id` | string | — | Target compartment |
| `instance_name` | string | — | Display name |
| `hostname_label` | string | — | VNIC hostname label |
| `subnet_id` | string | — | Subnet to attach |
| `ssh_public_keys` | list | — | SSH keys installed on boot |
| `docker_image` | string | — | Image to pull and run |
| `container_name` | string | — | Container name |
| `container_port` | number | — | Host port mapped to the container's port 80 |
| `domains` | list(string) | — | Domains for nginx `server_name` + certbot (`-d` flags) |
| `email` | string | — | Let's Encrypt registration email |
| `image_ocid` | string | *pinned* | Ubuntu 22.04 image OCID — **region-specific, override for your region** |

### `modules/compute_openvpn` — x86 VPN VPS

Ubuntu micro running angristan's `openvpn-install.sh` non-interactively (UDP 1194,
endpoint auto-detected from the public IP).

| Variable | Type | Default | Description |
|---|---|---|---|
| `availability_domain` | string | — | AD to launch in |
| `compartment_id` | string | — | Target compartment |
| `instance_name` | string | — | Display name |
| `hostname_label` | string | — | VNIC hostname label |
| `subnet_id` | string | — | Subnet to attach |
| `ssh_public_keys` | list | — | SSH keys installed on boot |
| `image_ocid` | string | *pinned* | Ubuntu 22.04 image OCID — **region-specific** |

### `modules/compute_arm` — ARM workhorse (Crafty + Minecraft)

A1.Flex box running Crafty Controller (web UI on `:8443`, game port `:25565`) with an nginx
HTTPS reverse proxy and Let's Encrypt, plus a weekly certificate-renewal cron.

| Variable | Type | Default | Description |
|---|---|---|---|
| `compartment_id` | string | — | Target compartment |
| `instance_name` | string | — | Display name |
| `hostname_label` | string | — | VNIC hostname label |
| `ssh_public_keys` | list | — | SSH keys installed on boot |
| `subnet_id` | string | — | Subnet to attach |
| `ocpus` | number | — | OCPUs (2 = Always Free max for A1) |
| `memory_in_gbs` | number | — | RAM (12 = Always Free max for A1) |
| `domain` | string | — | FQDN for the Crafty UI (nginx `server_name` + LE cert) |
| `email` | string | — | Let's Encrypt registration email |
| `timezone` | string | `UTC` | TZ for containers |
| `crafty_http_port` | number | `8000` | Crafty UI HTTP port |
| `crafty_https_port` | number | `8443` | Crafty UI HTTPS port |
| `minecraft_port` | number | `25565` | Minecraft server port |
| `image_ocid` | string | *pinned* | Ubuntu 24.04 (aarch64) image OCID — **region-specific** |

### `modules/network`

| Variable | Type | Default | Description |
|---|---|---|---|
| `compartment_id` | string | — | Target compartment |
| `network_name` | string | — | Name prefix for VCN/IGW/RT/SL/subnet |
| `vcn_cidr` | string | `10.0.0.0/16` | VCN CIDR |
| `public_subnet_cidr` | string | `10.0.1.0/24` | Public subnet CIDR |
| `vcn_dns_label` | string | `mainvcn` | VCN DNS label (unique per region) |
| `subnet_dns_label` | string | `public` | Subnet DNS label (unique per VCN) |
| `allowed_tcp_ports` | list(number) | `[22, 80, 443, 8000, 8443, 25565]` | TCP ingress opened to `0.0.0.0/0` |
| `allowed_udp_ports` | list(number) | `[1194]` | UDP ingress ports opened to `0.0.0.0/0` |

### `modules/dns`

| Variable | Type | Default | Description |
|---|---|---|---|
| `compartment_id` | string | — | Compartment for the zone |
| `zone_name` | string | — | Zone to manage (e.g. `example.com`) |
| `ttl` | number | `300` | Record TTL |
| `records` | list of `{name, ip}` | — | A records; `name = ""` is the apex record |

### `modules/backend`

| Variable | Type | Description |
|---|---|---|
| `tenancy_ocid` | string | Tenancy for the namespace lookup |
| `compartment_ocid` | string | Compartment for the state bucket |
| `region` | string | Bucket region |

---

## Getting started (local deploy)

### Prerequisites

- OCI account with an **API key** configured (see the
  [docs](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm))
- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.12 and OCI provider ≥ 7.20
- SSH key pair
- OCI CLI (optional but handy)

### 1. Clone and configure credentials

```bash
git clone <your-fork>
cd infra-oracle
cp .env.example .env      # then edit .env with your values
source .env
```

`.env` exports `TF_VAR_*` values (never commit it):

| Variable | Description |
|---|---|
| `TF_VAR_tenancy_ocid` | Your tenancy OCID |
| `TF_VAR_user_ocid` | Your IAM user OCID |
| `TF_VAR_fingerprint` | API key fingerprint |
| `TF_VAR_private_key` **or** `TF_VAR_private_key_path` | API signing key |
| `TF_VAR_region` | Your home region |
| `TF_VAR_ssh_public_keys` | JSON array: `[{"user":"ubuntu","publickey":"ssh-ed25519 AAAA... you@host"}]` |

### 2. Point the backend at *your* bucket

`projects/prod/main.tf` configures the OCI backend — edit the `backend "oci"` block
(`bucket`, `namespace`, `region`, `key`) to your own Object Storage namespace, **or** pass the
same values as `-backend-config` flags on `terraform init`.

On the first run the bucket doesn't exist yet. Bootstrap once with the backend commented out:

```bash
cd projects/prod
# comment out the backend "oci" block, then:
terraform init
terraform apply          # creates the state bucket via the backend module
# uncomment the backend block, then:
terraform init           # migrates state into the bucket
```

### 3. Override the pinned images for your region

Image OCIDs are pinned (so new Oracle builds never force a VM rebuild), but OCIDs are
**region-specific**. The defaults in the compute modules only exist in `sa-saopaulo-1` —
override `image_ocid` on every compute module call with an image from your home region:

```bash
oci compute image list -c "$TF_VAR_tenancy_ocid" \
  --operating-system "Canonical Ubuntu" --operating-system-version "24.04" \
  --shape "VM.Standard.A1.Flex" \
  --query 'data[0].id' --raw-output
```

### 4. Adjust the composition and deploy

Edit `projects/prod/main.tf`: instance names, sizes, domains, the Docker image to host, the
DNS records, and the open ports. Then:

```bash
terraform init
terraform plan
terraform apply
```

### 5. Delegate your DNS

If you manage the zone with OCI DNS, `terraform output dns_nameservers` shows the
nameservers — set them as NS records at your registrar *before* creating certs, otherwise
Let's Encrypt validation will fail (DNS propagation takes time; the cloud-init certbot steps
retry for ~1 minute).

### 6. Verify

```bash
terraform output portfolio_public_ip    # or vpn_public_ip / minecraft_public_ip
terraform output portfolio_ssh_command  # ready-made SSH command
ssh ubuntu@<public-ip>
```

---

## GitHub Actions CI/CD

The workflow (`.github/workflows/terraform.yml`) runs on changes to `projects/**`,
`modules/**`, or the workflow itself:

- **Pull requests** → `terraform fmt -check`, `terraform validate`, `terraform plan` — the plan
  is posted as a PR comment.
- **Push to `main`** → `terraform apply -auto-approve` (your changes go live automatically).
- **Concurrency** — a single `terraform-apply` group serializes runs, so parallel pushes queue
  instead of colliding on the state lock.

### Required repository secrets

| Secret | Description |
|---|---|
| `OCI_TENANCY_OCID` | Tenancy OCID |
| `OCI_USER_OCID` | IAM user OCID |
| `OCI_FINGERPRINT` | API key fingerprint |
| `OCI_PRIVATE_KEY` | API signing key (PEM contents) |
| `SSH_PUBLIC_KEYS` | JSON array of SSH public keys (same format as `TF_VAR_ssh_public_keys`) |

> Put **related changes in one commit/PR** — every merge to `main` applies that commit in full,
> so partial states never get applied.

---

## Staying inside the Always Free tier

- **Compute:** max 2 AMD micros (`E2.1.Micro`) **and** max 2 OCPU / 12 GB of ARM (`A1.Flex`) —
  the defaults consume exactly that.
- **Storage:** 200 GB total across all boot + block volumes in the tenancy. Rebuilding an
  instance *without* deleting its boot volume leaves billable orphans:

  ```bash
  oci bv boot-volume list -c "$TF_VAR_tenancy_ocid" --availability-domain <AD>
  # delete detached ones:
  oci bv boot-volume delete --boot-volume-id <ocid> --force
  ```

- **Idle ARM instances are reclaimed** after roughly a week below 20% CPU/NET/MEM usage — keep
  the A1 box busy.
- The only recurring charge in this setup is an OCI DNS zone (~$0.005/month).

---

## Operational notes (read before modifying)

These behaviors are deliberate — they were learned the hard way:

1. **`metadata` is ForceNew** in the OCI provider: changing `ssh_authorized_keys` or `user_data`
   (cloud-init) would destroy and recreate the VM. All compute modules set
   `lifecycle { ignore_changes = [metadata] }` — instance-level changes (SSH keys, cloud-init
   edits) are applied on the OS directly.
2. **Images are pinned** with `image_ocid` variables. Auto-resolving "latest" drifts every time
   Oracle publishes a new build and forces instance replacement (downtime). Bump deliberately.
3. **cloud-init YAML:** don't use multi-line backslash continuations — cloud-init folds multiline
   `runcmd` entries into one line and leaves broken `\` escapes. Keep every `runcmd` item on one
   line; write multi-line files via YAML block scalars (`- |`) or `printf '%s\n'`.
4. **SSH keys are immutable on OCI** after instance creation — rotate keys on the OS (or via
   console), not through the instance API.
5. **State locking:** concurrent applies collide with `412 IfNoneMatchFailed` on the lock
   object. The CI concurrency group prevents this for automation; locally, don't run applies in
   parallel with CI.
6. **`terraform apply -target=...` pulls in dependencies** — targeting a DNS record can drag in
   (and recreate) the compute instance behind it. Use sparingly.
7. **DNS lifecycle:** a record removed from config is deleted from the zone on the next apply.
   Remove and re-add DNS in *separate* applies and the site goes dark in between (and certs fail
   with NXDOMAIN).
8. **WebSockets through the reverse proxy need HTTP/1.1** (Crafty/Tornado rejects WebSockets over
   HTTP/2). The ARM cloud-init implements Crafty's documented nginx recipe: `proxy_http_version
   1.1`, `Upgrade`/`Connection` headers, buffering off, 3600 s timeouts.

---

## Security

- No secrets are stored in the repository — credentials live in `.env` (gitignored) and GitHub
  Actions secrets.
- Terraform state lives in a private Object Storage bucket, outside version control.
- Instances accept SSH key authentication only; host-level firewalls (iptables, persisted via
  `iptables-persistent`) open only the service ports, on top of the OCI security list.

---

## License

MIT License. See [LICENSE](LICENSE).

---

## Author

**Pablo Berrettoni** — [pabloberrettoni.com](https://pabloberrettoni.com)
