#!/bin/bash
set -e

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --files) sensitive_files=("$2"); shift ;;
    --changed-files) changed_files=("$2"); shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

# Check for unauthorized changes
unauth_files=()
for file in "${changed_files[@]}"; do
  for sensitive in "${sensitive_files[@]}"; do
    if [[ "$file" == $sensitive ]]; then
      unauth_files+=("$file")
    fi
  done
done

if [ ${#unauth_files[@]} -gt 0 ]; then
  echo "Unauthorized changes detected in sensitive files:"
  for file in "${unauth_files[@]}"; do
    echo " - $file"
  done
  echo "To override this check, apply the 'ignore-sensitive-files-pr' label."
  exit 1
else
  echo "No unauthorized sensitive file changes detected."
fi
