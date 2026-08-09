pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'

        ECR_REGISTRY = '218589468002.dkr.ecr.us-east-1.amazonaws.com'

        ECR_REPOSITORY_NAME = 'automation-devops-project'

        ECR_REPOSITORY = "${ECR_REGISTRY}/${ECR_REPOSITORY_NAME}"
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
                    echo "Node:"
                    node --version

                    echo "NPM:"
                    npm --version

                    echo "Docker:"
                    docker --version

                    echo "AWS:"
                    aws --version
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
            docker build \
                -t $ECR_REPOSITORY:jenkins-$BUILD_NUMBER \
                -t $ECR_REPOSITORY:latest \
                .
        '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
            echo "Logging in to Amazon ECR..."

            aws ecr get-login-password --region ${AWS_REGION} | \
            docker login \
            --username AWS \
            --password-stdin ${ECR_REGISTRY}

            echo "Tagging Docker images..."

            docker tag ${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER} \
                ${ECR_REGISTRY}/${ECR_REPOSITORY_NAME}:jenkins-${BUILD_NUMBER}

            docker tag ${ECR_REPOSITORY}:latest \
                ${ECR_REGISTRY}/${ECR_REPOSITORY_NAME}:latest

            echo "Pushing build image..."

            docker push \
                ${ECR_REGISTRY}/${ECR_REPOSITORY_NAME}:jenkins-${BUILD_NUMBER}

            echo "Pushing latest image..."

            docker push \
                ${ECR_REGISTRY}/${ECR_REPOSITORY_NAME}:latest

            echo "ECR push completed successfully!"
        '''
            }
        }
    }

    post {
        success {
            echo 'CI pipeline completed successfully!'
        }

        failure {
            echo 'CI pipeline failed. Check the stage logs.'
        }
    }
}
