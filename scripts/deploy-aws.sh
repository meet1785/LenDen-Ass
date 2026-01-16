#!/bin/bash
# =============================================================================
# Deploy to AWS Script
# This script deploys the infrastructure to AWS using Terraform
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_DIR/terraform"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           LenDen DevSecOps - AWS Deployment                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check AWS credentials
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "⚠️  AWS credentials not found in environment variables."
    echo ""
    echo "Please set your AWS credentials:"
    echo "  export AWS_ACCESS_KEY_ID=your_access_key"
    echo "  export AWS_SECRET_ACCESS_KEY=your_secret_key"
    echo "  export AWS_DEFAULT_REGION=us-east-1"
    echo ""
    echo "Or configure AWS CLI: aws configure"
    exit 1
fi

echo "✅ AWS credentials found"
echo ""

cd "$TERRAFORM_DIR"

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Validate configuration
echo ""
echo "🔍 Validating Terraform configuration..."
terraform validate

# Plan deployment
echo ""
echo "📋 Creating deployment plan..."
terraform plan -out=tfplan

# Confirm deployment
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   DEPLOYMENT CONFIRMATION                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
read -p "Do you want to apply this plan? (yes/no): " CONFIRM

if [ "$CONFIRM" = "yes" ]; then
    echo ""
    echo "🚀 Deploying infrastructure..."
    terraform apply tfplan
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  DEPLOYMENT COMPLETE                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Outputs:"
    terraform output
    
    echo ""
    echo "Your application should be accessible at the public IP above."
    echo "It may take a few minutes for the instance to fully initialize."
else
    echo "Deployment cancelled."
fi
