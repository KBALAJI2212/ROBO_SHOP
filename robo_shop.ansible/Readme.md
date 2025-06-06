### Ansible

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