#!/bin/bash
cd terraform
terraform init
terraform plan
echo "Run 'terraform apply' to deploy"
