#!/bin/bash

set -e

echo "Installing dependencies..."
npm install

echo "Running line count check..."
python .github/workflows/countline.py --lines 600 --exclude_files \
  src/screens/LoginPage/LoginPage.tsx \
  src/GraphQl/Queries/Queries.ts \
  src/screens/OrgList/OrgList.tsx \
  src/GraphQl/Mutations/mutations.ts \
  src/components/EventListCard/EventListCardModals.tsx \
  src/components/TagActions/TagActionsMocks.ts \
  src/utils/interfaces.ts \
  src/screens/MemberDetail/MemberDetail.tsx

echo "Fetching changed TypeScript files..."
changed_files=$(npx tj-actions/changed-files@v45)

echo "Checking formatting..."
if [ "$changed_files" != "true" ]; then
  echo "Running format check..."
  if ! npm run format:check; then
    echo "Format issues detected. Running format fix..."
    npm run format:fix
  fi
fi

echo "Running type-checking..."
if [ "$changed_files" != "true" ]; then
  npm run typecheck
fi

echo "Checking for linting errors in modified files..."
if [ "$changed_files" != "true" ]; then
  echo "Linting changed files..."
  npx eslint "$changed_files"
fi

echo "Checking for TSDoc comments..."
npm run check-tsdoc

echo "Checking for localStorage usage..."
chmod +x scripts/githooks/check-localstorage-usage.js
node scripts/githooks/check-localstorage-usage.js --scan-entire-repo

echo "Comparing translation files..."
python .github/workflows/compare_translations.py --directory public/locales

echo "Checking if source and target branches are different..."
source_branch="${GITHUB_HEAD_REF:-$(git rev-parse --abbrev-ref HEAD)}"
target_branch="${GITHUB_BASE_REF:-$(git symbolic-ref --short HEAD)}"

if [ "$source_branch" == "$target_branch" ]; then
  echo "Error: Source and Target Branches are the same."
  echo "Source Branch: $source_branch"
  echo "Target Branch: $target_branch"
  exit 1
fi

echo "All code quality checks passed!"
