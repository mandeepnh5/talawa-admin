#!/bin/bash

set -e

echo "Setting up environment..."
echo "Fetching changed files..."
unauthorized_files=(
  ".env*"
  ".github/**"
  "env.example"
  ".node-version"
  ".husky/**"
  "scripts/**"
  "src/style/**"
  "schema.graphql"
  "package.json"
  "package-lock.json"
  "tsconfig.json"
  ".gitignore"
  ".eslintrc.json"
  ".eslintignore"
  ".prettierrc"
  ".prettierignore"
  ".nojekyll"
  "vite.config.ts"
  "docker-compose.yaml"
  "Dockerfile"
  "CODEOWNERS"
  "LICENSE"
  "setup.ts"
  ".coderabbit.yaml"
  "CODE_OF_CONDUCT.md"
  "CODE_STYLE.md"
  "CONTRIBUTING.md"
  "DOCUMENTATION.md"
  "INSTALLATION.md"
  "ISSUE_GUIDELINES.md"
  "PR_GUIDELINES.md"
  "README.md"
  "*.pem"
  "*.key"
  "*.cert"
  "*.password"
  "*.secret"
  "*.credentials"
)

changed_files=$(git diff --name-only HEAD^ HEAD)

echo "Checking for unauthorized file changes..."
unauthorized_detected=false
for file in ${changed_files}; do
  for pattern in "${unauthorized_files[@]}"; do
    if [[ $file == $pattern ]]; then
      echo "$file is unauthorized to change/delete"
      unauthorized_detected=true
    fi
  done
done

if $unauthorized_detected; then
  echo "Unauthorized file changes detected!"
  echo "To override this check, apply the 'ignore-sensitive-files-pr' label."
  exit 1
else
  echo "No unauthorized changes detected."
fi