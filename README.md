# README

Details of the Java "Hello World" application deployed to EKS Cluster


1. Infrastructure Provisioning Using Terraform
In the terraform-infra directory, we have a main.tf file, which is used to provision the required infrastructure on AWS, specifically for the deployment of the EKS cluster. The key steps involved here are:

EKS Cluster Setup: The main.tf file includes the configuration for creating an EKS cluster. The cluster is the core of our Kubernetes setup, where applications will be deployed and managed.

Node Group and Node Instance: The configuration also defines a node group, which specifies the type of EC2 instances that will be used as worker nodes in the cluster. In this case, a single EC2 instance is being used for simplicity and to reduce costs for the initial setup.

By running the necessary Terraform commands (terraform init, terraform apply), the EKS cluster, along with the node group, is created.

2. Java Application Containerization with Docker
The next step involves creating a Docker image for the Java "Hello World" application. Here’s a breakdown of the process:

Java Application Source: A small Java "Hello World" application was sourced from GitHub. This simple application listens on a specific port and prints a "Hello, World!" message when accessed.

Dockerfile Creation: A Dockerfile was written to containerize the Java application. The Dockerfile specifies how to build the Docker image, starting from a base image (e.g., OpenJDK), copying the application files, compiling the Java code, and finally running the application.

Building and Pushing the Docker Image: The Docker image was built using the command:

bash
Copy code
docker build -t my-username/javaapp:latest .
After building the image locally, it was pushed to DockerHub using:

bash
Copy code
docker push my-username/javaapp:latest
This makes the image publicly available on DockerHub, which can later be pulled by the Kubernetes cluster to run the application.

3. Helm Deployment to Kubernetes (EKS Cluster)
Helm was used to deploy the application to the EKS cluster. The steps followed are as below:

3.1 Creating the Helm Chart
Helm Create Command: The first step in deploying the application using Helm was to generate a new Helm chart with the following command:
bash
Copy code
helm create java-app
This command generates a directory structure for a Helm chart, including templates for deployment.yaml, service.yaml, ingress.yaml, and a values.yaml file. These files allow for the flexible configuration of the application deployment.
3.2 Modifying the Helm Chart
Update the values.yaml: The values.yaml file contains default values for various settings such as image repository, service configuration, and ingress. This file was modified to reflect the specifics of our deployment:

The Docker image (my-username/javaapp:latest) was updated in the image.repository and image.tag fields to ensure that the correct Docker image is used.
Any necessary configurations for ingress (such as domain names, paths, and annotations) were also added or updated in the ingress.yaml.
Other Changes: Additional changes were made to other files like deployment.yaml and service.yaml to match the application’s requirements. These changes typically involve:

Setting the container port to 8080 (the port where the Java app is listening inside the container).
Configuring the service type as LoadBalancer to expose the application externally.
3.3 Deploying the Application
Once the necessary changes were made, the Helm deployment was initiated with the following command:

bash
Copy code
helm install java-app ./java-app
This command deploys the Java application using Helm, creating the necessary Kubernetes resources (such as Pods, Deployments, Services, and Ingresses) in the EKS cluster.

Deployment: The Deployment resource ensures that the application runs on the available nodes in the EKS cluster. It manages the lifecycle of the application pods (creating, scaling, and rolling updates).

Service: The Service resource exposes the application to external traffic, routing requests to the correct pod and port.

Ingress: The Ingress resource (optional) handles routing external traffic from a specific URL (or domain) to the application. In this case, it was configured to route traffic to the LoadBalancer service on port 80, which is then forwarded to the pod's internal port 8080.

4. Accessing the Java Application
Once the deployment was complete, the Java application was accessible via the external LoadBalancer URL provided by EKS. The LoadBalancer is automatically provisioned by Kubernetes when the service type is set to LoadBalancer.

External Access: The application is accessible externally via the LoadBalancer's DNS name (something like k8s-default-javaapp-xxxxx.elb.us-east-1.amazonaws.com). If an Ingress was set up with a custom domain (e.g., your-domain.com), the application could also be accessed through that domain.

Port Configuration: The application inside the container listens on port 8080, but externally, it is accessible through port 80, which was mapped in the service.