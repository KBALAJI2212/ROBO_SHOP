### Terraform

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