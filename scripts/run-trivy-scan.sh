#!/bin/bash
echo "Scanning vulnerable terraform..."
trivy config terraform-vulnerable/ --severity HIGH,CRITICAL
echo ""
echo "Scanning secure terraform..."
trivy config terraform/ --severity HIGH,CRITICAL
