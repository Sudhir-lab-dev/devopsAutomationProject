pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY = 'automation-devops-project'
        AWS_ACCOUNT_ID = '218589468002'

        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_NAME = "${ECR_REGISTRY}/${ECR_REPOSITORY}"
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '===== Checkout ====='

                git(
                    branch: 'main',
                    url: 'https://github.com/Sudhir-lab-dev/devopsAutomationProject.git',
                    credentialsId: 'github-credentials'
                )
            }
        }

        stage('Environment Check') {
            steps {
                sh '''
                    echo "===== Environment Check ====="

                    echo "Node:"
                    node -v

                    echo "NPM:"
                    npm -v

                    echo "Git:"
                    git --version

                    echo "Docker:"
                    docker --version

                    echo "AWS CLI:"
                    aws --version

                    echo "Java:"
                    java -version

                    echo "Current user:"
                    whoami
                '''
            }
        }

        stage('AWS Identity Check') {
            steps {
                sh '''
                    echo "===== AWS Identity ====="

                    aws sts get-caller-identity
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '===== Installing Dependencies ====='

                sh '''
                    npm ci
                '''
            }
        }

        stage('Build Application') {
            steps {
                echo '===== Building Application ====='

                sh '''
                    npm run build
                '''
            }
        }

        stage('Verify Build') {
            steps {
                echo '===== Verifying Build ====='

                sh '''
                    ls -lah dist/
                '''
            }
        }

        stage('Docker Check') {
            steps {
                echo '===== Docker Check ====='

                sh '''
                    docker ps
                    docker images
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo '===== Building Docker Image ====='

                sh '''
                    docker build \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        .

                    echo "Docker image created:"
                    docker images ${IMAGE_NAME}
                '''
            }
        }

        stage('ECR Login') {
            steps {
                echo '===== ECR Login ====='

                sh '''
                    aws ecr get-login-password \
                        --region ${AWS_REGION} | \
                    docker login \
                        --username AWS \
                        --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                echo '===== Push Image to ECR ====='

                sh '''
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                '''
            }
        }
    }

    post {
        success {
            echo '=========================================='
            echo 'Pipeline completed successfully!'
            echo 'Docker image pushed to Amazon ECR.'
            echo '=========================================='
        }

        failure {
            echo '=========================================='
            echo 'Pipeline FAILED.'
            echo 'Check the failed stage in Console Output.'
            echo '=========================================='
        }

        always {
            echo 'Jenkins pipeline execution completed.'
        }
    }
}
