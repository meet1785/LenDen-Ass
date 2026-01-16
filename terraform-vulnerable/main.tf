# =============================================================================
# VULNERABLE TERRAFORM CONFIGURATION FOR AWS (INTENTIONAL - FOR SECURITY DEMO)
# =============================================================================
# ⚠️ WARNING: This configuration contains INTENTIONAL security vulnerabilities
# that will be detected by Trivy and fixed using AI-based remediation.
#
# VULNERABILITIES INCLUDED:
# 1. SSH (port 22) open to 0.0.0.0/0 (entire internet)
# 2. Unencrypted EBS root volume
# 3. IMDSv2 not enforced (vulnerable to SSRF attacks)
# 4. Overly permissive security group rules
# 5. HTTP exposed instead of HTTPS
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# =============================================================================
# VARIABLES
# =============================================================================

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "lenden-devsecops"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# =============================================================================
# DATA SOURCES
# =============================================================================

# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# VPC AND NETWORKING
# =============================================================================

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.environment
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.environment
  }
}

# Create Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet"
    Environment = var.environment
  }
}

# Create Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.app_name}-public-rt"
    Environment = var.environment
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# SECURITY GROUP - VULNERABLE CONFIGURATION
# =============================================================================

resource "aws_security_group" "web_server" {
  name        = "${var.app_name}-sg"
  description = "Security group for web server - VULNERABLE"
  vpc_id      = aws_vpc.main.id

  # ❌ VULNERABILITY 1: SSH open to entire internet (0.0.0.0/0)
  # This allows anyone on the internet to attempt SSH connections!
  ingress {
    description = "SSH from anywhere - VULNERABLE"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ❌ VULNERABILITY 2: HTTP open (should use HTTPS for production)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application port
  ingress {
    description = "Application port from anywhere"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ❌ VULNERABILITY 3: All outbound traffic allowed (overly permissive)
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-sg"
    Environment = var.environment
  }
}

# =============================================================================
# EC2 INSTANCE - VULNERABLE CONFIGURATION
# =============================================================================

resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web_server.id]
  associate_public_ip_address = true

  # ❌ VULNERABILITY 4: Root volume is NOT encrypted
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = false  # ❌ VULNERABILITY: Should be true!
  }

  # ❌ VULNERABILITY 5: IMDSv2 not enforced (allows SSRF attacks)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"  # ❌ VULNERABILITY: Should be "required"
    http_put_response_hop_limit = 2
  }

  # User data to install Docker and run the application
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -a -G docker ec2-user
              
              # Run the application container
              docker run -d -p 5000:5000 --name lenden-app \
                -e NODE_ENV=production \
                -e ENVIRONMENT=production \
                --restart unless-stopped \
                node:20-alpine sh -c "
                  mkdir -p /app && cd /app &&
                  echo 'const express = require(\"express\"); const app = express(); app.get(\"/\", (req, res) => res.send(\"<h1>LenDen DevSecOps App Running on AWS!</h1><p>Deployed via Terraform + Jenkins Pipeline</p>\")); app.get(\"/health\", (req, res) => res.json({status: \"healthy\", cloud: \"AWS\"})); app.listen(5000, () => console.log(\"Server running on port 5000\"));' > server.js &&
                  npm init -y && npm install express &&
                  node server.js
                "
              EOF

  tags = {
    Name        = "${var.app_name}-web-server"
    Environment = var.environment
    Application = "LenDen DevSecOps Demo"
  }
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web_server.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web_server.public_dns
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_instance.web_server.public_ip}:5000"
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i your-key.pem ec2-user@${aws_instance.web_server.public_ip}"
}
