# Roboshop E-commerce Microservices Project

## Introduction

The Roboshop project is a fully functional ecommerce platform built with microservices to demonstrate a scalable, **3-tier architecture**. Users can browse products, create accounts, add items to their cart, view purchase history, and ship globally. The project leverages **NGINX** as a reverse proxy, Node.js, Java, and Python-based microservices, and databases like **MongoDB**, **Redis**, **RabbitMQ**, **MySQL**.

The project is deployed using **Shell-Scripting**, **Ansible**, **Terraform**, **Docker**, and **Jenkins**, with monitoring via **Grafana**, **Prometheus**, **cAdvisor**, and **Node Exporter**. Each tool serves a specific purpose, from infrastructure provisioning to CI/CD automation.

This README dives into how each tool was used, with a special focus on Terraform and Jenkins, which handle the heavy lifting for infrastructure and CI/CD automation. Let’s explore!



### Architecture

- **Web Tier**: Nginx serves as a reverse proxy, residing in a public subnet. It routes traffic to application services via an internal load balancer and has no direct access to app or database servers.

- **Application Tier**: Microservices (User, Cart, Catalogue, Shipping, Payment) are deployed in a private subnet with no internet access but can communicate with databases. These services are built using Node.js (User, Cart, Catalogue), Java (Shipping), and Python (Payment).

- **Database Tier**: MongoDB, Redis, RabbitMQ, and MySQL reside in a dedicated database subnet with no internet access, serving requests coming only from the application tier.

- **Networking**: A custom VPC (10.0.0.0/16) with public subnets (10.0.3.0/25, 10.0.3.128/25), private subnets (10.0.2.0/25, 10.0.2.128/25), and a database subnet (10.0.1.0/25). Internet access for private and database subnets is facilitated through a NAT instance in the public subnet for updates/patches.

- **Load Balancing**: A public-facing Application Load Balancer (ALB) routes traffic to Nginx instances, while an internal ALB routes traffic from Nginx to application services using host-based routing.

- **Scalability**: Auto Scaling groups paired with launch templates and spot instances ensure cost-efficient scaling.

- **Security**: HTTPS is enabled via a hosted zone certificate, and load balancer logs are stored in an S3 bucket.

- **Monitoring**: Grafana, Prometheus, cAdvisor, and Node-Exporter provide comprehensive monitoring of containers and hosts.


---

## Tools and Implementation

### 1. Terraform-[DEPLOYMENT LINK](https://terraform.balaji.website:80/)

**Terraform** is the backbone of this project’s infrastructure, automating the provisioning of a secure, scalable, and cost-optimized Roboshop environment on AWS. I went all-in to make this setup robust and production-ready.

**How It Works**:

- **VPC and Networking**:
  - Creates a custom VPC (10.0.0.0/16) with:
    - Public subnets (10.0.3.0/25, 10.0.3.128/25) for NGINX and NAT instances.
    - Private subnets (10.0.2.0/25, 10.0.2.128/25) for app services.
    - DB subnet (10.0.1.0/25) for databases.
  - Configures route tables, routes, and an Internet Gateway (IGW).
  - Uses a NAT instance (not NAT Gateway) in the public subnet for cost savings, allowing private and DB subnets to access the internet indirectly.

- **Security Groups**:
  - Web tier: Allows inbound from the internet and outbound to the internal ALB.
  - App tier: Allows inbound from the internal ALB and outbound to databases.
  - DB tier: Allows inbound from app services only, with no direct internet access.

- **Load Balancers**:
  - **Public ALB**: Balances traffic to NGINX instances in the public subnet, accessible via HTTPS with a hosted zone certificate.
  - **Internal ALB**: Routes traffic from NGINX to app services in private subnets,this LB has no internet access.
  - Configures host-based routing to direct traffic to specific services (e.g.,`cart.x.z` to Cart service).
  - Sets up ELB health checks and stores logs in an S3 bucket.

- **Auto Scaling**:
  - Creates auto-scaling groups for NGINX(web) and app services, using launch templates.
  - Uses spot instances to reduce costs, with listener rules for per service dynamic scaling.

- **Additional Features**:
  - Deploys a single instance for each tool (Shell, Ansible, Docker, Jenkins) to create their own isolated Roboshop environments.
  - Stores Terraform state in an S3 bucket with DynamoDB for state locking.
  - Bootstraps instances with shell scripts to configure services during provisioning.

**Pros**:

- **Full Automation**: Provisions the entire infrastructure with a single `terraform apply`.
- **Scalable and Resilient**: Auto-scaling groups and load balancers handle traffic spikes.
- **Cost-Effective**: Spot instances and NAT instance reduce costs compared to managed services.
- **Secure**: Isolated subnets and security groups enforce least-privilege access.
- **Centralized State Management**: S3 and DynamoDB ensure safe state handling.

**Cons**:

- **Complexity**: Managing a large Terraform codebase requires careful planning.
- **Initial Setup Time**: Writing and testing Terraform configurations is time-intensive.
- **State Management Risks**: Misconfigured S3 or DynamoDB can lead to state conflicts.
- **Learning Curve**: Requires familiarity with AWS and Terraform’s HCL syntax.

---


### 2. Jenkins with Monitoring Stack-[DEPLOYMENT LINK](https://jenkins.balaji.website:80/)

**Jenkins** powers the CI/CD pipeline for Roboshop, automating code updates, image building, and deployment. This was a big focus for me to ensure a fully automated, hands-off workflow.

**How It Works**:

- **Configuration as Code**: Used a Jenkins plugin to skip manual setup of jenkins and create an initial user via code.
- **Dockerized Jenkins**: Baked the Jenkins configuration into a Docker image, hosted on [**Docker Hub**](https://hub.docker.com/r/kbalaji2212/roboshop/tags).

- **Pipeline Workflow**:
  - A GitHub webhook triggers the pipeline if code changes are made.
  - Jenkins compares the last two commits to check if service files (e.g., User, Cart) were modified, ignoring non-service files (ex:README).
  - If service files are changed:
    - Pulls the latest code from GitHub.
    - After user confirmation,Builds new Docker images for affected services.
    - Queries Docker Hub for the last version number of affected service image.
    - Tags and pushes the images to Docker Hub.
    - Deployes new service containers and replaces the old service container. 


**Pros**:

- **Fully Automated CI/CD**: Code changes trigger automatic builds and deployments.
- **Smart Change Detection**: Only rebuilds services affected by code changes, saving time.
- **Containerized Jenkins**: Portable and consistent across environments.

**Cons**:

- **Setup Complexity**: Configuring Jenkins as code and webhooks requires initial effort.
- **Dependency on Docker Hub**: Image uploads/downloads rely on external service availability.

## Monitoring Stack

- **Grafana**: Visualizes metrics with dashboards (requires 2-minute manual setup).
- **Prometheus**: A Data-Source and Scrapes metrics. 
- **cAdvisor**: Provides container-level insights (CPU, memory, no.of containers etc.).
- **Node Exporter**: Monitors host-level metrics (e.g., disk).

These tools are deployed automatically during initial run of Docker Compose command; ensuring real-time insights into the Roboshop stack’s performance.

## How to Deploy

1. **Shell**: Run individual service scripts or the `all-in-one` script on a single instance.
2. **Ansible**: Execute the playbook to configure services across multiple instances.
3. **Terraform**: Run `terraform apply` to provision the entire infrastructure and bootstrap services.
4. **Docker**: Use `docker-compose up` to spin up the Roboshop stack from Docker Hub images.
5. **Jenkins**: Push code changes to the GitHub repo to trigger the CI/CD pipeline.

---


### 3. Docker-[DEPLOYMENT LINK](https://docker.balaji.website:80/)

I containerized all Roboshop services (User, Cart, Catalogue, Shipping, Payment, NGINX) to ensure consistency and portability.

**How It Works**:

- Each service has a **Dockerfile** to build its image,also stored on [**Docker Hub**](https://hub.docker.com/r/kbalaji2212/roboshop/tags).
- A **Docker Compose** file pulls these images and sets up the entire Roboshop stack inside a custom network with a single `docker-compose up` command.
- Containers are configured to communicate with databases and among themselves within the private network.

**Pros**:

- **Lightweight**: Containers use minimal resources compared to VMs.
- **Portable**: Images run consistently across environments.
- **Isolated Environments**: Each service runs in its own container, reducing conflicts.
- **Fast Deployment**: Docker Compose simplifies multi-service orchestration.

**Cons**:

- **Manual Infra Provisioning**: Infrastructure must be set up manually.
- **Image Management Overhead**: Building and updating images requires maintenance.
- **Resource Limits**: Containers on the same instance compete for resources so requires bigger instance.

---


### 4. Ansible-[DEPLOYMENT LINK](https://ansible.balaji.website:80/)

I used **Ansible** roles to automate service configuration across multiple instances, making it easier to scale the Roboshop setup.

**How It Works**:

- Each service (e.g., User, Cart, NGINX) has its own Ansible role with tasks, templates, and variables.
- Roles allow flexibility: Use service-specific templates/variables or a common one for all services.
- A single Ansible playbook configures the entire Roboshop stack across multiple instances.

**Pros**:

- **Scalable Configuration**: Easily configures multiple instances from a single control node.
- **Reusable Roles**: Modular roles reduce duplication and simplify maintenance.
- **Idempotent**: Ensures consistent configurations without unintended changes.
- **Customizable**: Templates and variables allow fine-tuned service configurations.

**Cons**:

- **Learning Curve**: Requires understanding of Ansible’s role-based structure.
- **Debugging Complexity**: Errors in large playbooks can be tricky to troubleshoot.

---


### 5. Shell Scripting-[DEPLOYMENT LINK](https://shell.balaji.website:80/)

I wrote shell scripts to install and configure each service (e.g., User, Cart, NGINX) individually or all at once using an `all-in-one` script on a single instance.

**How It Works**:

- Individual scripts target specific services, installing dependencies and configuring them.
- The `all-in-one` script sets up the entire Roboshop stack on a single instance, ideal for quick setups or testing.

**Pros**:

- **Simple Set Up**: Easy to write and execute with minimal setup.Requires only basic scripting knowledge.
- **Fast for Single Instances**: Great for quick prototyping or small-scale deployments.
- **Portable**: Scripts can be reused across different environments.

**Cons**:

- **Scalability Issues**: Configuring multiple instances manually is tedious and error-prone.
- **No Infra Automation**: Requires manual provisioning of infrastructure, which is time-consuming.

---



*Note:These applications are based on an [open-source_project](https://github.com/instana/robot-shop).I did not develop the original code for these applications.I am only deploying and managing these applications to demonstrate my expertise in infrastructure automation,management and deployment.*
