pipeline {
    agent any

    environment {
        SEMGREP_HOME = '/vagrant/.semgrep'
        REPORT_DIR   = '/vagrant/reports'
    }

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("${WORKSPACE}") {
                    sh 'docker build -t devsecops-app .'
                }
            }
        }

        stage('Static Analysis') {
            steps {
                dir("${WORKSPACE}") {
                    sh '''
                    mkdir -p $REPORT_DIR
                    semgrep --config auto . --json > $REPORT_DIR/semgrep-report.json
                    '''
                }
            }
        }

        stage('Vulnerability Scan') {
            steps {
                dir("${WORKSPACE}") {
                    sh '''
                    echo "Vulnerability Scan stage placeholder"
                    # Ex: trivy fs --exit-code 1 --no-progress --format json -o $REPORT_DIR/trivy-report.json .
                    '''
                }
            }
        }

        stage('DAST - ZAP Scan') {
            steps {
                dir("${WORKSPACE}") {
                    sh '''
                    echo "DAST Scan placeholder"
                    # Ex: zap-cli quick-scan --self-contained -r $REPORT_DIR/zap-report.html http://localhost:3000
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir("${WORKSPACE}") {
                    sh '''
                    echo "SonarQube Analysis placeholder"
                    # Ex: sonar-scanner -Dsonar.projectKey=devsecops-app -Dsonar.sources=. -Dsonar.host.url=http://localhost:9000 -Dsonar.login=YOUR_TOKEN
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                dir("${WORKSPACE}") {
                    sh '''
                    echo "Deploy stage placeholder"
                    # Ex: docker run -d -p 3000:3000 devsecops-app
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline terminé. Les rapports sont dans le dossier $REPORT_DIR'
        }
    }
}
