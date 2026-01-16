# 🤖 GenAI Usage Report

## Assignment Requirement
> **"Use AI to analyze the security report, explain the risks, and rewrite the code to fix the vulnerabilities."**

---

## 1. Security Scan Output (Input to AI)

The following Trivy scan results were provided to the AI for analysis:

```
Trivy Scan Results on terraform-vulnerable/main.tf

Tests: 8 (SUCCESSES: 1, FAILURES: 7)
Failures: 7 (HIGH: 3, CRITICAL: 4)

CRITICAL: Security group rule allows egress to multiple public internet addresses.
├── File: main.tf:187
├── Resource: aws_security_group.web_server
└── Issue: cidr_blocks = ["0.0.0.0/0"]

CRITICAL: Security group rule allows ingress from public internet.
├── File: main.tf:160, 169, 178
├── Resource: aws_security_group.web_server  
└── Issue: cidr_blocks = ["0.0.0.0/0"] for SSH, HTTPS, App ports

HIGH: Instance does not require IMDS access to require a token
├── File: main.tf:218
├── Resource: aws_instance.web_server
└── Issue: http_tokens = "optional"

HIGH: Root block device is not encrypted.
├── File: main.tf:212
├── Resource: aws_instance.web_server
└── Issue: encrypted = false

HIGH: Subnet associates public IP address.
├── File: main.tf:115
├── Resource: aws_subnet.public
└── Issue: map_public_ip_on_launch = true
```

---

## 2. Prompt Used to AI

```
I have a Terraform configuration for AWS that was scanned by Trivy and 
found the following security vulnerabilities:

1. AVD-AWS-0107 (CRITICAL): SSH port 22 is open to 0.0.0.0/0
2. AVD-AWS-0104 (CRITICAL): Security group allows unrestricted egress to 0.0.0.0/0
3. AVD-AWS-0131 (HIGH): EBS root volume is not encrypted
4. AVD-AWS-0028 (HIGH): IMDSv2 is not required (http_tokens = "optional")
5. AVD-AWS-0164 (HIGH): Subnet auto-assigns public IPs

Please:
1. Explain each vulnerability and its security risk
2. Provide the corrected Terraform code that fixes all issues
```

---

## 3. AI Response - Risk Explanation

| Vulnerability ID | Severity | Risk Explanation |
|-----------------|----------|------------------|
| **AVD-AWS-0107** | CRITICAL | SSH port open to 0.0.0.0/0 allows anyone on the internet to attempt brute-force attacks. Attackers run automated bots scanning for open port 22. |
| **AVD-AWS-0104** | CRITICAL | Unrestricted egress allows compromised servers to exfiltrate data to any destination. Makes breach detection and containment difficult. |
| **AVD-AWS-0131** | HIGH | Unencrypted EBS means data at rest is not protected. Violates compliance requirements (HIPAA, PCI-DSS, SOC2). |
| **AVD-AWS-0028** | HIGH | IMDSv2 not enforced allows SSRF attacks to steal IAM credentials from EC2 metadata service. This was the attack vector in the Capital One breach. |
| **AVD-AWS-0164** | HIGH | Auto-assigning public IPs exposes resources directly to the internet, increasing attack surface. |

---

## 4. AI Response - Code Fixes

### Fix 1: Restrict SSH Access
```hcl
# BEFORE (vulnerable)
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # ❌ Open to entire internet
}

# AFTER (secure) - AI Recommendation
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.allowed_ssh_cidr_blocks  # ✅ Restricted to private networks
}

variable "allowed_ssh_cidr_blocks" {
  default = ["10.0.0.0/8"]  # Private network only
}
```

### Fix 2: Restrict Egress to VPC CIDR
```hcl
# BEFORE (vulnerable)
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]  # ❌ Unrestricted egress
}

# AFTER (secure) - AI Recommendation
egress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/16"]  # ✅ VPC CIDR only
}
```

### Fix 3: Enable EBS Encryption
```hcl
# BEFORE (vulnerable)
root_block_device {
  volume_size = 20
  encrypted   = false  # ❌ Not encrypted
}

# AFTER (secure) - AI Recommendation
root_block_device {
  volume_size = 20
  encrypted   = true              # ✅ Encrypted
  kms_key_id  = aws_kms_key.ebs.arn
}
```

### Fix 4: Enforce IMDSv2
```hcl
# BEFORE (vulnerable)
metadata_options {
  http_tokens = "optional"  # ❌ IMDSv1 allowed (vulnerable to SSRF)
}

# AFTER (secure) - AI Recommendation
metadata_options {
  http_tokens = "required"  # ✅ Only IMDSv2 allowed
}
```

### Fix 5: Disable Auto-Assign Public IP
```hcl
# BEFORE (vulnerable)
resource "aws_subnet" "public" {
  map_public_ip_on_launch = true  # ❌ Auto-assigns public IP
}

# AFTER (secure) - AI Recommendation
resource "aws_subnet" "public" {
  map_public_ip_on_launch = false  # ✅ No auto-assign
}
```

---

## 5. Result After AI Remediation

After applying AI-recommended fixes, Trivy scan shows:

```
Report Summary
┌─────────┬───────────┬───────────────────┐
│ Target  │   Type    │ Misconfigurations │
├─────────┼───────────┼───────────────────┤
│ main.tf │ terraform │         0         │
└─────────┴───────────┴───────────────────┘

✅ No HIGH or CRITICAL security findings detected
```

---

## 6. AI Tool Used

- **Tool**: GitHub Copilot (Claude Opus 4.5)
- **Date**: January 16, 2026
- **Purpose**: Analyze Trivy security scan output and provide remediated Terraform code
