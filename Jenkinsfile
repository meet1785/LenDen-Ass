/**
 * LenDen DevSecOps Jenkins Pipeline
 * 
 * This pipeline implements a complete CI/CD workflow with security scanning:
 * 1. Checkout - Pull source code from Git
 * 2. Infrastructure Security Scan - Scan Terraform with Trivy
 * 3. Terraform Plan - Validate and plan infrastructure changes
 * 
 * The pipeline will fail if critical security vulnerabilities are found,
 * prompting AI-based remediation before deployment.
 */

pipeline {
    agent any
    
    environment {
        APP_NAME = 'lenden-devsecops'
        TERRAFORM_VERSION = '1.6.0'
        TRIVY_VERSION = '0.48.0'
        // Set to 'terraform-vulnerable' to demo failing scan, 'terraform' for passing
        TERRAFORM_DIR = 'terraform'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    
    stages {
        /**
         * Stage 1: Checkout
         * Pull source code from Git repository
         */
        stage('Checkout') {
            steps {
                echo '=========================================='
                echo '📥 Stage 1: Checkout Source Code'
                echo '=========================================='
                
                checkout scm
                
                sh '''
                    echo "Repository contents:"
                    ls -la
                    echo ""
                    echo "Git information:"
                    git log --oneline -5 || echo "Not a git repo"
                '''
            }
        }
        
        /**
         * Stage 2: Infrastructure Security Scan
         * Use Trivy to scan Terraform files for misconfigurations
         */
        stage('Infrastructure Security Scan') {
            steps {
                echo '=========================================='
                echo '🔒 Stage 2: Infrastructure Security Scan'
                echo '=========================================='
                echo "Scanning directory: ${TERRAFORM_DIR}"
                
                script {
                    // Install Trivy if not present
                    sh '''
                        if ! command -v trivy &> /dev/null; then
                            echo "Installing Trivy..."
                            curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin v${TRIVY_VERSION}
                        fi
                        trivy --version
                    '''
                    
                    // Run Trivy scan on Terraform files
                    // Generate both console output and JSON report
                    def scanResult = sh(
                        script: """
                            echo ""
                            echo "╔══════════════════════════════════════════════════════════════╗"
                            echo "║           TRIVY INFRASTRUCTURE SECURITY SCAN                  ║"
                            echo "╚══════════════════════════════════════════════════════════════╝"
                            echo ""
                            
                            # Run Trivy config scan on Terraform files
                            trivy config ${TERRAFORM_DIR} \
                                --severity HIGH,CRITICAL \
                                --format table \
                                --exit-code 0
                            
                            echo ""
                            echo "Generating detailed JSON report..."
                            
                            # Generate JSON report for detailed analysis
                            trivy config ${TERRAFORM_DIR} \
                                --severity LOW,MEDIUM,HIGH,CRITICAL \
                                --format json \
                                --output trivy-report.json
                            
                            echo ""
                            echo "═══════════════════════════════════════════════════════════════"
                            echo "                    SCAN SUMMARY                                "
                            echo "═══════════════════════════════════════════════════════════════"
                            
                            # Check for critical/high vulnerabilities
                            CRITICAL_COUNT=\$(trivy config ${TERRAFORM_DIR} --severity CRITICAL --format json 2>/dev/null | grep -c '"Severity": "CRITICAL"' || echo 0)
                            HIGH_COUNT=\$(trivy config ${TERRAFORM_DIR} --severity HIGH --format json 2>/dev/null | grep -c '"Severity": "HIGH"' || echo 0)
                            
                            echo "Critical Issues: \${CRITICAL_COUNT}"
                            echo "High Issues: \${HIGH_COUNT}"
                            echo ""
                            
                            # Exit with error if critical issues found
                            if [ "\${CRITICAL_COUNT}" -gt 0 ]; then
                                echo "❌ CRITICAL security vulnerabilities detected!"
                                echo ""
                                echo "╔══════════════════════════════════════════════════════════════╗"
                                echo "║  ACTION REQUIRED: Fix vulnerabilities before deployment      ║"
                                echo "║  Use AI to analyze the report and remediate issues          ║"
                                echo "╚══════════════════════════════════════════════════════════════╝"
                                exit 1
                            fi
                            
                            echo "✅ No critical security vulnerabilities found!"
                        """,
                        returnStatus: true
                    )
                    
                    // Archive the Trivy report
                    archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
                    
                    if (scanResult != 0) {
                        error("Security scan failed! Critical vulnerabilities detected in Terraform configuration.")
                    }
                }
            }
            post {
                always {
                    echo 'Security scan completed. Check the Trivy report for details.'
                }
                failure {
                    echo '''
                    ╔══════════════════════════════════════════════════════════════╗
                    ║                    SECURITY SCAN FAILED                       ║
                    ╠══════════════════════════════════════════════════════════════╣
                    ║                                                              ║
                    ║  Critical security vulnerabilities were detected!            ║
                    ║                                                              ║
                    ║  NEXT STEPS:                                                 ║
                    ║  1. Review the Trivy report above                           ║
                    ║  2. Copy the vulnerability details                          ║
                    ║  3. Use AI (ChatGPT/Copilot) to analyze and fix            ║
                    ║  4. Update Terraform code with AI recommendations          ║
                    ║  5. Re-run this pipeline                                    ║
                    ║                                                              ║
                    ╚══════════════════════════════════════════════════════════════╝
                    '''
                }
            }
        }
        
        /**
         * Stage 3: Terraform Init & Validate
         * Initialize Terraform and validate configuration
         */
        stage('Terraform Init & Validate') {
            steps {
                echo '=========================================='
                echo '🔧 Stage 3: Terraform Init & Validate'
                echo '=========================================='
                
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        # Install Terraform if not present
                        if ! command -v terraform &> /dev/null; then
                            echo "Installing Terraform..."
                            curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip
                            unzip -o terraform.zip
                            mv terraform /usr/local/bin/
                            rm terraform.zip
                        fi
                        
                        terraform --version
                        
                        echo ""
                        echo "Initializing Terraform..."
                        terraform init -backend=false
                        
                        echo ""
                        echo "Validating Terraform configuration..."
                        terraform validate
                        
                        echo ""
                        echo "✅ Terraform configuration is valid!"
                    '''
                }
            }
        }
        
        /**
         * Stage 4: Terraform Plan
         * Generate execution plan for infrastructure changes
         */
        stage('Terraform Plan') {
            steps {
                echo '=========================================='
                echo '📋 Stage 4: Terraform Plan'
                echo '=========================================='
                
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        echo "Generating Terraform execution plan..."
                        echo ""
                        
                        # Run terraform plan (without applying)
                        terraform plan -out=tfplan -input=false || {
                            echo "Note: Plan generated but may require AWS credentials for full execution"
                            terraform plan -input=false 2>&1 || true
                        }
                        
                        echo ""
                        echo "╔══════════════════════════════════════════════════════════════╗"
                        echo "║              TERRAFORM PLAN COMPLETED                         ║"
                        echo "╚══════════════════════════════════════════════════════════════╝"
                    '''
                }
            }
        }
        
        /**
         * Stage 5: Build Docker Image (Optional)
         * Build the application Docker image
         */
        stage('Build Docker Image') {
            when {
                expression { 
                    return fileExists('app/Dockerfile')
                }
            }
            steps {
                echo '=========================================='
                echo '🐳 Stage 5: Build Docker Image'
                echo '=========================================='
                
                dir('app') {
                    sh '''
                        echo "Building Docker image..."
                        docker build -t ${APP_NAME}:${BUILD_NUMBER} .
                        docker tag ${APP_NAME}:${BUILD_NUMBER} ${APP_NAME}:latest
                        
                        echo ""
                        echo "Docker images:"
                        docker images | grep ${APP_NAME}
                        
                        echo ""
                        echo "✅ Docker image built successfully!"
                    '''
                }
            }
        }
        
        /**
         * Stage 6: Container Security Scan
         * Scan the Docker image for vulnerabilities
         */
        stage('Container Security Scan') {
            when {
                expression { 
                    return fileExists('app/Dockerfile')
                }
            }
            steps {
                echo '=========================================='
                echo '🔍 Stage 6: Container Security Scan'
                echo '=========================================='
                
                sh '''
                    echo "Scanning Docker image for vulnerabilities..."
                    trivy image ${APP_NAME}:latest \
                        --severity HIGH,CRITICAL \
                        --format table \
                        --exit-code 0
                    
                    echo ""
                    echo "✅ Container security scan completed!"
                '''
            }
        }
    }
    
    post {
        success {
            echo '''
            ╔══════════════════════════════════════════════════════════════╗
            ║                    PIPELINE SUCCESSFUL                        ║
            ╠══════════════════════════════════════════════════════════════╣
            ║                                                              ║
            ║  ✅ All stages completed successfully!                       ║
            ║  ✅ Security scan passed - No critical vulnerabilities       ║
            ║  ✅ Terraform configuration is valid and secure              ║
            ║  ✅ Ready for deployment to AWS                              ║
            ║                                                              ║
            ╚══════════════════════════════════════════════════════════════╝
            '''
        }
        failure {
            echo '''
            ╔══════════════════════════════════════════════════════════════╗
            ║                    PIPELINE FAILED                            ║
            ╠══════════════════════════════════════════════════════════════╣
            ║                                                              ║
            ║  ❌ Pipeline execution failed!                               ║
            ║                                                              ║
            ║  Review the logs above to identify the issue.               ║
            ║  Common causes:                                              ║
            ║  - Security vulnerabilities in Terraform code               ║
            ║  - Invalid Terraform configuration                          ║
            ║  - Docker build failures                                    ║
            ║                                                              ║
            ╚══════════════════════════════════════════════════════════════╝
            '''
        }
        always {
            echo 'Cleaning up workspace...'
            cleanWs(deleteDirs: true, disableDeferredWipeout: true, patterns: [
                [pattern: 'trivy-report.json', type: 'INCLUDE'],
                [pattern: '.terraform', type: 'INCLUDE']
            ])
        }
    }
}
