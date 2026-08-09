pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'

        ECR_REGISTRY = '218589468002.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY_NAME = 'automation-devops-project'
        ECR_REPOSITORY = "${ECR_REGISTRY}/${ECR_REPOSITORY_NAME}"

        APP_SERVER = '10.0.1.65'
        APP_USER = 'ec2-user'
        APP_CONTAINER = 'automation-app'
        APP_PORT = '3000'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Sudhir-lab-dev/devopsAutomationProject.git'
            }
        }

        stage('Verify Environment') {
            steps {
                sh '''
                    echo "======================================"
                    echo "Environment"
                    echo "======================================"

                    echo "Node:"
                    node --version

                    echo "NPM:"
                    npm --version

                    echo "Docker:"
                    docker --version

                    echo "AWS:"
                    aws --version

                    echo "Git:"
                    git --version
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Application') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    echo "======================================"
                    echo "Building Docker Image"
                    echo "======================================"

                    docker build \
                        -t ${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER} \
                        -t ${ECR_REPOSITORY}:latest \
                        .

                    echo "Docker build completed successfully."
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                    echo "======================================"
                    echo "Login to Amazon ECR"
                    echo "======================================"

                    aws ecr get-login-password \
                        --region ${AWS_REGION} | \
                    docker login \
                        --username AWS \
                        --password-stdin ${ECR_REGISTRY}

                    echo "======================================"
                    echo "Push Build Image"
                    echo "======================================"

                    docker push \
                        ${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER}

                    echo "======================================"
                    echo "Push Latest Image"
                    echo "======================================"

                    docker push \
                        ${ECR_REPOSITORY}:latest

                    echo "ECR push completed successfully."
                '''
            }
        }

        stage('Deploy to Application EC2') {
            steps {
                sh '''
                    echo "======================================"
                    echo "Deploying Application"
                    echo "======================================"

                    ssh -i /var/lib/jenkins/.ssh/id_ed25519 \
                        -o StrictHostKeyChecking=yes \
                        ${APP_USER}@${APP_SERVER} "

                        set -e

                        echo 'Logging in to Amazon ECR...'

                        aws ecr get-login-password \
                            --region ${AWS_REGION} | \
                        docker login \
                            --username AWS \
                            --password-stdin ${ECR_REGISTRY}

                        echo 'Pulling latest image...'

                        docker pull ${ECR_REPOSITORY}:latest

                        echo 'Stopping existing container...'

                        docker stop ${APP_CONTAINER} 2>/dev/null || true

                        echo 'Removing existing container...'

                        docker rm ${APP_CONTAINER} 2>/dev/null || true

                        echo 'Starting new container...'

                        docker run -d \
                            --name ${APP_CONTAINER} \
                            --restart unless-stopped \
                            -p ${APP_PORT}:${APP_PORT} \
                            ${ECR_REPOSITORY}:latest

                        echo 'Waiting for application to start...'

                        sleep 10

                        echo 'Container status:'

                        docker ps \
                            --filter name=${APP_CONTAINER}

                        echo 'Deployment completed successfully.'
                    "
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    echo "======================================"
                    echo "Application Health Check"
                    echo "======================================"

                    ssh -i /var/lib/jenkins/.ssh/id_ed25519 \
                        -o StrictHostKeyChecking=yes \
                        ${APP_USER}@${APP_SERVER} \
                        "curl -f http://localhost:${APP_PORT}/api/health"

                    echo ""
                    echo "Health check passed successfully."
                '''
            }
        }
    }

    post {
        success {
            echo '======================================'
            echo 'CI/CD pipeline completed successfully!'
            echo "Application deployed to ${APP_SERVER}:${APP_PORT}"
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'CI/CD pipeline failed.'
            echo 'Check the stage logs.'
            echo '======================================'
        }

        always {
            echo "Pipeline finished. Build number: ${BUILD_NUMBER}"
        }
    }
}
