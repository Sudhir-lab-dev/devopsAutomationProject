pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'

        ECR_REGISTRY = '218589468002.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY_NAME = 'automation-devops-project'
        ECR_REPOSITORY = "${ECR_REGISTRY}/${ECR_REPOSITORY_NAME}"

        EKS_CLUSTER_NAME = 'automation-devops-project-eks'

        K8S_NAMESPACE = 'default'
        K8S_DEPLOYMENT = 'automation-app'
        K8S_CONTAINER = 'automation-app'
        K8S_SERVICE = 'automation-app'
    }

    stages {
        /*
         * ==========================================================
         * VERIFY JENKINS ENVIRONMENT
         * ==========================================================
         */

        stage('Verify Environment') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Jenkins Environment"
                    echo "======================================"

                    echo "Hostname:"
                    hostname

                    echo ""
                    echo "Running User:"
                    whoami

                    echo ""
                    echo "Node:"
                    node --version

                    echo ""
                    echo "NPM:"
                    npm --version

                    echo ""
                    echo "Docker:"
                    docker --version

                    echo ""
                    echo "AWS:"
                    aws --version

                    echo ""
                    echo "Git:"
                    git --version

                    echo ""
                    echo "kubectl:"
                    kubectl version --client

                    echo ""
                    echo "======================================"
                    echo "AWS Identity"
                    echo "======================================"

                    aws sts get-caller-identity

                    echo ""
                    echo "======================================"
                    echo "Kubernetes Context"
                    echo "======================================"

                    kubectl config current-context
                '''
            }
        }

        /*
         * ==========================================================
         * VERIFY EKS ACCESS
         * ==========================================================
         */

        stage('Verify EKS Access') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Verifying EKS Access"
                    echo "======================================"

                    echo "Expected EKS Cluster:"
                    echo "${EKS_CLUSTER_NAME}"

                    echo ""
                    echo "Current Kubernetes Context:"
                    CURRENT_CONTEXT=$(kubectl config current-context)

                    echo "${CURRENT_CONTEXT}"

                    EXPECTED_CONTEXT="arn:aws:eks:${AWS_REGION}:218589468002:cluster/${EKS_CLUSTER_NAME}"

                    if [ "${CURRENT_CONTEXT}" != "${EXPECTED_CONTEXT}" ]; then
                        echo ""
                        echo "ERROR: Jenkins is using the wrong Kubernetes context."
                        echo "Expected:"
                        echo "${EXPECTED_CONTEXT}"
                        echo "Actual:"
                        echo "${CURRENT_CONTEXT}"
                        exit 1
                    fi

                    echo ""
                    echo "Kubernetes context verification passed."

                    echo ""
                    echo "======================================"
                    echo "EKS Nodes"
                    echo "======================================"

                    kubectl get nodes -o wide

                    echo ""
                    echo "======================================"
                    echo "Current Application Deployment"
                    echo "======================================"

                    kubectl get deployment ${K8S_DEPLOYMENT} \
                        -n ${K8S_NAMESPACE}
                '''
            }
        }

        /*
         * ==========================================================
         * INSTALL DEPENDENCIES
         * ==========================================================
         */

        stage('Install Dependencies') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Installing Dependencies"
                    echo "======================================"

                    npm ci
                '''
            }
        }

        /*
         * ==========================================================
         * TEST
         * ==========================================================
         */

        stage('Run Tests') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Running Tests"
                    echo "======================================"

                    npm test
                '''
            }
        }

        /*
         * ==========================================================
         * TYPESCRIPT BUILD
         * ==========================================================
         */

        stage('Build Application') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Building TypeScript Application"
                    echo "======================================"

                    npm run build

                    echo ""
                    echo "TypeScript build completed successfully."
                '''
            }
        }

        /*
         * ==========================================================
         * DOCKER BUILD
         * ==========================================================
         */

        stage('Docker Build') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Building Docker Image"
                    echo "======================================"

                    EKS_IMAGE="${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER}"

                    echo "Build Image:"
                    echo "${EKS_IMAGE}"

                    docker build \
                        -t "${EKS_IMAGE}" \
                        -t "${ECR_REPOSITORY}:latest" \
                        .

                    echo ""
                    echo "======================================"
                    echo "Docker Images"
                    echo "======================================"

                    docker images "${ECR_REPOSITORY}"
                '''
            }
        }

        /*
         * ==========================================================
         * PUSH TO ECR
         * ==========================================================
         */

        stage('Push Image to ECR') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Logging in to Amazon ECR"
                    echo "======================================"

                    aws ecr get-login-password \
                        --region ${AWS_REGION} | \
                    docker login \
                        --username AWS \
                        --password-stdin ${ECR_REGISTRY}

                    echo ""
                    echo "ECR login successful."

                    echo ""
                    echo "======================================"
                    echo "Pushing Build Image"
                    echo "======================================"

                    docker push \
                        ${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER}

                    echo ""
                    echo "Build image pushed successfully."

                    echo ""
                    echo "======================================"
                    echo "Pushing Latest Image"
                    echo "======================================"

                    docker push \
                        ${ECR_REPOSITORY}:latest

                    echo ""
                    echo "Latest image pushed successfully."

                    echo ""
                    echo "ECR push completed successfully."
                '''
            }
        }

        /*
         * ==========================================================
         * DEPLOY TO EKS
         *
         * IMPORTANT:
         * Jenkins is already running on the EKS administration
         * EC2 instance.
         *
         * Therefore NO SSH is required.
         * kubectl communicates directly with EKS.
         * ==========================================================
         */

        stage('Deploy to EKS') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Deploying Application to EKS"
                    echo "======================================"

                    EKS_IMAGE="${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER}"

                    echo "Cluster:"
                    echo "${EKS_CLUSTER_NAME}"

                    echo ""
                    echo "Deployment:"
                    echo "${K8S_DEPLOYMENT}"

                    echo ""
                    echo "Container:"
                    echo "${K8S_CONTAINER}"

                    echo ""
                    echo "New Image:"
                    echo "${EKS_IMAGE}"

                    echo ""
                    echo "======================================"
                    echo "Updating Deployment Image"
                    echo "======================================"

                    kubectl set image \
                        deployment/${K8S_DEPLOYMENT} \
                        ${K8S_CONTAINER}=${EKS_IMAGE} \
                        -n ${K8S_NAMESPACE}

                    echo ""
                    echo "Deployment image updated."

                    echo ""
                    echo "======================================"
                    echo "Waiting for Kubernetes Rollout"
                    echo "======================================"

                    kubectl rollout status \
                        deployment/${K8S_DEPLOYMENT} \
                        -n ${K8S_NAMESPACE} \
                        --timeout=5m

                    echo ""
                    echo "EKS rollout completed successfully."
                '''
            }
        }

        /*
         * ==========================================================
         * VERIFY EKS DEPLOYMENT
         * ==========================================================
         */

        stage('Verify EKS Deployment') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Verifying EKS Deployment"
                    echo "======================================"

                    EXPECTED_IMAGE="${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER}"

                    echo "Expected Image:"
                    echo "${EXPECTED_IMAGE}"

                    echo ""
                    echo "======================================"
                    echo "Deployment"
                    echo "======================================"

                    kubectl get deployment ${K8S_DEPLOYMENT} \
                        -n ${K8S_NAMESPACE} \
                        -o wide

                    echo ""
                    echo "======================================"
                    echo "Pods"
                    echo "======================================"

                    kubectl get pods \
                        -l app=${K8S_DEPLOYMENT} \
                        -n ${K8S_NAMESPACE} \
                        -o wide

                    echo ""
                    echo "======================================"
                    echo "Running Image"
                    echo "======================================"

                    ACTUAL_IMAGE=$(kubectl get deployment ${K8S_DEPLOYMENT} \
                        -n ${K8S_NAMESPACE} \
                        -o jsonpath='{.spec.template.spec.containers[0].image}')

                    echo "Actual Image:"
                    echo "${ACTUAL_IMAGE}"

                    echo ""
                    echo "Expected Image:"
                    echo "${EXPECTED_IMAGE}"

                    if [ "${ACTUAL_IMAGE}" != "${EXPECTED_IMAGE}" ]; then
                        echo ""
                        echo "ERROR: EKS is not running the expected Jenkins image."
                        exit 1
                    fi

                    echo ""
                    echo "EKS image verification passed."

                    echo ""
                    echo "======================================"
                    echo "Pod Status"
                    echo "======================================"

                    kubectl get pods \
                        -l app=${K8S_DEPLOYMENT} \
                        -n ${K8S_NAMESPACE}

                    echo ""
                    echo "EKS deployment verification completed successfully."
                '''
            }
        }

        /*
         * ==========================================================
         * VERIFY KUBERNETES SERVICE
         * ==========================================================
         */

        stage('Verify Kubernetes Service') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Verifying Kubernetes Service"
                    echo "======================================"

                    kubectl get svc ${K8S_SERVICE} \
                        -n ${K8S_NAMESPACE} \
                        -o wide

                    echo ""
                    echo "Service Type:"

                    SERVICE_TYPE=$(kubectl get svc ${K8S_SERVICE} \
                        -n ${K8S_NAMESPACE} \
                        -o jsonpath='{.spec.type}')

                    echo "${SERVICE_TYPE}"

                    if [ "${SERVICE_TYPE}" != "LoadBalancer" ]; then
                        echo ""
                        echo "ERROR: Expected Service type LoadBalancer."
                        exit 1
                    fi

                    echo ""
                    echo "Kubernetes LoadBalancer Service verified."
                '''
            }
        }

        /*
         * ==========================================================
         * GET LOAD BALANCER
         * ==========================================================
         */

        stage('Get Load Balancer') {
            steps {
                script {
                    def loadBalancer = sh(
                        script: '''
                            kubectl get svc ${K8S_SERVICE} \
                                -n ${K8S_NAMESPACE} \
                                -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
                        ''',
                        returnStdout: true
                    ).trim()

                    if (!loadBalancer) {
                        error('Load Balancer hostname was not found.')
                    }

                    env.LOAD_BALANCER_HOST = loadBalancer

                    echo ''
                    echo '======================================'
                    echo 'AWS Load Balancer'
                    echo '======================================'

                    echo "${env.LOAD_BALANCER_HOST}"
                }
            }
        }

        /*
         * ==========================================================
         * HEALTH CHECK
         *
         * Retry because the AWS Load Balancer may need some time
         * to recognize the newly rolled-out pod.
         * ==========================================================
         */

        stage('Health Check') {
            steps {
                sh '''
                    set -e

                    echo "======================================"
                    echo "Application Health Check"
                    echo "======================================"

                    HEALTH_URL="http://${LOAD_BALANCER_HOST}/api/health"

                    echo "Health URL:"
                    echo "${HEALTH_URL}"

                    echo ""

                    MAX_ATTEMPTS=12
                    ATTEMPT=1

                    while [ ${ATTEMPT} -le ${MAX_ATTEMPTS} ]; do

                        echo "Health check attempt ${ATTEMPT}/${MAX_ATTEMPTS}"

                        if curl \
                            --fail \
                            --silent \
                            --show-error \
                            --max-time 15 \
                            "${HEALTH_URL}"; then

                            echo ""
                            echo ""
                            echo "======================================"
                            echo "HEALTH CHECK PASSED"
                            echo "======================================"

                            exit 0
                        fi

                        echo ""
                        echo "Application not ready yet."

                        if [ ${ATTEMPT} -lt ${MAX_ATTEMPTS} ]; then
                            echo "Waiting 10 seconds..."
                            sleep 10
                        fi

                        ATTEMPT=$((ATTEMPT + 1))
                    done

                    echo ""
                    echo "======================================"
                    echo "HEALTH CHECK FAILED"
                    echo "======================================"

                    echo "Application did not become healthy within the expected time."

                    exit 1
                '''
            }
        }
    }

    /*
     * ==========================================================
     * POST ACTIONS
     * ==========================================================
     */

    post {
        success {
            echo """
======================================
CI/CD PIPELINE SUCCESS
======================================

GitHub
   ↓
Jenkins EC2
   ↓
npm test
   ↓
TypeScript build
   ↓
Docker build
   ↓
Amazon ECR
   ↓
Amazon EKS
   ↓
Kubernetes rollout
   ↓
AWS Load Balancer
   ↓
Application health check

======================================
DEPLOYMENT INFORMATION
======================================

Build:
${BUILD_NUMBER}

Docker Image:
${ECR_REPOSITORY}:jenkins-${BUILD_NUMBER}

EKS Cluster:
${EKS_CLUSTER_NAME}

Load Balancer:
${LOAD_BALANCER_HOST}

Health Endpoint:
http://${LOAD_BALANCER_HOST}/api/health

======================================
Deployment completed successfully.
======================================
"""
        }

        failure {
            echo """
======================================
CI/CD PIPELINE FAILED
======================================

Build:
${BUILD_NUMBER}

EKS Cluster:
${EKS_CLUSTER_NAME}

Check the failed stage above.

======================================
"""
        }

        always {
            echo "Pipeline finished. Build number: ${BUILD_NUMBER}"
        }
    }
}
