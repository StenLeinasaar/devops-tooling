#!/usr/bin/env bash
# Bootstrap a basic Ansible project structure.
# Usage: ./bootstrap_ansible.sh <path>
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <path>" >&2
    exit 1
fi

root_dir="$1"

# Create base directories
for dir in playbooks group_vars host_vars roles inventory docs; do
    mkdir -p "$root_dir/$dir"
done

# Sample inventory file
cat > "$root_dir/inventory/hosts" <<'INV'
[example]
localhost ansible_connection=local
INV

# Sample group vars
cat > "$root_dir/group_vars/all.yml" <<'VARS'
---
# Global variables
package_state: present
VARS

# Sample host vars
cat > "$root_dir/host_vars/localhost.yml" <<'VARS'
---
# Host specific variables
my_host_var: default_value
VARS

# Sample role
mkdir -p "$root_dir/roles/sample_role/tasks"
cat > "$root_dir/roles/sample_role/tasks/main.yml" <<'ROLE'
---
- name: Echo a message
  ansible.builtin.debug:
    msg: "Sample role executed"
ROLE

# Sample playbook demonstrating tags
cat > "$root_dir/playbooks/site.yml" <<'PLAY'
---
- name: Example play
  hosts: all
  roles:
    - role: sample_role
      tags: ["setup"]
PLAY

# Detailed README
cat > "$root_dir/README.md" <<'EOF_MD'
# Ansible Project

This directory was bootstrapped by the setup tooling script. It provides a minimal best-practice layout for new Ansible automation work.

## Layout

- `playbooks/` – entry point playbooks
- `roles/` – reusable roles
- `group_vars/` – shared variables for all hosts
- `host_vars/` – host specific variables
- `inventory/` – default inventory location
- `docs/` – project documentation

## Usage

Run the sample playbook against the provided inventory:

```bash
ansible-playbook playbooks/site.yml -i inventory/hosts
```

To run only tasks tagged `setup`:

```bash
ansible-playbook playbooks/site.yml -i inventory/hosts --tags setup
```

## Inventory

Edit `inventory/hosts` to define your hosts. The default content is:

```ini
[example]
localhost ansible_connection=local
```

## Variable files

- `group_vars/all.yml` contains global variables such as `package_state`.
- `host_vars/localhost.yml` holds host-specific settings like `my_host_var`.

## Tags

The sample playbook assigns the tag `setup` to the `sample_role`. Tags let you run only portions of a playbook with `--tags` or skip them with `--skip-tags`.
EOF_MD

# Documentation placeholder
cat > "$root_dir/docs/usage.md" <<'DOC'
# Documentation

Describe how to use this Ansible project here.
DOC

printf '\nAnsible project created at %s\n' "$root_dir"

