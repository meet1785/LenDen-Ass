#!/bin/bash
# =============================================================================
# Run Trivy Security Scan Locally
# This script runs Trivy on both vulnerable and secure Terraform configurations
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           LenDen DevSecOps - Trivy Security Scan             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$PROJECT_DIR"

# Check if Trivy is installed
if ! command -v trivy &> /dev/null; then
    echo "Installing Trivy..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
fi

echo "Trivy version: $(trivy --version)"
echo ""

# Function to run scan
run_scan() {
    local dir=$1
    local name=$2
    
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Scanning: $name ($dir)"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    if [ -d "$dir" ]; then
        trivy config "$dir" \
            --severity LOW,MEDIUM,HIGH,CRITICAL \
            --format table
        
        echo ""
        
        # Count issues
        CRITICAL=$(trivy config "$dir" --severity CRITICAL --format json 2>/dev/null | grep -c '"Severity": "CRITICAL"' || echo 0)
        HIGH=$(trivy config "$dir" --severity HIGH --format json 2>/dev/null | grep -c '"Severity": "HIGH"' || echo 0)
        MEDIUM=$(trivy config "$dir" --severity MEDIUM --format json 2>/dev/null | grep -c '"Severity": "MEDIUM"' || echo 0)
        LOW=$(trivy config "$dir" --severity LOW --format json 2>/dev/null | grep -c '"Severity": "LOW"' || echo 0)
        
        echo "Summary for $name:"
        echo "  Critical: $CRITICAL"
        echo "  High: $HIGH"
        echo "  Medium: $MEDIUM"
        echo "  Low: $LOW"
        echo ""
    else
        echo "Directory $dir not found!"
    fi
}

# Scan vulnerable configuration
if [ -d "terraform-vulnerable" ]; then
    run_scan "terraform-vulnerable" "VULNERABLE Terraform"
fi

# Scan secure configuration
if [ -d "terraform" ]; then
    run_scan "terraform" "SECURE Terraform"
fi

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    SCAN COMPLETE                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Compare the results between vulnerable and secure configurations."
echo "The secure version should have significantly fewer issues."
