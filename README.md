# 🚀 LenDen DevSecOps Assignment

A comprehensive DevSecOps project demonstrating containerization, infrastructure as code, CI/CD pipelines with security scanning, and AI-driven security remediation.

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Prerequisites](#-prerequisites)
- [Quick Start Guide](#-quick-start-guide)
- [Project Structure](#-project-structure)
- [Before & After Security Report](#-before--after-security-report)
- [AI Usage Log](#-ai-usage-log-mandatory)
- [Screenshots](#-screenshots)
- [Video Recording](#-video-recording)

---

## 🎯 Project Overview

**Scenario:** As a DevOps Engineer, the task is to ensure cloud infrastructure is **secure by default**.

This project implements:
1. **Containerized Web Application** - Node.js app running in Docker
2. **Infrastructure as Code** - AWS resources provisioned with Terraform
3. **CI/CD Pipeline** - Jenkins pipeline with automated security scanning
4. **Security Scanning** - Trivy scans Terraform for vulnerabilities
5. **AI-Driven Remediation** - Use AI to fix security issues

### What You'll Learn
- How to containerize applications with Docker
- How to write Terraform to provision AWS infrastructure
- How to set up Jenkins pipelines
- How to scan infrastructure code for security vulnerabilities
- How to use AI to fix security issues

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DevSecOps Pipeline Flow                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────┐     ┌──────────────┐     ┌───────────────────────────────┐│
│  │  Developer   │────▶│    GitHub    │────▶│      Jenkins Pipeline         ││
│  │  Push Code   │     │  Repository  │     │                               ││
│  └──────────────┘     └──────────────┘     │  ┌─────────────────────────┐  ││
│                                            │  │ 1. Checkout Code        │  ││
│                                            │  ├─────────────────────────┤  ││
│                                            │  │ 2. Trivy Security Scan  │◀─┼┼── Fails if vulnerabilities found
│                                            │  ├─────────────────────────┤  ││
│                                            │  │ 3. Terraform Validate   │  ││
│                                            │  ├─────────────────────────┤  ││
│                                            │  │ 4. Terraform Plan       │  ││
│                                            │  ├─────────────────────────┤  ││
│                                            │  │ 5. Docker Build         │  ││
│                                            │  └─────────────────────────┘  ││
│                                            └───────────────────────────────┘│
│                                                         │                    │
│                                                         ▼                    │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                            AWS Cloud                                   │  │
│  │  ┌──────────────────────────────────────────────────────────────────┐ │  │
│  │  │                              VPC                                  │ │  │
│  │  │  ┌───────────────────┐    ┌────────────────────────────────────┐ │ │  │
│  │  │  │  Security Group   │    │           EC2 Instance             │ │ │  │
│  │  │  │  ┌─────────────┐  │    │  ┌──────────────────────────────┐  │ │ │  │
│  │  │  │  │SSH (secured)│  │    │  │      Docker Container        │  │ │ │  │
│  │  │  │  │HTTPS (443)  │  │    │  │  ┌────────────────────────┐  │  │ │ │  │
│  │  │  │  │App (5000)   │  │    │  │  │   Node.js Express App  │  │  │ │ │  │
│  │  │  │  └─────────────┘  │    │  │  │      Port 5000         │  │  │ │ │  │
│  │  │  └───────────────────┘    │  │  └────────────────────────┘  │  │ │ │  │
│  │  │                           │  └──────────────────────────────┘  │ │ │  │
│  │  │                           └────────────────────────────────────┘ │ │  │
│  │  └──────────────────────────────────────────────────────────────────┘ │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Technology Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **Application** | Node.js, Express.js | Web server |
| **Containerization** | Docker, Docker Compose | Package application |
| **Infrastructure** | Terraform | Provision AWS resources |
| **Cloud Provider** | AWS (EC2, VPC, Security Groups) | Host application |
| **CI/CD** | Jenkins | Automate pipeline |
| **Security** | Trivy | Scan for vulnerabilities |
| **Version Control** | Git, GitHub | Source code management |

---

## 📚 Prerequisites

Before starting, ensure you have:

- **Docker** (v20.10+) - [Install Docker](https://docs.docker.com/get-docker/)
- **AWS Account** with IAM credentials
- **AWS CLI** configured (`aws configure`)
- **Git** installed

---

## ⚡ Quick Start Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/meet1785/LenDen-Ass.git
cd LenDen-Ass
```

### Step 2: Run the Application Locally

```bash
# Install dependencies and create package-lock.json
cd app && npm install && cd ..

# Build and run with Docker
docker-compose up -d --build

# Verify it's running
curl http://localhost:5000/health
```

### Step 3: Run Security Scan Locally

```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin

# Scan VULNERABLE Terraform (should show issues)
trivy config terraform-vulnerable/ --severity HIGH,CRITICAL

# Scan SECURE Terraform (should show fewer issues)
trivy config terraform/ --severity HIGH,CRITICAL
```

### Step 4: Start Jenkins

```bash
# Start Jenkins
docker-compose -f docker-compose.jenkins.yml up -d

# Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Access Jenkins at http://localhost:8080
```

### Step 5: Deploy to AWS

```bash
# Set AWS credentials
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1

# Deploy secure infrastructure
cd terraform
terraform init
terraform plan
terraform apply
```

---

## 📁 Project Structure

```
LenDen-Ass/
│
├── app/                          # Node.js Web Application
│   ├── server.js                 # Express.js server
│   ├── package.json              # Dependencies
│   ├── Dockerfile                # Container definition
│   └── public/
│       └── index.html            # Frontend UI
│
├── terraform-vulnerable/         # ❌ INSECURE Terraform (intentional)
│   └── main.tf                   # Contains security flaws for demo
│
├── terraform/                    # ✅ SECURE Terraform (after fixes)
│   └── main.tf                   # Fixed version
│
├── jenkins/                      # Jenkins Configuration
│   └── Dockerfile                # Jenkins with Trivy & Terraform
│
├── scripts/                      # Helper Scripts
│   ├── setup-jenkins.sh          # Start Jenkins
│   ├── run-trivy-scan.sh         # Run security scan
│   └── deploy-aws.sh             # Deploy to AWS
│
├── docker-compose.yml            # Run app locally
├── docker-compose.jenkins.yml    # Run Jenkins locally
├── Jenkinsfile                   # CI/CD Pipeline definition
└── README.md                     # This file
```

---

## 📊 Before & After Security Report

### ❌ BEFORE: Vulnerable Configuration

**Trivy Scan Results on `terraform-vulnerable/`:**

```
Tests: 5 (SUCCESSES: 0, FAILURES: 5)
Failures: 5 (HIGH: 4, CRITICAL: 1)

┌──────────────────┬──────────┬────────────────────────────────────────────────┐
│ Vulnerability ID │ Severity │ Description                                    │
├──────────────────┼──────────┼────────────────────────────────────────────────┤
│ AVD-AWS-0107     │ HIGH     │ SSH port 22 open to 0.0.0.0/0 (entire internet)│
├──────────────────┼──────────┼────────────────────────────────────────────────┤
│ AVD-AWS-0131     │ HIGH     │ EBS root volume is NOT encrypted               │
├──────────────────┼──────────┼────────────────────────────────────────────────┤
│ AVD-AWS-0028     │ HIGH     │ IMDSv2 not required (SSRF vulnerability)       │
├──────────────────┼──────────┼────────────────────────────────────────────────┤
│ AVD-AWS-0104     │ CRITICAL │ Unrestricted egress to any IP                  │
├──────────────────┼──────────┼────────────────────────────────────────────────┤
│ AVD-AWS-0164     │ HIGH     │ Subnet auto-assigns public IPs                 │
└──────────────────┴──────────┴────────────────────────────────────────────────┘
```

### ✅ AFTER: Secure Configuration

**Fixes Applied in `terraform/`:**

| Vulnerability | Before (Insecure) | After (Secure) |
|--------------|-------------------|----------------|
| SSH Access | `0.0.0.0/0` (anyone) | `10.0.0.0/8` (private only) |
| EBS Encryption | `encrypted = false` | `encrypted = true` + KMS key |
| IMDSv2 | `http_tokens = "optional"` | `http_tokens = "required"` |
| Egress Rules | All traffic allowed | Only HTTP, HTTPS, DNS |

---

## 📝 AI Usage Log (MANDATORY)

### Prompt Used to AI (ChatGPT/GitHub Copilot)

```
I have a Terraform configuration for AWS that was scanned by Trivy and 
found the following security vulnerabilities:

1. AVD-AWS-0107 (HIGH): SSH port 22 is open to 0.0.0.0/0
   - Line: cidr_blocks = ["0.0.0.0/0"] in SSH ingress rule

2. AVD-AWS-0131 (HIGH): EBS root volume is not encrypted
   - Line: encrypted = false

3. AVD-AWS-0028 (HIGH): IMDSv2 is not required
   - Line: http_tokens = "optional"

4. AVD-AWS-0104 (CRITICAL): Security group allows all egress traffic
   - Line: protocol = "-1" with cidr_blocks = ["0.0.0.0/0"]

Please:
1. Explain each vulnerability and its security risk
2. Provide the corrected Terraform code that fixes all issues
3. Add any additional security best practices
```

### Summary of Identified Risks

| Vulnerability | Risk Explanation |
|--------------|------------------|
| **SSH open to 0.0.0.0/0** | Anyone on the internet can attempt brute-force attacks on SSH. This is the #1 way servers get compromised. Attackers run bots that scan for open port 22 and try common passwords. |
| **Unencrypted EBS** | Data at rest is not protected. If the disk is stolen or accessed improperly, all data is readable. Violates compliance requirements (HIPAA, PCI-DSS, SOC2). |
| **IMDSv2 not enforced** | Allows Server-Side Request Forgery (SSRF) attacks. An attacker can trick the server into querying the metadata service and steal IAM credentials. This was the attack vector in the famous Capital One breach. |
| **Unrestricted egress** | If the server is compromised, attackers can freely exfiltrate data to any destination. Makes it harder to detect and contain breaches. |

### AI-Recommended Changes Applied

1. **SSH Access Restriction**
   ```hcl
   # BEFORE (vulnerable)
   cidr_blocks = ["0.0.0.0/0"]
   
   # AFTER (secure)
   cidr_blocks = var.allowed_ssh_cidr_blocks  # ["10.0.0.0/8"]
   ```

2. **EBS Encryption**
   ```hcl
   # BEFORE (vulnerable)
   encrypted = false
   
   # AFTER (secure)
   encrypted  = true
   kms_key_id = aws_kms_key.ebs.arn
   ```

3. **IMDSv2 Enforcement**
   ```hcl
   # BEFORE (vulnerable)
   http_tokens = "optional"
   
   # AFTER (secure)
   http_tokens = "required"
   ```

4. **Egress Rules**
   ```hcl
   # BEFORE (vulnerable)
   protocol    = "-1"  # All traffic
   cidr_blocks = ["0.0.0.0/0"]
   
   # AFTER (secure) - Separate rules for specific ports
   egress { port = 443 }  # HTTPS
   egress { port = 80 }   # HTTP
   egress { port = 53 }   # DNS
   ```

---

## 📸 Screenshots

### 1. Jenkins Pipeline Success
*[Add screenshot of successful Jenkins pipeline run]*

### 2. Initial Failing Security Scan (Vulnerable)
*[Add screenshot of Trivy detecting vulnerabilities in terraform-vulnerable/]*

### 3. Final Passing Security Scan (Secure)
*[Add screenshot of Trivy with fewer issues on terraform/]*

### 4. Application Running on AWS Public IP
*[Add screenshot of the application running at http://PUBLIC_IP:5000]*

---

## 🎥 Video Recording

**Demo Video Link:** *[Add your 5-10 minute video link here]*

The video should demonstrate:
- ✅ Jenkins pipeline execution
- ✅ Security scans (before and after)
- ✅ Terraform deployment to AWS
- ✅ Application running on AWS public IP

---

## 🚀 Deployment Commands Summary

```bash
# 1. Run app locally
docker-compose up -d --build

# 2. Start Jenkins
docker-compose -f docker-compose.jenkins.yml up -d

# 3. Run security scan
trivy config terraform-vulnerable/ --severity HIGH,CRITICAL

# 4. Deploy to AWS
cd terraform
terraform init
terraform plan
terraform apply

# 5. Cleanup
terraform destroy
```

---

## 📄 License

MIT License - For educational purposes.

---

## 👨‍💻 Author

**DevSecOps Assignment**  
Submitted by: meet1785  
Repository: https://github.com/meet1785/LenDen-Ass