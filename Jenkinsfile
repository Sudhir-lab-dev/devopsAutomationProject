pipeline {
    agent any

    environment {
        APP_NAME = 'automation-devops-project'
        IMAGE_NAME = 'automation-devops-project'
        CONTAINER_NAME = 'automation-devops-app'
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Environment') {
            steps {
                sh '''
                node -v
                npm -v
                git --version
                docker --version
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Build TypeScript') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Stop Old Container') {
            steps {
                sh '''
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true
                '''
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                docker run -d \
                    --name ${CONTAINER_NAME} \
                    -p 3001:3000 \
                    ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                sleep 10
                curl http://host.docker.internal:3001/health
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Docker Deployment Successful'
        }

        failure {
            echo '❌ Deployment Failed'
        }

        always {
            cleanWs()
        }
    }
}
