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

# Basic README template
cat > "$root_dir/README.md" <<'EOF_MD'
# Ansible Project

This directory was bootstrapped by the setup tooling script. It provides a
minimal best‑practice layout for new Ansible automation work.

- `playbooks/` – entry point playbooks
- `group_vars/` – group variable files
- `host_vars/` – host variable files
- `roles/` – reusable roles
- `inventory/` – default inventory location
- `docs/` – project documentation
EOF_MD

# Documentation placeholder
cat > "$root_dir/docs/usage.md" <<'DOC'
# Documentation

Describe how to use this Ansible project here.
DOC

printf '\nAnsible project created at %s\n' "$root_dir"
