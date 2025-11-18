# Oracle Cloud Infrastructure Terraform Automation

This project provides Infrastructure as Code (IaC) for deploying and managing cloud resources on Oracle Cloud Infrastructure (OCI) using [Terraform](https://www.terraform.io/). It features a modular architecture, supports CI/CD with GitHub Actions, and leverages Oracle Cloud's Always Free tier.

---

## Features

- **Modular Terraform**: Reusable modules for compute, networking, DNS, and backend state.
- **Automated CI/CD**: GitHub Actions workflow for plan/apply on PRs and main branch.
- **Secure State Management**: Remote state stored in OCI Object Storage.
- **Production-Ready**: SSH, HTTP, and HTTPS access, Nginx reverse proxy, Dockerized app, and automatic SSL via Certbot.
- **Always Free Tier**: Designed to run within Oracle's free resource limits.

---

## Project Structure

```
├── modules/
│   ├── compute_portfolio/        # Portfolio website compute instance (x86)
│   ├── compute_translate/        # Translation service compute instance (x86)
│   ├── compute_arm/              # ARM compute instance (A1 Flex)
│   ├── network/                  # VCN, subnet, security, gateway
│   ├── dns/                      # DNS zone and records
│   └── backend/                  # Remote state bucket module
├── projects/
│   └── prod/                     # Production environment composition
├── .github/
│   └── workflows/                # GitHub Actions workflow
├── .env.example                  # Example environment variables
├── .gitignore                    # Ignore rules
└── README.md                     # Project documentation
```

---

## Prerequisites

- Oracle Cloud account with API keys
- Terraform >= 1.13.0
- SSH key pair for server access

---

## Local Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Oracle-Infra
   ```

2. **Create environment configuration**
   ```bash
   cp .env.example .env
   ```

3. **Edit `.env` with your OCI credentials**
   ```bash
   export TF_VAR_tenancy_ocid="your-tenancy-ocid"
   export TF_VAR_user_ocid="your-user-ocid"
   export TF_VAR_fingerprint="your-api-key-fingerprint"
   export TF_VAR_private_key="-----BEGIN PRIVATE KEY-----
   your-private-key-content
   -----END PRIVATE KEY-----"
   export TF_VAR_ssh_public_keys='[{"user":"username","publickey":"ssh-ed25519 AAAAC3... your-key"}]'
   ```

4. **Initialize and deploy**
   ```bash
   source .env
   cd projects/prod
   terraform init
   terraform plan
   terraform apply
   ```

---

## GitHub Actions Setup

### Required Secrets

Configure the following secrets in your GitHub repository settings:

| Secret Name        | Description                        |
|--------------------|------------------------------------|
| `OCI_TENANCY_OCID` | Your OCI tenancy identifier        |
| `OCI_USER_OCID`    | Your OCI user identifier           |
| `OCI_FINGERPRINT`  | API key fingerprint                |
| `OCI_PRIVATE_KEY`  | Complete private key content       |
| `SSH_PUBLIC_KEYS`  | JSON array of SSH public keys      |

### SSH Keys Format

The `SSH_PUBLIC_KEYS` secret should contain a JSON array:
```json
[{"user":"your-username","publickey":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your-public-key"}]
```

### Workflow Behavior

- **Pull Requests**: Runs `terraform plan` and comments results on the PR
- **Main Branch**: Automatically applies infrastructure changes with `terraform apply`

---

## Resource Specifications

This configuration uses Oracle Cloud's Always Free tier resources:

**STANDARD:**
- **Compute**: `VM.Standard.E2.1.Micro` (1 OCPU, 1 GB RAM)
- **Storage**: 50 GB boot volume
- **Network**: Public IP with internet gateway
- **Operating System**: Oracle Linux 8
- **Cost**: $0.00 (within Always Free limits)

**ARM:**
- **Compute**: VM.Standard.A1.Flex (2 OCPUs, 12 GB RAM)
- **Storage**: 47 GB boot volume
- **Network**: Public IP with internet gateway
- **Operating System**: Ubuntu 24.04 LTS
- **Cost**: $0.00 (within Always Free limits)

---

## Usage

### Accessing the Server

After deployment, connect via SSH:
```bash
ssh ubuntu@<public-ip-address>
```
The public IP address is displayed in Terraform outputs.

### Deploying Websites

The server includes Nginx web server. Deploy your content to:
```bash
sudo cp your-files /var/www/html/
```

### Modifying Infrastructure

1. Make changes to Terraform files
2. Create a pull request to review the plan
3. Merge to main branch to apply changes

---

## Security Considerations

- No sensitive data is stored in the repository
- Secrets are managed through environment variables and GitHub Secrets
- Terraform state is excluded from version control
- SSH key-based authentication only
- Firewall configured to allow only necessary ports

---

## Module Customization

The VPS module accepts these parameters:

- `instance_name`: Display name for the instance
- `hostname_label`: DNS hostname label
- `ssh_public_keys`: List of SSH public keys
- `ocpus`: Number of OCPUs (1-4 for Always Free)
- `memory_in_gbs`: Memory allocation (6-24 GB for Always Free)

---

## License

MIT License. See [LICENSE](LICENSE) if present.

---

## Author

Pablo Berrettoni

---