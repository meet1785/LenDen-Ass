#!/bin/bash
docker-compose -f docker-compose.jenkins.yml up -d
echo "Jenkins starting at http://localhost:8080"
sleep 10
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Check logs for password"
