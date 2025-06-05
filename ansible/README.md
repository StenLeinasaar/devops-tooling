# Ansible Tooling

This directory contains scripts and playbooks for managing infrastructure with Ansible.

## Structure

- `playbooks/` - entry point playbooks.
- `tasks/<os>/` - OS specific task snippets that can be reused by playbooks.

Currently only Ubuntu Docker installation tasks are provided, but additional
operating system directories can be added under `tasks/` in the future.

## Example

Run the Docker setup playbook against your inventory:

```bash
ansible-playbook playbooks/docker.yml -i hosts
```

Ensure that your inventory group or host variables correctly identify the
operating system so the playbook can include the appropriate task file.
