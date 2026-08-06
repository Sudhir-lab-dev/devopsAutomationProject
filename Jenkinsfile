pipeline {
    agent any

    environment {
        IMAGE_NAME = 'automation-devops-project'
        CONTAINER_NAME = 'automation-devops-app'

        IMAGE_TAG = "${BUILD_NUMBER}"

        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '218589468002'

        ECR_REPOSITORY = 'automation-devops-project'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

        APP_SERVER_USER = 'ec2-user'
        APP_SERVER_HOST = '44.206.110.223'

        DOCKER_BUILDKIT = '1'
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
                aws --version
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

        stage('Publish Test Results') {
            steps {
                junit 'reports/junit/junit.xml'
            }
        }

        stage('Login to AWS ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr-credentials'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION \
                    | docker login \
                    --username AWS \
                    --password-stdin $ECR_REGISTRY
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build --pull \
                -t $IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh '''
                docker tag $IMAGE_NAME:$IMAGE_TAG \
                $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

                docker tag $IMAGE_NAME:$IMAGE_TAG \
                $ECR_REGISTRY/$ECR_REPOSITORY:latest
                '''
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh '''
                docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
                docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest
                '''
            }
        }

        stage('Deploy to Application EC2') {
            steps {
                sh '''
                ssh -o BatchMode=yes -o StrictHostKeyChecking=no \
                $APP_SERVER_USER@$APP_SERVER_HOST << EOF

                aws ecr get-login-password --region $AWS_REGION \
                | docker login \
                --username AWS \
                --password-stdin $ECR_REGISTRY

                docker pull $ECR_REGISTRY/$ECR_REPOSITORY:latest

                docker stop $CONTAINER_NAME || true
                docker rm $CONTAINER_NAME || true

                docker run -d \
                  --name $CONTAINER_NAME \
                  --restart unless-stopped \
                  -p 3001:3000 \
                  $ECR_REGISTRY/$ECR_REPOSITORY:latest

                sleep 10

                curl http://localhost:3001/api/health

                EOF
                '''
            }
        }

        stage('Cleanup Local Images') {
            steps {
                sh '''
                docker image rm \
                $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG || true

                docker image rm \
                $IMAGE_NAME:$IMAGE_TAG || true

                docker image prune -f
                '''
            }
        }
    }

    post {
        success {
            echo '======================================'
            echo 'Deployment Successful'
            echo "Image Tag : ${IMAGE_TAG}"
            echo "Application deployed to ${APP_SERVER_HOST}"
            echo '======================================'
        }

        failure {
            echo 'Pipeline Failed'
        }

        always {
            cleanWs()
        }
    }
}
