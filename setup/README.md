# Setup Tooling

This directory contains helper scripts for bootstrapping new infrastructure projects.

## bootstrap_ansible.sh

Creates a minimal Ansible project layout complete with a sample playbook, inventory, and variable files. Provide a target directory as the only argument and the script will populate it with a recommended structure and a detailed README.

```bash
./bootstrap_ansible.sh my-ansible-project
```

The generated README explains how to run the example playbook, how to use tags, and where to place host or group variables for customization.

