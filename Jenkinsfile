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

        stage('ESLint') {
            steps {
                sh 'npm run lint'
            }
        }

        stage('Build TypeScript') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $IMAGE_NAME:latest .
                '''
            }
        }

        stage('Stop Old Container') {
            steps {
                sh '''
                docker stop $CONTAINER_NAME || true
                docker rm $CONTAINER_NAME || true
                '''
            }
        }

        stage('Run Docker Container') {
            steps {
                sh '''
                docker run -d \
                  --name $CONTAINER_NAME \
                  -p 3001:3000 \
                  $IMAGE_NAME:latest
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                echo "Waiting for application to start..."
                sleep 10

                STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://host.docker.internal:3001/api/health)

                if [ "$STATUS" != "200" ]; then
                    echo "Application health check failed with HTTP $STATUS"
                    exit 1
                fi

                echo "Application is healthy."
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
