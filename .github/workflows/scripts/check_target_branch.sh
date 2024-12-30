#!/bin/bash
set -e

# Extract the base branch name from the GitHub event
TARGET_BRANCH=$(jq -r '.pull_request.base.ref' "$GITHUB_EVENT_PATH")

if [[ "$TARGET_BRANCH" != "develop-postgres" ]]; then
  echo "Error: Pull request target branch must be 'develop-postgres'."
  echo "Please refer to PR_GUIDELINES.md."
  exit 1
fi

echo "Target branch is correct: $TARGET_BRANCH"
