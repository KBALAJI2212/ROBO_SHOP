### Jenkins with Monitoring Stack
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