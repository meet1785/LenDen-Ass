#!/bin/bash
# =============================================================================
# Jenkins Setup Script
# This script starts Jenkins in Docker and displays setup instructions
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           LenDen DevSecOps - Jenkins Setup                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd "$PROJECT_DIR"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "📦 Building Jenkins Docker image..."
docker-compose -f docker-compose.jenkins.yml build

echo ""
echo "🚀 Starting Jenkins..."
docker-compose -f docker-compose.jenkins.yml up -d jenkins

echo ""
echo "⏳ Waiting for Jenkins to start (this may take a minute)..."
sleep 30

# Get initial admin password
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  JENKINS SETUP INSTRUCTIONS                   ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "1. Open Jenkins in your browser: http://localhost:8080"
echo ""
echo "2. Get the initial admin password:"

# Try to get the password
if docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
    echo ""
else
    echo "   Run: docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword"
fi

echo ""
echo "3. Complete the setup wizard:"
echo "   - Install suggested plugins"
echo "   - Create admin user"
echo ""
echo "4. Create a new Pipeline job:"
echo "   - Click 'New Item'"
echo "   - Enter name: 'lenden-devsecops'"
echo "   - Select 'Pipeline'"
echo "   - In Pipeline section, select 'Pipeline script from SCM'"
echo "   - SCM: Git"
echo "   - Repository URL: https://github.com/meet1785/LenDen-Ass.git"
echo "   - Branch: */main"
echo "   - Script Path: Jenkinsfile"
echo ""
echo "5. Run the pipeline and observe:"
echo "   - First run with vulnerable Terraform (will show warnings)"
echo "   - Fix using AI recommendations"
echo "   - Second run should pass"
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Jenkins is starting at: http://localhost:8080               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "To view logs: docker logs -f jenkins"
echo "To stop: docker-compose -f docker-compose.jenkins.yml down"
