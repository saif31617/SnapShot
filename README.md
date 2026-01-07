
### Step 1: Set up the AWS Infrastructure Foundations

### Step 1.1 : Create a repository named something
You need to create three specific resources in your AWS Console (or via CLI) to prepare for the GitHub connection:

Create an ECR (Elastic Container Registry) Repository: GitHub Actions will build your React app into a Docker image. It needs a private place to "push" that image.

Action: Create a repository named something like my-react-app.

### Step 1.2 : Create an IAM User for GitHub Actions: GitHub needs permission to talk to your AWS account.

Action: Create a user (e.g., github-action-user) and give it Programmatic Access.

Permissions: For now, attach policies for AmazonEC2ContainerRegistryFullAccess and AmazonECS_FullAccess.

Crucial: Save the Access Key ID and Secret Access Key.

### Step 1.3 :  Store Credentials in GitHub Secrets:

Go to your forked repo on GitHub.

Navigate to Settings > Secrets and variables > Actions.

Add two secrets: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY

### Step 2 : Create the Dockerfile 

### Step 2.1: Create a .dockerignore

To keep your image small and fast, create another file named .dockerignore in the same root directory. This prevents bulky, unnecessary files from being sent to the build

node_modules
build
.git
.github
Dockerfile
.dockerignore


Now that your code is "container-ready" with the Dockerfile, the next step is to set up the infrastructure on AWS where the container will actually run.

### Step 3 : infrastructure for contianer management

### Step 3.1 : Create Create the ECS Cluster

Open the ECS Console: In your AWS Console, search for Elastic Container Service.

Create Cluster: Click the Create cluster button.

Cluster Configuration:

Cluster name: Give it a name like react-app-cluster.

Infrastructure: Select AWS Fargate (serverless).

Why Fargate? It is the easiest way to start because you don't have to manage actual EC2 servers; AWS handles the underlying hardware for you.

Monitoring & Tags: You can leave these as default.

Finish: Click Create.

### Step 3.2 : Create the task definition file 

Create in git repository task-definition.json

{
    "family": "react-app-task",
    "networkMode": "awsvpc",
    "executionRoleArn": "arn:aws:iam::678878256416:role/saifullah-ecsTaskExecutionRole",
    "containerDefinitions": [
        {
            "name": "react-container",
            "image": "678878256416.dkr.ecr.us-east-1.amazonaws.com/saifullah-ecr:cf6372f2f376588b297697794bbf43f3a2db9edc",
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80,
                    "protocol": "tcp"
                }
            ]
        }
    ],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "256",
    "memory": "512"
}



### Step 4 : Prepare the GitHub Workflow File

Now we create the "brain" of the operation. This file will detect your code push, build the image, and tell ECS to update.

In your project, create a folder path: .github/workflows/

Inside that folder, create a file named deploy.yml.




### Step 5: Fix the Task Execution Role

We need to create a role in AWS and then tell your task-definition.json to use it.

### 5.1 : Create the Role  ecsTaskExecutionRole

Go to IAM > Roles > Create role.

Select AWS Service and choose Elastic Container Service.

Select Elastic Container Service Task as the use case.

Attach the policy: AmazonECSTaskExecutionRolePolicy.

Name it: ecsTaskExecutionRole.

Copy the ARN (it looks like arn:aws:iam::123456789012:role/ecsTaskExecutionRole)

### 5.2 Get the Role ARN Update your task-definition.json
Once created, click on the name ecsTaskExecutionRole in the list. Copy the ARN. It will look like this: arn:aws:iam::123456789012:role/ecsTaskExecutionRole


Now, go to your laptop and update your task-definition.json file. You must add the executionRoleArn at the top level of the JSON.

### 6 Create the ECS Service via Console

Start Service Creation:

Find the Services tab and click the Create button.

Deployment Configuration:

Compute options: Keep the default Capacity provider strategy.

Application type: Select Service.

Task definition:

Family: Select the task definition name you registered (e.g., react-app-task).

Revision: Choose the latest one (e.g., 1 (LATEST)).

Service name: Type react-web-service (this must match the name in your deploy.yml exactly).

Desired tasks: Set this to 1.

Networking (Critical Step):

VPC: Select your Default VPC.

Subnets: Select at least two subnets (e.g., us-east-1a and us-east-1b) to ensure availability.

Security group: Select Create a new security group.

Name: react-sg.

Inbound Rules: Add a rule for HTTP on Port 80 with Source 0.0.0.0/0 (Anywhere) so you can access the website in your browser.

Public IP: Ensure this is set to Turned on.

Finish:

Leave all other settings (like Load Balancing) as default for now.

Scroll to the bottom and click Create.