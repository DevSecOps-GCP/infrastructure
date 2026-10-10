#!/usr/bin/env bash
# Prints the Terraform stacks (directories with a backend.tf) changed between two commits,
# as a JSON array in apply order. Human-applied stacks are never listed.
set -euo pipefail

base=$1
head=$2

# Human-applied stacks: they define the identities the pipeline itself uses.
manual='terraform/(000-organization|440-vault-bootstrap)'

git diff --name-only "$base...$head" -- terraform/ |
  while read -r file; do
    dir=$(dirname "$file")
    while [[ $dir == terraform/* && ! -f $dir/backend.tf ]]; do
      dir=$(dirname "$dir")
    done
    if [[ -f $dir/backend.tf ]]; then echo "$dir"; fi
  done |
  { grep -Evx "$manual" || true; } |
  sort -u |
  jq -Rnc '[inputs]'
