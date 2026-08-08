pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY = 'automation-devops-project'
        AWS_ACCOUNT_ID = '218589468002'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_NAME = "${ECR_REGISTRY}/${ECR_REPOSITORY}"
    }

    stages {
        stage('Checkout') {
            steps {
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
                    echo "Node:"
                    node -v

                    echo "NPM:"
                    npm -v

                    echo "Docker:"
                    docker --version

                    echo "AWS CLI:"
                    aws --version
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    npm ci
                '''
            }
        }

        stage('Build Application') {
            steps {
                sh '''
                    npm run build
                '''
            }
        }

        stage('Verify Build') {
            steps {
                sh '''
                    echo "Build output:"
                    ls -la dist/
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    echo "Building Docker image..."

                    docker build \
                        -t ${IMAGE_NAME}:latest \
                        .

                    echo "Docker image built successfully:"
                    docker images ${IMAGE_NAME}
                '''
            }
        }

        stage('ECR Login') {
            steps {
                sh '''
                    echo "Logging in to Amazon ECR..."

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
                sh '''
                    echo "Pushing Docker image to ECR..."

                    docker push ${IMAGE_NAME}:latest

                    echo "Docker image pushed successfully!"
                '''
            }
        }
    }

    post {
        success {
            echo 'Build and Docker image push completed successfully!'
        }

        failure {
            echo 'Pipeline failed.'
        }

        always {
            echo 'Jenkins pipeline execution completed.'
        }
    }
}
