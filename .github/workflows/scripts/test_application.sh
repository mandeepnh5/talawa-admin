#!/bin/bash
set -e

coverage_dir="./coverage"
jest_coverage_dir="${coverage_dir}/jest"
vitest_coverage_dir="${coverage_dir}/vitest"

echo "Running Jest tests..."
NODE_V8_COVERAGE="${jest_coverage_dir}" npm run test -- --watchAll=false --coverage
echo "Jest tests completed successfully."

echo "Running Vitest tests..."
NODE_V8_COVERAGE="${vitest_coverage_dir}" npm run test:vitest:coverage
echo "Vitest tests completed successfully."

echo "Merging coverage reports..."
mkdir -p "$coverage_dir"
if ! npx lcov-result-merger "${coverage_dir}/*/lcov.info" > "${coverage_dir}/lcov.info"; then
  echo "Failed to merge coverage reports."
  exit 1
fi
echo "Coverage reports merged successfully."

changed_files=${CHANGED_FILES:-""}
if [ -n "$changed_files" ]; then
  echo "Running TypeScript compilation for changed files..."
  for file in $changed_files; do
    if [[ "$file" == *.ts || "$file" == *.tsx ]]; then
      echo "Compiling $file..."
      npx tsc --noEmit "$file"
    fi
  done
fi

echo "Uploading coverage to Codecov..."
npx codecov -t "${CODECOV_TOKEN}" -f "${coverage_dir}/lcov.info" --verbose
echo "Coverage uploaded to Codecov successfully."
