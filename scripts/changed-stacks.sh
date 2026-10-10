#!/usr/bin/env bash
# Prints the Terraform stacks (directories with a backend.tf) changed between two commits,
# as a JSON array in apply order. 000-organization is human-applied and never listed.
set -euo pipefail

base=$1
head=$2

git diff --name-only "$base...$head" -- terraform/ |
  while read -r file; do
    dir=$(dirname "$file")
    while [[ $dir == terraform/* && ! -f $dir/backend.tf ]]; do
      dir=$(dirname "$dir")
    done
    if [[ -f $dir/backend.tf ]]; then echo "$dir"; fi
  done |
  { grep -vx 'terraform/000-organization' || true; } |
  sort -u |
  jq -Rnc '[inputs]'
