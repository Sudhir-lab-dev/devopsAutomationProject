pipeline {
    agent any

    environment {
        APP_NAME = 'automation-devops-project'
        IMAGE_NAME = 'automation-devops-project'
        CONTAINER_NAME = 'automation-devops-app'

        IMAGE_TAG = "${BUILD_NUMBER}"

        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '218589468002'

        ECR_REPOSITORY = 'automation-devops-project'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

    // SONAR_SCANNER = tool 'SonarScanner'
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

        // stage('SonarQube Analysis') {
        //     steps {
        //         withSonarQubeEnv('SonarQube') {
        //             sh '''
        //             $SONAR_SCANNER/bin/sonar-scanner
        //             '''
        //         }
        //     }
        // }

        // stage('Quality Gate') {
        //     steps {
        //         timeout(time: 5, unit: 'MINUTES') {
        //             waitForQualityGate abortPipeline: true
        //         }
        //     }
        // }

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
                docker build -t $IMAGE_NAME:$IMAGE_TAG .
                '''
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh '''
        docker tag \
        $IMAGE_NAME:$IMAGE_TAG \
        $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

        docker tag \
        $IMAGE_NAME:$IMAGE_TAG \
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

        stage('Docker Image Info') {
            steps {
                sh '''
                echo "======================================"
                echo "Docker Images"
                echo "======================================"
                docker images

                echo ""
                echo "ECR Image:"
                echo "$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
                '''
            }
        }

        stage('Cleanup Local Images') {
            steps {
                sh '''
        docker image prune -f
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
                    $IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
        echo "Waiting for application to start..."
        sleep 10

        STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://localhost:3001/api/health)

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
            echo "Docker Image: ${IMAGE_NAME}:${IMAGE_TAG}"
        }

        failure {
            echo '❌ Deployment Failed'
        }

        always {
            cleanWs()
        }
    }
}
