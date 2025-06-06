### Docker

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