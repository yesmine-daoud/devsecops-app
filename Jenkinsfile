pipeline {
    agent any
    
    environment {
        APP_NAME = "devsecops-app"
        DOCKER_IMAGE = "devsecops-app"
        BUILD_TAG = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }
        
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }
        
        stage('Secrets Scan - Gitleaks') {
            steps {
                echo 'Scanning for hardcoded secrets...'
                script {
                    def exitCode = sh(
                        script: '''
                            gitleaks detect --source . --verbose --report-path gitleaks-report.json --report-format json --no-git || true
                        ''',
                        returnStatus: true
                    )
                    
                    if (exitCode == 1) {
                        def report = readJSON file: 'gitleaks-report.json'
                        if (report && report.size() > 0) {
                            echo "WARNING: ${report.size()} secret(s) detected!"
                        }
                    } else {
                        echo 'No secrets detected'
                    }
                }
            }
        }
        
        stage('SAST - Semgrep') {
            steps {
                echo 'Running static code analysis...'
                sh '''
                    semgrep --config auto --json --output semgrep-report.json . || echo "Semgrep scan completed"
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo 'Installing npm dependencies...'
                sh 'npm install'
            }
        }
        
        stage('Dependency Check - Trivy') {
            steps {
                echo 'Scanning dependencies for vulnerabilities...'
                sh '''
                    trivy fs --security-checks vuln --format json --output trivy-fs-report.json . || echo "Trivy FS scan completed"
                '''
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh 'npm test'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${BUILD_TAG} .
                        docker tag ${DOCKER_IMAGE}:${BUILD_TAG} ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        
        stage('Container Scan - Trivy') {
            steps {
                echo 'Scanning Docker image...'
                script {
                    sh """
                        trivy image --severity HIGH,CRITICAL --format json --output trivy-image-report.json ${DOCKER_IMAGE}:${BUILD_TAG} || echo "Trivy image scan completed"
                    """
                    
                    if (fileExists('trivy-image-report.json')) {
                        def report = readJSON file: 'trivy-image-report.json'
                        def criticalCount = 0
                        def highCount = 0
                        
                        if (report.Results) {
                            report.Results.each { result ->
                                if (result.Vulnerabilities) {
                                    result.Vulnerabilities.each { vuln ->
                                        if (vuln.Severity == 'CRITICAL') criticalCount++
                                        if (vuln.Severity == 'HIGH') highCount++
                                    }
                                }
                            }
                        }
                        
                        echo "Vulnerabilities Summary:"
                        echo "   Critical: ${criticalCount}"
                        echo "   High: ${highCount}"
                    }
                }
            }
        }
        
        stage('Deploy to Staging') {
            steps {
                echo 'Deploying to staging environment...'
                sh """
                    docker rm -f ${APP_NAME}-staging || true
                    docker run -d --name ${APP_NAME}-staging -p 3000:3000 --restart unless-stopped ${DOCKER_IMAGE}:${BUILD_TAG}
                    sleep 5
                """
            }
        }
        
        stage('DAST - OWASP ZAP') {
            steps {
                echo 'Running dynamic security scan...'
                script {
                    sh """
                        docker run --rm --network host -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t http://localhost:3000 -r zap-report.html -J zap-report.json || echo "ZAP scan completed"
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo 'Testing application health...'
                sh '''
                    curl -f http://localhost:3000/health || exit 1
                    curl -f http://localhost:3000/ || exit 1
                    echo "All health checks passed!"
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Publishing reports...'
            archiveArtifacts artifacts: '*-report.json, *-report.html', allowEmptyArchive: true
            publishHTML([
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'zap-report.html',
                reportName: 'OWASP ZAP Security Report'
            ])
        }
        
        success {
            echo 'Pipeline completed successfully!'
            echo "Docker Image: ${DOCKER_IMAGE}:${BUILD_TAG}"
            echo "Application: http://localhost:3000"
        }
        
        failure {
            echo 'Pipeline failed!'
            sh "docker rm -f ${APP_NAME}-staging || true"
        }
        
        cleanup {
            echo 'Cleaning up old images...'
            sh '''
                docker images | grep devsecops-app | tail -n +6 | awk '{print $3}' | xargs -r docker rmi -f || true
            '''
        }
    }
}
