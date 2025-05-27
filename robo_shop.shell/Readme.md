### Shell Scripting-[DEPLOYMENT LINK](https://shell.balaji.website:80/)

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