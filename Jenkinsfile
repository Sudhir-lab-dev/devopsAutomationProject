pipeline {
    agent any

    environment {
        APP_NAME = 'automation-devops-project'
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

        stage('Verify Docker Access') {
            steps {
                sh '''
            echo "=== Docker Version ==="
            docker --version

            echo "=== Docker Containers ==="
            docker ps

            echo "=== Docker Images ==="
            docker images
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
    }

    post {
        success {
            echo '✅ Build completed successfully.'
        }

        failure {
            echo '❌ Build failed.'
        }

        always {
            cleanWs()
        }
    }
}
