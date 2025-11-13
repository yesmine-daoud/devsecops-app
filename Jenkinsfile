pipeline {
    agent any

    environment {
        PROJECT_DIR = '/vagrant/devsecops-app'
        REPORTS_DIR = '/home/vagrant/reports'   // ✅ changé ici
        SEMGREP_HOME = '/home/vagrant/.semgrep'
        ZAP_PORT = '8090'
        SONAR_HOST = 'http://192.168.56.10:9000'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/yesmine-daoud/devsecops-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("${PROJECT_DIR}") {
                    sh 'docker build -t devsecops-app .'
                }
            }
        }

        stage('Static Analysis') {
            steps {
                dir("${PROJECT_DIR}") {
                    sh 'mkdir -p ${REPORTS_DIR}'
                    sh 'export SEMGREP_HOME=${SEMGREP_HOME} && semgrep --config auto . --json > ${REPORTS_DIR}/semgrep-report.json'
                }
            }
        }

        stage('Vulnerability Scan') {
            steps {
                dir("${PROJECT_DIR}") {
                    sh 'trivy fs --exit-code 1 --format json --output ${REPORTS_DIR}/trivy-report.json .'
                }
            }
        }

        stage('DAST - ZAP Scan') {
            steps {
                sh 'zaproxy -daemon -port ${ZAP_PORT}'
                sh 'zap-cli -p ${ZAP_PORT} quick-scan http://localhost:8080'
                sh 'zap-cli -p ${ZAP_PORT} report -o ${REPORTS_DIR}/zap-report.html -f html'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'sonar-scanner -Dsonar.projectKey=devsecops-app -Dsonar.sources=${PROJECT_DIR} -Dsonar.host.url=${SONAR_HOST}'
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deployment stage (optionnel)'
            }
        }
    }

    post {
        always {
            echo 'Pipeline terminé. Les rapports sont dans /home/vagrant/reports'
        }
    }
}
