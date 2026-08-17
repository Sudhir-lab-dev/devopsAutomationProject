pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'

        ECR_REGISTRY = '218589468002.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY_NAME = 'automation-devops-project'
        ECR_REPOSITORY = "${ECR_REGISTRY}/${ECR_REPOSITORY_NAME}"

        APP_SERVER = '10.0.1.109'
        APP_USER = 'ec2-user'
        APP_CONTAINER = 'automation-app'
        APP_PORT = '3000'

        S3_BUCKET_NAME = 'automation-devops-project-screenshots-218589468002'
    }

    stages {
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

        stage('Deploy to EKS') {
            steps {
                sh '''
            echo "======================================"
            echo "Deploying Application to EKS"
            echo "======================================"

            echo "EKS Image:"
            echo "${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER}"

            ssh -i /var/lib/jenkins/.ssh/id_ed25519 \
                -o StrictHostKeyChecking=yes \
                ${APP_USER}@${APP_SERVER} "

                set -e

                echo 'Updating EKS deployment image...'

                kubectl set image deployment/automation-app \
                    automation-app=${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER}

                echo 'Waiting for rollout to complete...'

                kubectl rollout status deployment/automation-app \
                    --timeout=5m

                echo 'Deployment rollout successful.'

                echo 'Current deployment image:'

                kubectl get deployment automation-app \
                    -o jsonpath='{.spec.template.spec.containers[0].image}'

                echo ''

            "
        '''
            }
        }

        stage('Verify EKS Deployment') {
            steps {
                sh '''
            echo "======================================"
            echo "Verifying EKS Deployment"
            echo "======================================"

            EXPECTED_IMAGE="${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER}"

            echo "Expected image:"
            echo "${EXPECTED_IMAGE}"

            ssh -i /var/lib/jenkins/.ssh/id_ed25519 \
                -o StrictHostKeyChecking=yes \
                ${APP_USER}@${APP_SERVER} "

                set -e

                echo 'Deployment:'
                kubectl get deployment automation-app -o wide

                echo ''
                echo 'Pod:'
                kubectl get pods -l app=automation-app -o wide

                echo ''
                echo 'Running image:'

                ACTUAL_IMAGE=\$(kubectl get deployment automation-app \
                    -o jsonpath='{.spec.template.spec.containers[0].image}')

                echo \${ACTUAL_IMAGE}

                echo ''
                echo 'Expected image:'
                echo '${EXPECTED_IMAGE}'

                if [ \\"\${ACTUAL_IMAGE}\\" != \\"${EXPECTED_IMAGE}\\" ]; then
                    echo 'ERROR: EKS is not running the expected Jenkins image.'
                    exit 1
                fi

                echo ''
                echo 'EKS image verification passed.'

            "
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
                            -e AWS_REGION=${AWS_REGION} \
                            -e S3_BUCKET_NAME=${S3_BUCKET_NAME} \
                            ${ECR_REPOSITORY}:latest

                        echo 'Waiting for application to start...'

                        sleep 10

                        echo 'Container status:'

                        docker ps \
                            --filter name=${APP_CONTAINER}

                        echo 'Checking container is running...'

                        if ! docker ps --format '{{.Names}}' | grep -q '^${APP_CONTAINER}$'; then
                            echo 'ERROR: Application container is not running.'
                            echo 'Container logs:'
                            docker logs ${APP_CONTAINER} || true
                            exit 1
                        fi

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

        stage('Cleanup Old Docker Images') {
            steps {
                sh '''
                    echo "======================================"
                    echo "Cleaning Old Docker Images"
                    echo "======================================"

                    ssh -i /var/lib/jenkins/.ssh/id_ed25519 \
                        -o StrictHostKeyChecking=yes \
                        ${APP_USER}@${APP_SERVER} "

                        echo 'Docker disk usage before cleanup:'
                        docker system df

                        echo 'Removing unused Docker images...'

                        docker image prune -af

                        echo 'Docker disk usage after cleanup:'
                        docker system df

                        echo 'Disk usage:'
                        df -h

                    "
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
