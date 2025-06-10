# Oracle Cloud Infrastructure GitOps Project

This project demonstrates GitOps practices for deploying VPS infrastructure on Oracle Cloud's Always Free tier using Terraform.

## 🏗️ Architecture

- **Terraform modules** for reusable infrastructure components
- **GitHub Actions** for CI/CD automation
- **Always Free tier** resources (2 OCPUs, 12GB RAM)
- **Ubuntu 24.04** minimal server setup
- **Nginx** web server ready for deployment

## 🚀 Quick Start

### Prerequisites

1. Oracle Cloud Infrastructure account
2. API key pair generated in OCI
3. SSH key pair for server access

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd oracle-cloud-gitops
   ```

2. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your actual OCI credentials
   source .env
   ```

3. **Deploy infrastructure**
   ```bash
   cd projects/prod
   terraform init
   terraform plan
   terraform apply
   ```

### GitHub Actions Setup

1. **Add repository secrets** in GitHub Settings → Secrets and variables → Actions:
   - `OCI_TENANCY_OCID`: Your OCI tenancy OCID
   - `OCI_USER_OCID`: Your OCI user OCID  
   - `OCI_FINGERPRINT`: Your API key fingerprint
   - `OCI_PRIVATE_KEY_PATH`: Path to private key (e.g., `~/.oci/oci_api_key.pem`)
   - `SSH_PUBLIC_KEYS`: JSON array of SSH keys (see format below)

2. **SSH Keys format for GitHub secret**:
   ```json
   [{"user":"your-username","publickey":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your-public-key"}]
   ```

3. **Automated deployment**:
   - Pull requests trigger `terraform plan`
   - Pushes to `main` trigger `terraform apply`

## 📁 Project Structure

```
├── modules/vps-definition/    # Reusable VPS module
│   ├── main.tf               # VCN, compute, networking
│   ├── variables.tf          # Module inputs
│   ├── outputs.tf            # Module outputs
│   └── cloud-init.yaml       # Server initialization
├── projects/prod/            # Production environment
│   ├── main.tf              # Module composition
│   ├── variables.tf         # Environment variables
│   └── outputs.tf           # Environment outputs
└── .github/workflows/        # CI/CD automation
    └── terraform.yml         # GitHub Actions workflow
```

## 🔒 Security

- No sensitive data committed to repository
- Secrets managed via environment variables and GitHub Secrets
- State file excluded from version control
- SSH key-based authentication only

## 💰 Cost

This project uses Oracle Cloud's Always Free tier resources:
- **Compute**: VM.Standard.A1.Flex (2 OCPUs, 12GB RAM)
- **Networking**: VCN, subnet, internet gateway
- **Storage**: Boot volume included
- **Cost**: $0.00/month (within Always Free limits)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

Pull requests automatically trigger Terraform plans for review.