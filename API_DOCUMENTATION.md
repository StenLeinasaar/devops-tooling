# DevOps Tooling - API Documentation

This document provides comprehensive documentation for all public APIs, functions, and components in the devops-tooling project.

## Table of Contents

1. [Ansible Components](#ansible-components)
   - [Docker Installation Playbook](#docker-installation-playbook)
   - [Ubuntu Docker Tasks](#ubuntu-docker-tasks)
   - [Configuration Variables](#configuration-variables)
   - [Inventory Management](#inventory-management)
2. [Setup Tools](#setup-tools)
   - [Ansible Bootstrap Script](#ansible-bootstrap-script)
3. [Development Tools](#development-tools)
   - [Makefile Commands](#makefile-commands)
   - [Pre-commit Hooks](#pre-commit-hooks)
4. [Code Examples](#code-examples)
5. [Usage Patterns](#usage-patterns)

---

## Ansible Components

### Docker Installation Playbook

**File:** `ansible/playbooks/docker.yml`

**Purpose:** Main entry point for installing Docker on target systems using OS-specific tasks.

**API Definition:**
```yaml
---
- name: Install Docker
  hosts: all
  become: true
  tasks:
    - name: Include OS specific tasks
      ansible.builtin.include_tasks: "../tasks/{{ ansible_distribution | lower }}/docker.yml"
```

**Parameters:**
- `hosts`: Target hosts (default: `all`)
- `become`: Privilege escalation (required: `true`)

**Usage Examples:**

1. **Basic Usage:**
```bash
ansible-playbook ansible/playbooks/docker.yml -i ansible/hosts
```

2. **Custom Inventory:**
```bash
ansible-playbook ansible/playbooks/docker.yml -i production_hosts
```

3. **Specific Host Group:**
```bash
ansible-playbook ansible/playbooks/docker.yml -i ansible/hosts --limit ubuntu
```

4. **Check Mode (Dry Run):**
```bash
ansible-playbook ansible/playbooks/docker.yml -i ansible/hosts --check
```

**Requirements:**
- Target system must be Ubuntu (current implementation)
- Ansible user must have sudo privileges
- Internet connectivity for package downloads

---

### Ubuntu Docker Tasks

**File:** `ansible/tasks/ubuntu/docker.yml`

**Purpose:** OS-specific tasks for installing Docker on Ubuntu systems.

**API Definition:**
The task file provides the following operations:

1. **Install Prerequisites**
```yaml
- name: Install required packages
  ansible.builtin.apt:
    name: "{{ docker_prereq_packages }}"
    state: present
    update_cache: yes
```

2. **Add Docker GPG Key**
```yaml
- name: Add Docker GPG key
  ansible.builtin.apt_key:
    url: "{{ docker_gpg_key_url }}"
    state: present
```

3. **Configure Repository**
```yaml
- name: Add Docker repository
  ansible.builtin.apt_repository:
    repo: "deb [arch={{ docker_repo_arch }}] {{ docker_repo_url }} {{ docker_repo_release }} stable"
    state: present
    update_cache: yes
```

4. **Install Docker**
```yaml
- name: Install Docker packages
  ansible.builtin.apt:
    name: "{{ docker_packages }}"
    state: present
    update_cache: yes
```

5. **Ensure Service Running**
```yaml
- name: Ensure Docker is running
  ansible.builtin.service:
    name: "{{ docker_service_name }}"
    state: started
    enabled: yes
```

**Dependencies:**
- Requires variables from `group_vars/all.yml`
- Ubuntu operating system
- APT package manager

**Usage Examples:**

1. **Include in Custom Playbook:**
```yaml
---
- name: Custom Docker Setup
  hosts: docker_hosts
  become: true
  tasks:
    - name: Install Docker on Ubuntu
      ansible.builtin.include_tasks: tasks/ubuntu/docker.yml
      when: ansible_distribution == "Ubuntu"
```

2. **Override Variables:**
```yaml
---
- name: Custom Docker Setup with Overrides
  hosts: docker_hosts
  become: true
  vars:
    docker_repo_arch: arm64  # For ARM systems
  tasks:
    - name: Install Docker on Ubuntu
      ansible.builtin.include_tasks: tasks/ubuntu/docker.yml
```

---

### Configuration Variables

**File:** `ansible/group_vars/all.yml`

**Purpose:** Global configuration variables for Docker installation.

**API Definition:**

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `docker_prereq_packages` | list | See below | Prerequisites before Docker installation |
| `docker_gpg_key_url` | string | `https://download.docker.com/linux/ubuntu/gpg` | GPG key URL for package verification |
| `docker_repo_url` | string | `https://download.docker.com/linux/ubuntu` | Docker repository base URL |
| `docker_repo_arch` | string | `amd64` | Repository architecture |
| `docker_repo_release` | string | `{{ ansible_distribution_release }}` | Ubuntu release codename |
| `docker_packages` | list | See below | Docker packages to install |
| `docker_service_name` | string | `docker` | Docker service name |

**Default Values:**

```yaml
# Prerequisites
docker_prereq_packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - software-properties-common

# Docker packages
docker_packages:
  - docker-ce
  - docker-ce-cli
  - containerd.io
```

**Usage Examples:**

1. **Override in Group Variables:**
```yaml
# group_vars/production.yml
docker_repo_arch: arm64
docker_packages:
  - docker-ce
  - docker-ce-cli
  - containerd.io
  - docker-compose-plugin
```

2. **Override in Host Variables:**
```yaml
# host_vars/server1.yml
docker_prereq_packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - software-properties-common
  - python3-pip  # Additional package for this host
```

3. **Override at Runtime:**
```bash
ansible-playbook docker.yml -i hosts -e "docker_repo_arch=arm64"
```

---

### Inventory Management

**File:** `ansible/hosts`

**Purpose:** Example inventory file for local testing.

**API Definition:**
```ini
[ubuntu]
localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3
```

**Usage Examples:**

1. **Local Testing:**
```bash
ansible-playbook playbooks/docker.yml -i hosts
```

2. **Custom Inventory Structure:**
```ini
[docker_servers]
web1.example.com
web2.example.com
db1.example.com

[docker_servers:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/production.pem

[ubuntu:children]
docker_servers
```

3. **Dynamic Inventory:**
```bash
# Using AWS EC2 dynamic inventory
ansible-playbook playbooks/docker.yml -i ec2.py --limit "tag_Environment_production"
```

---

## Setup Tools

### Ansible Bootstrap Script

**File:** `setup/bootstrap_ansible.sh`

**Purpose:** Creates a minimal Ansible project structure with best practices.

**API Definition:**
```bash
./bootstrap_ansible.sh <path>
```

**Parameters:**
- `path` (required): Target directory for the new Ansible project

**Generated Structure:**
```
<path>/
├── playbooks/
│   └── site.yml
├── roles/
│   └── sample_role/
│       └── tasks/
│           └── main.yml
├── group_vars/
│   └── all.yml
├── host_vars/
│   └── localhost.yml
├── inventory/
│   └── hosts
├── docs/
│   └── usage.md
└── README.md
```

**Usage Examples:**

1. **Basic Project Creation:**
```bash
cd setup
./bootstrap_ansible.sh my-ansible-project
```

2. **Create in Specific Location:**
```bash
./setup/bootstrap_ansible.sh /opt/ansible-projects/web-deployment
```

3. **Verify Generated Structure:**
```bash
./bootstrap_ansible.sh test-project
cd test-project
ansible-playbook playbooks/site.yml -i inventory/hosts
```

**Generated Files API:**

1. **Sample Playbook (`playbooks/site.yml`):**
```yaml
---
- name: Example play
  hosts: all
  roles:
    - role: sample_role
      tags: ["setup"]
```

2. **Sample Role (`roles/sample_role/tasks/main.yml`):**
```yaml
---
- name: Echo a message
  ansible.builtin.debug:
    msg: "Sample role executed"
```

3. **Sample Variables:**
```yaml
# group_vars/all.yml
---
package_state: present

# host_vars/localhost.yml
---
my_host_var: default_value
```

**Script Functions:**

The bootstrap script provides these internal functions:

1. **Directory Creation:**
   - Creates standard Ansible project directories
   - Ensures proper structure for scalability

2. **File Generation:**
   - Creates sample files with best practices
   - Generates comprehensive documentation

3. **Template Population:**
   - Populates files with working examples
   - Includes tag usage demonstrations

---

## Development Tools

### Makefile Commands

**File:** `Makefile`

**Purpose:** Provides convenient commands for development workflow.

**API Definition:**

| Command | Description | Usage |
|---------|-------------|-------|
| `make install` | Install pre-commit and set up git hooks | `make install` |
| `make precommit` | Run all pre-commit hooks on all files | `make precommit` |

**Usage Examples:**

1. **Initial Setup:**
```bash
# Install development dependencies
make install
```

2. **Manual Code Quality Check:**
```bash
# Run all quality checks
make precommit
```

3. **Integration with CI/CD:**
```bash
# In your CI pipeline
make install
make precommit
```

**Dependencies:**
- Python 3.x
- pip package manager
- Git repository

---

### Pre-commit Hooks

**File:** `.pre-commit-config.yaml`

**Purpose:** Automated code quality and formatting tools.

**API Definition:**

The configuration includes these hooks:

1. **Black Formatter**
```yaml
- repo: https://github.com/psf/black
  rev: 23.9.1
  hooks:
    - id: black
      args: ["--line-length=88"]
```

2. **Flake8 Linter**
```yaml
- repo: https://gitlab.com/pycqa/flake8
  rev: 6.1.0
  hooks:
    - id: flake8
      args: ["--max-line-length=88", "--ignore=E203,W503"]
```

3. **Import Sorting (isort)**
```yaml
- repo: https://github.com/pre-commit/mirrors-isort
  rev: v5.10.1
  hooks:
    - id: isort
      args: ["--profile", "black"]
```

4. **Secret Detection**
```yaml
- repo: https://github.com/Yelp/detect-secrets
  rev: v1.4.0
  hooks:
    - id: detect-secrets
```

**Usage Examples:**

1. **Manual Execution:**
```bash
pre-commit run --all-files
```

2. **Specific Hook:**
```bash
pre-commit run black --all-files
```

3. **Skip Hooks (when necessary):**
```bash
git commit -m "fix: urgent hotfix" --no-verify
```

4. **Custom Configuration:**
```yaml
# .pre-commit-config.yaml override
repos:
  - repo: https://github.com/psf/black
    rev: 23.9.1
    hooks:
      - id: black
        args: ["--line-length=100"]  # Custom line length
```

---

## Code Examples

### Complete Workflow Examples

1. **Setting Up a New Environment:**
```bash
# 1. Clone the repository
git clone <repository-url> devops-tooling
cd devops-tooling

# 2. Set up development environment
make install

# 3. Create a new Ansible project
./setup/bootstrap_ansible.sh my-infrastructure

# 4. Install Docker on servers
cd my-infrastructure
ansible-playbook playbooks/site.yml -i inventory/hosts

# 5. Run Docker installation from main project
cd ../ansible
ansible-playbook playbooks/docker.yml -i hosts
```

2. **Custom Docker Installation:**
```bash
# Create custom inventory
cat > custom_hosts << EOF
[docker_hosts]
server1.example.com ansible_user=ubuntu
server2.example.com ansible_user=ubuntu

[docker_hosts:vars]
docker_repo_arch=amd64
ansible_ssh_private_key_file=~/.ssh/production.pem
EOF

# Run installation with custom variables
ansible-playbook ansible/playbooks/docker.yml -i custom_hosts \
  -e "docker_packages=['docker-ce', 'docker-ce-cli', 'containerd.io', 'docker-compose-plugin']"
```

3. **Development Workflow:**
```bash
# Make changes to code
echo "print('hello world')" > test.py

# Run quality checks
make precommit

# If issues are found, they're automatically fixed or reported
# Commit your changes
git add .
git commit -m "feat: add new functionality"
```

---

## Usage Patterns

### Best Practices

1. **Ansible Playbook Execution:**
```bash
# Always use check mode first
ansible-playbook playbooks/docker.yml -i hosts --check

# Use verbose output for debugging
ansible-playbook playbooks/docker.yml -i hosts -vv

# Limit to specific hosts
ansible-playbook playbooks/docker.yml -i hosts --limit "server1,server2"
```

2. **Variable Management:**
```yaml
# group_vars/production.yml
---
docker_repo_arch: amd64
docker_packages:
  - docker-ce=5:20.10.24~3-0~ubuntu-focal
  - docker-ce-cli=5:20.10.24~3-0~ubuntu-focal
  - containerd.io

# host_vars/web1.production.yml
---
docker_prereq_packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - software-properties-common
  - nginx  # Additional package for web servers
```

3. **Error Handling:**
```yaml
---
- name: Install Docker with error handling
  hosts: all
  become: true
  tasks:
    - name: Include OS specific tasks
      ansible.builtin.include_tasks: "../tasks/{{ ansible_distribution | lower }}/docker.yml"
      rescue:
        - name: Log error
          ansible.builtin.debug:
            msg: "Failed to install Docker on {{ inventory_hostname }}"
        - name: Fail gracefully
          ansible.builtin.fail:
            msg: "Docker installation failed"
```

### Integration Examples

1. **CI/CD Pipeline Integration:**
```yaml
# .github/workflows/ansible.yml
name: Ansible Deployment
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: 3.9
      - name: Install dependencies
        run: |
          pip install ansible
          make install
      - name: Run quality checks
        run: make precommit
      - name: Deploy Docker
        run: |
          ansible-playbook ansible/playbooks/docker.yml -i production_hosts
```

2. **Terraform Integration:**
```hcl
# terraform/main.tf
resource "null_resource" "configure_docker" {
  depends_on = [aws_instance.web]
  
  provisioner "local-exec" {
    command = "ansible-playbook ../ansible/playbooks/docker.yml -i '${aws_instance.web.public_ip},' -u ubuntu"
  }
}
```

---

## Error Handling and Troubleshooting

### Common Issues and Solutions

1. **Permission Errors:**
```bash
# Issue: Permission denied during Docker installation
# Solution: Ensure become: true is set and user has sudo access
ansible-playbook playbooks/docker.yml -i hosts --ask-become-pass
```

2. **Network Connectivity:**
```bash
# Issue: Cannot reach Docker repository
# Solution: Check internet connectivity and DNS
ansible all -i hosts -m ping
ansible all -i hosts -m shell -a "nslookup download.docker.com"
```

3. **Variable Override Issues:**
```bash
# Issue: Variables not being applied
# Solution: Check variable precedence and use debug
ansible-playbook playbooks/docker.yml -i hosts -e debug=true
```

### Debugging Commands

```bash
# Check connectivity
ansible all -i hosts -m ping

# Gather system information
ansible all -i hosts -m setup

# Test specific tasks
ansible all -i hosts -m apt -a "name=curl state=present" --check

# Verbose execution
ansible-playbook playbooks/docker.yml -i hosts -vvv
```

---

## API Reference Summary

| Component | Type | Purpose | Key Files |
|-----------|------|---------|-----------|
| Docker Playbook | Ansible Playbook | Install Docker on Ubuntu systems | `ansible/playbooks/docker.yml` |
| Ubuntu Tasks | Ansible Tasks | OS-specific Docker installation steps | `ansible/tasks/ubuntu/docker.yml` |
| Configuration | Variables | Customizable installation parameters | `ansible/group_vars/all.yml` |
| Bootstrap Script | Shell Script | Generate new Ansible projects | `setup/bootstrap_ansible.sh` |
| Development Tools | Make/Pre-commit | Code quality and formatting | `Makefile`, `.pre-commit-config.yaml` |

This documentation provides comprehensive coverage of all public APIs, functions, and components with practical examples and usage instructions.