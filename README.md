# 🚀 Automation DevOps Project

An end-to-end **AWS DevOps + QA Automation project** demonstrating how a Node.js + TypeScript browser automation application can be containerized, continuously deployed, and operated on AWS.

The project combines:

- Node.js
- TypeScript
- Express.js
- Puppeteer
- Jest
- Docker
- Jenkins
- Amazon ECR
- Amazon EKS
- Kubernetes
- Amazon S3
- Terraform
- AWS IAM
- AWS Load Balancer
- GitHub
- Postman

The application accepts CSV data through a REST API, validates each record, uses Puppeteer to automate browser form filling, generates screenshots, uploads successful screenshots to Amazon S3, and returns processing results through the API.

The complete application is deployed automatically through a Jenkins CI/CD pipeline to Amazon EKS.

---

# 📌 Project Highlights

This project demonstrates two complete flows:

### 1. Application Automation Flow

```text
Postman
   │
   │ POST CSV
   ▼
Application API
   │
   ▼
CSV Validation
   │
   ├── Invalid Record
   │       │
   │       ▼
   │   Validation Error
   │
   └── Valid Record
           │
           ▼
      Puppeteer Bot
           │
           ▼
      Fill Web Form
           │
           ▼
      Take Screenshot
           │
           ▼
      Upload to S3
           │
           ▼
      API Response
           │
           ▼
     Screenshot S3 URI


##### DevOps CI/CD Flow #####

Developer
    │
    ▼
GitHub
    │
    ▼
Jenkins EC2
    │
    ├── Checkout
    ├── Verify Environment
    ├── Verify AWS Identity
    ├── Verify EKS Access
    ├── npm ci
    ├── Jest Tests
    ├── TypeScript Build
    ├── Docker Build
    │
    ▼
Amazon ECR
    │
    │ Pull Image
    ▼
Amazon EKS
    │
    ├── Kubernetes Deployment
    ├── Kubernetes Pod
    └── LoadBalancer Service
            │
            ▼
      AWS Load Balancer
            │
            ▼
       Application API



🎯 Project Objective

The objective of this project is to demonstrate a realistic DevOps workflow where an automation application can be:

Developed using Node.js and TypeScript
Tested automatically
Compiled using TypeScript
Containerized using Docker
Stored in Amazon ECR
Deployed to Amazon EKS
Exposed through an AWS Load Balancer
Validated using an automated health check
Triggered through a REST API
Process CSV records
Automate browser form filling using Puppeteer
Generate screenshots
Store screenshots in Amazon S3
Return processing results to the API consumer


🏗️ High-Level Architecture

                         ┌──────────────────────┐
                         │       Developer      │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │       GitHub         │
                         │   Source Repository  │
                         └──────────┬───────────┘
                                    │
                              Git Checkout
                                    │
                                    ▼
                    ┌─────────────────────────────┐
                    │        Jenkins EC2          │
                    │                             │
                    │  CI/CD Pipeline             │
                    │                             │
                    │  npm ci                     │
                    │  Jest Tests                 │
                    │  TypeScript Build            │
                    │  Docker Build               │
                    │  ECR Push                   │
                    │  EKS Deployment              │
                    │  Health Check               │
                    └──────────────┬──────────────┘
                                   │
                             Docker Push
                                   │
                                   ▼
                    ┌─────────────────────────────┐
                    │        Amazon ECR            │
                    │                             │
                    │ automation-devops-project   │
                    │                             │
                    │ jenkins-<BUILD_NUMBER>      │
                    └──────────────┬──────────────┘
                                   │
                              Pull Image
                                   │
                                   ▼
              ┌─────────────────────────────────────────┐
              │               Amazon EKS                │
              │                                         │
              │  Cluster:                               │
              │  automation-devops-project-eks          │
              │                                         │
              │  ┌───────────────────────────────────┐  │
              │  │ Kubernetes Deployment             │  │
              │  │                                   │  │
              │  │ automation-app                    │  │
              │  │                                   │  │
              │  │ ┌─────────────────────────────┐   │  │
              │  │ │ Pod                         │   │  │
              │  │ │                             │   │  │
              │  │ │ Node.js + TypeScript        │   │  │
              │  │ │ Express.js                  │   │  │
              │  │ │ Puppeteer                   │   │  │
              │  │ └─────────────────────────────┘   │  │
              │  └───────────────────────────────────┘  │
              │                                         │
              │  Kubernetes Service                     │
              │  Type: LoadBalancer                     │
              └───────────────────┬─────────────────────┘
                                  │
                                  ▼
                       ┌──────────────────────┐
                       │   AWS Load Balancer  │
                       └──────────┬───────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ Application API  │
                         └────────┬─────────┘
                                  │
                         POST /api/csv/upload
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ CSV Processing    │
                         │ & Validation      │
                         └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ Puppeteer Bot    │
                         │ Form Automation  │
                         └────────┬─────────┘
                                  │
                            Screenshot
                                  │
                                  ▼
                         ┌──────────────────┐
                         │    Amazon S3     │
                         │ Screenshot Store │
                         └──────────────────┘


🔄 Application Automation Flow

The application exposes a CSV upload endpoint.

POST /api/csv/upload

A CSV file containing user information is sent using Postman.

Example CSV:

firstName,lastName,email
Sudhir,Mhaske,sudhir@example.com
John,,john@example.com
Alice,Smith,alice@example.com

The application processes each record independently.

Step 1 — CSV Upload

The client sends a multipart/form-data request from Postman.

POST /api/csv/upload

The uploaded CSV contains multiple records.



Step 2 — CSV Validation

Each record is validated before browser automation begins.

For example:

firstName → required
lastName  → required
email     → required

Invalid records are rejected without running the browser automation.

Example:

John,,john@example.com

produces:

{
  "status": "FAILED",
  "errorType": "VALIDATION_ERROR",
  "errors": [
    "lastName is required"
  ]
}

This allows successful and failed records to be processed independently.



🤖 Puppeteer Automation

Valid CSV records are passed to the Puppeteer automation service.

The automation performs the following steps:

Valid CSV Record
       │
       ▼
Launch Browser
       │
       ▼
Open Target Form
       │
       ▼
Enter First Name
       │
       ▼
Enter Last Name
       │
       ▼
Enter Email
       │
       ▼
Submit / Complete Form
       │
       ▼
Generate Screenshot
       │
       ▼
Upload Screenshot to S3

Puppeteer is used for browser automation inside the Docker container running on Amazon EKS.



🪣 Screenshot Storage — Amazon S3

Successful automation screenshots are uploaded to Amazon S3.

Example S3 bucket:

automation-devops-project-screenshots-218589468002

Example S3 object:

screenshots/2026-08-18T11-37-44-800Z-3d83ac8f-0a0a-477d-adf8-19c60eec2513.png

The application records the S3 object information and returns it in the API response.



📡 API Response

The API returns a record-by-record processing result.

Example:

{
  "success": false,
  "message": "CSV processing completed with some failures",
  "totalRecords": 3,
  "successfulRecords": 2,
  "failedRecords": 1,
  "results": [
    {
      "firstName": "Sudhir",
      "lastName": "Mhaske",
      "email": "sudhir@example.com",
      "status": "SUCCESS",
      "screenshot": {
        "fileName": "2026-08-18T11-37-44-800Z-3d83ac8f-0a0a-477d-adf8-19c60eec2513.png",
        "s3Key": "screenshots/2026-08-18T11-37-44-800Z-3d83ac8f-0a0a-477d-adf8-19c60eec2513.png",
        "s3Uri": "s3://automation-devops-project-screenshots-218589468002/screenshots/2026-08-18T11-37-44-800Z-3d83ac8f-0a0a-477d-adf8-19c60eec2513.png"
      }
    },
    {
      "firstName": "John",
      "lastName": "",
      "email": "john@example.com",
      "status": "FAILED",
      "errorType": "VALIDATION_ERROR",
      "errors": [
        "lastName is required"
      ]
    }
  ]
}


Important

The top-level:

"success": false

does not mean the entire request failed.

It indicates that the CSV processing completed with one or more record-level failures.

In this example:

Total Records     = 3
Successful Records = 2
Failed Records     = 1

This demonstrates partial-success processing and record-level failure handling.



☁️ AWS Infrastructure

The application is deployed using the following AWS services:

| AWS Service       | Purpose                            |
| ----------------- | ---------------------------------- |
| Amazon EC2        | Jenkins CI/CD server               |
| Amazon EKS        | Kubernetes container orchestration |
| Amazon ECR        | Docker image registry              |
| Amazon S3         | Screenshot storage                 |
| AWS IAM           | Authentication and permissions     |
| AWS Load Balancer | External application access        |
| Amazon VPC        | Network infrastructure             |
| Subnets           | Network isolation                  |
| Security Groups   | Network access control             |


Infrastructure is provisioned using Terraform.



🛠️ Technology Stack

##Application##

Node.js
TypeScript
Express.js
Puppeteer
Jest
CSV processing
REST API

##DevOps##

Git
GitHub
Jenkins
Docker
Kubernetes
Amazon ECR
Amazon EKS
Terraform
AWS CLI
kubectl
Linux

##AWS##

Amazon EC2
Amazon ECR
Amazon EKS
Amazon S3
IAM
VPC
AWS Load Balancer

##API Testing##

Postman



📂 Project Structure


automation-devops-project/
│
├── src/
│   ├── automation/
│   │   ├── bots/
│   │   ├── browser.ts
│   │   └── browserTest.ts
│   │
│   ├── config/
│   │
│   ├── controllers/
│   │
│   ├── routes/
│   │
│   ├── services/
│   │   ├── automation.service.ts
│   │   ├── csv.service.ts
│   │   └── s3.service.ts
│   │
│   ├── tests/
│   │
│   ├── types/
│   │
│   ├── utils/
│   │
│   ├── app.ts
│   └── server.ts
│
├── terraform/
│   ├── IAM
│   ├── EC2
│   ├── ECR
│   ├── EKS
│   ├── S3
│   ├── VPC
│   └── networking
│
├── docs/
│   ├── architecture.png
│   ├── jenkins-success.png
│   ├── csv-postman.png
│   ├── csv-response.png
│   ├── s3-screenshot.png
│   ├── eks-cluster.png
│   ├── kubernetes-pods.png
│   ├── ecr-image.png
│   └── application-health.png
│
├── Dockerfile
├── Jenkinsfile
├── package.json
├── tsconfig.json
├── jest.config.js
└── README.md



🔄 CI/CD Pipeline

Jenkins automates the application deployment process.

Pipeline Stages


1. Checkout Source
        ↓
2. Verify Jenkins Environment
        ↓
3. Verify AWS Identity
        ↓
4. Verify EKS Access
        ↓
5. Install Dependencies
        ↓
6. Run Jest Tests
        ↓
7. Build TypeScript Application
        ↓
8. Build Docker Image
        ↓
9. Authenticate with Amazon ECR
        ↓
10. Push Docker Image to ECR
        ↓
11. Update Kubernetes Deployment
        ↓
12. Kubernetes Rollout
        ↓
13. Verify Deployment
        ↓
14. Verify Kubernetes Service
        ↓
15. Retrieve AWS Load Balancer
        ↓
16. Application Health Check
        ↓
17. Pipeline SUCCESS


🧪 Automated Testing

Jest is used for automated unit testing.

Run tests locally:

npm test

Current successful pipeline result:

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total

The pipeline stops if the tests fail.



🏗️ TypeScript Build

The application is compiled using the TypeScript compiler.

npm run build

Successful build:

> automation-devops-project@1.0.0 build
> tsc

TypeScript build completed successfully.



🐳 Docker

The application is packaged as a Docker image.

Build Image
docker build -t automation-devops-project .

Run Container
docker run -d \
  --name automation-app \
  -p 3000:3000 \
  automation-devops-project

Health Check
curl http://localhost:3000/api/health

Expected response:

{
  "status": "UP",
  "message": "DevOps Automation Project is running"
}



📦 Amazon ECR

Docker images are stored in Amazon Elastic Container Registry.

Repository:

automation-devops-project

Images are tagged using the Jenkins build number.

Example:

automation-devops-project:jenkins-11

Full image:

218589468002.dkr.ecr.us-east-1.amazonaws.com/automation-devops-project:jenkins-11

The pipeline also maintains the:

latest

tag.



☸️ Amazon EKS

The application runs on Amazon Elastic Kubernetes Service.

EKS Cluster
automation-devops-project-eks

Kubernetes Deployment
automation-app

Kubernetes Service
automation-app

Service Type
LoadBalancer

Verify EKS
kubectl get nodes

Example:

NAME                          STATUS
ip-10-0-11-234.ec2.internal   Ready

Verify Deployment
kubectl get deployment automation-app

Verify Pods
kubectl get pods \
  -l app=automation-app \
  -o wide


Verify Service
kubectl get svc automation-app



🔐 IAM — Secure AWS Authentication

The Jenkins EC2 instance uses an IAM role instead of storing long-term AWS access keys.

This is an important security practice.

The EC2 IAM role provides the permissions required by Jenkins to interact with AWS services such as:

Amazon ECR
Amazon EKS
Amazon S3
EKS cluster discovery

Verify the active AWS identity:
aws sts get-caller-identity

Example:

arn:aws:sts::218589468002:assumed-role/automation-devops-project-ec2-role/...

No AWS access keys are stored inside the Jenkins pipeline.



🪣 Amazon S3

Amazon S3 stores screenshots generated by the Puppeteer automation.

Example bucket:

automation-devops-project-screenshots-218589468002

Screenshot objects are stored under:

screenshots/

Example:

screenshots/
└── 2026-08-18T11-37-44-800Z-3d83ac8f-0a0a-477d-adf8-19c60eec2513.png

The application uses the AWS SDK to upload screenshots to S3.




🏗️ Terraform Infrastructure as Code

Terraform is used to provision the AWS infrastructure.

Infrastructure includes:

VPC
Subnets
Security Groups
EC2
IAM Roles
IAM Policies
ECR
EKS
S3
Networking components



Typical commands:

terraform init
terraform plan
terraform apply

Terraform allows the infrastructure to be defined as code and reproduced consistently.



🔍 Jenkins + AWS + EKS Integration

Jenkins runs on an Amazon EC2 instance.

The EC2 instance uses an IAM role to authenticate with AWS.

Jenkins verifies the Kubernetes connection before deployment:
kubectl config current-context

Example:

arn:aws:eks:us-east-1:218589468002:cluster/automation-devops-project-eks

Jenkins then verifies the cluster:
kubectl get nodes

This confirms that the CI/CD server can communicate with the EKS cluster.




🚀 Deployment Strategy

Every Jenkins build creates a unique Docker image tag.

Example:
jenkins-11

The pipeline updates the Kubernetes deployment using:
kubectl set image \
  deployment/automation-app \
  automation-app=<ECR_IMAGE>

Jenkins then waits for Kubernetes to complete the rollout:
kubectl rollout status \
  deployment/automation-app



The pipeline verifies that the running deployment uses the expected image.

Example:
Expected Image:
218589468002.dkr.ecr.us-east-1.amazonaws.com/automation-devops-project:jenkins-11


Actual Image:
218589468002.dkr.ecr.us-east-1.amazonaws.com/automation-devops-project:jenkins-11

This provides an additional deployment verification step.



❤️ Application Health Check

After deployment, Jenkins retrieves the AWS Load Balancer hostname.

The pipeline then performs an HTTP health check.

Endpoint:
GET /api/health

Example:
{
  "status": "UP",
  "message": "DevOps Automation Project is running",
  "timestamp": "2026-08-18T06:51:03.079Z"
}

The pipeline fails automatically if the health check does not succeed.




📊 Successful Jenkins Deployment

The project successfully completed Jenkins build #11.

Pipeline:

GitHub
   ↓
Jenkins EC2
   ↓
Environment Verification
   ↓
AWS Identity Verification
   ↓
EKS Access Verification
   ↓
npm ci
   ↓
Jest Tests
   ↓
TypeScript Build
   ↓
Docker Build
   ↓
Amazon ECR
   ↓
Amazon EKS
   ↓
Kubernetes Rollout
   ↓
Deployment Verification
   ↓
AWS Load Balancer
   ↓
Application Health Check
   ↓
SUCCESS



Build:
11

Docker image:
automation-devops-project:jenkins-11

EKS cluster:
automation-devops-project-eks

Kubernetes deployment:
automation-app




📡 API Endpoints

Health Check
GET /api/health

Example:
curl http://localhost:3000/api/health


CSV Upload
POST /api/csv/upload

The endpoint accepts a CSV file using multipart/form-data.

Example Postman request:
POST http://<LOAD_BALANCER>/api/csv/upload

Body:
form-data

File field:
file

The API processes every CSV record independently.




🧾 CSV Processing Example

Input:
firstName,lastName,email
Sudhir,Mhaske,sudhir@example.com
John,,john@example.com
Alice,Smith,alice@example.com



Processing:

Sudhir Mhaske
      ↓
Validation PASS
      ↓
Puppeteer Automation
      ↓
Screenshot
      ↓
S3 Upload
      ↓
SUCCESS


John
      ↓
Validation FAIL
      ↓
lastName is required
      ↓
FAILED


Alice Smith
      ↓
Validation PASS
      ↓
Puppeteer Automation
      ↓
Screenshot
      ↓
S3 Upload
      ↓
SUCCESS



Result:
Total Records      = 3
Successful Records = 2
Failed Records     = 1

This demonstrates record-level validation and partial-success processing.




📸 Project Screenshots

Screenshots are available inside the:

docs/

directory.

Screenshots include:

##CI/CD##
Jenkins successful pipeline
Jenkins pipeline stages
Jenkins EKS deployment
Jenkins health check

##AWS##
Amazon ECR repository
ECR image with Jenkins build tag
EKS cluster
EKS node
Kubernetes deployment
Kubernetes pods
Kubernetes LoadBalancer service
S3 screenshots

##Application##
Postman CSV upload request
Postman API response
Screenshot generated by Puppeteer
Application health endpoint


Architecture Diagram

Jenkins Pipeline

Postman CSV Automation

CSV Processing Response

Amazon S3 Screenshot

EKS Deployment

Kubernetes Pods

Amazon ECR

Application Health





🚀 Running Locally

Clone Repository
git clone https://github.com/Sudhir-lab-dev/devopsAutomationProject.git

cd devopsAutomationProject

Install Dependencies
npm install

Run Development Server
npm run dev

Run Tests
npm test

Build Application
npm run build



🐳 Running with Docker

Build:
docker build -t automation-devops-project .

Run:
docker run -d \
  --name automation-app \
  -p 3000:3000 \
  automation-devops-project

Health check:
curl http://localhost:3000/api/health



🎯 DevOps Concepts Demonstrated

This project demonstrates practical implementation of:

Git and GitHub
CI/CD
Jenkins Declarative Pipelines
Jenkins running on AWS EC2
AWS IAM Roles
IAM-based authentication
Docker
Docker multi-stage builds
Amazon ECR
Kubernetes
Amazon EKS
Kubernetes Deployments
Kubernetes Pods
Kubernetes Services
AWS Load Balancer
Terraform Infrastructure as Code
Amazon S3
AWS CLI
kubectl
Linux administration
Automated testing
TypeScript compilation
Docker image versioning
Kubernetes rolling deployments
Deployment verification
Application health checks
REST API
Postman
CSV processing
Record-level validation
Puppeteer browser automation
Screenshot generation
S3 object storage
Partial-success processing
CI/CD application deployment





🔮 Future Enhancements

The current project provides a complete working CI/CD and application automation flow.

Potential future improvements include:

GitHub Webhook → automatic Jenkins trigger
SonarQube integration
Prometheus monitoring
Grafana dashboards
CloudWatch monitoring
Kubernetes Horizontal Pod Autoscaler
HTTPS using AWS ACM
Route 53 custom domain
Blue/Green deployment
Canary deployment
Automated rollback
Multi-environment infrastructure
Terraform remote state using S3
Terraform state locking
Kubernetes Secrets management
Centralized logging
API authentication
Presigned S3 URLs for secure screenshot access



🏆 Project Outcome

The project successfully demonstrates an end-to-end DevOps workflow:

SOURCE CODE
    │
    ▼
GITHUB
    │
    ▼
JENKINS
    │
    ├── TEST
    ├── BUILD
    └── CONTAINERIZE
    │
    ▼
AMAZON ECR
    │
    ▼
AMAZON EKS
    │
    ▼
KUBERNETES
    │
    ▼
AWS LOAD BALANCER
    │
    ▼
REST API
    │
    ▼
CSV PROCESSING
    │
    ▼
PUPPETEER AUTOMATION
    │
    ▼
SCREENSHOT
    │
    ▼
AMAZON S3
    │
    ▼
API RESPONSE

The application and its infrastructure are automated from source code to deployment and validated through automated testing and health checks.

👨‍💻 Author
Sudhir G. Mhaske

Software Engineer | AWS DevOps Engineer | QA Automation Engineer

GitHub:

https://github.com/Sudhir-lab-dev