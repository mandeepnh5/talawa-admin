#!/bin/bash
set -e

# Variables
coverage_dir="./coverage"
jest_coverage_dir="${coverage_dir}/jest"
vitest_coverage_dir="${coverage_dir}/vitest"

# Functions
run_tests() {
  local name=$1
  local command=$2
  local coverage_path=$3

  echo "Running ${name} tests..."
  NODE_V8_COVERAGE="${coverage_path}" $command
  echo "${name} tests completed successfully."
}

merge_coverage_reports() {
  echo "Merging coverage reports..."
  mkdir -p "$coverage_dir"
  if ! npx lcov-result-merger "${coverage_dir}/*/lcov.info" > "${coverage_dir}/lcov.info"; then
    echo "Failed to merge coverage reports."
    exit 1
  fi
  echo "Coverage reports merged successfully."
}

upload_to_codecov() {
  local codecov_token=$1
  echo "Uploading coverage to Codecov..."
  npx codecov -t "$codecov_token" -f "${coverage_dir}/lcov.info" --verbose
  echo "Coverage uploaded to Codecov successfully."
}

test_changed_files() {
  local files=$1
  echo "Running TypeScript compilation for changed files..."
  for file in $files; do
    if [[ "$file" == *.ts || "$file" == *.tsx ]]; then
      echo "Compiling $file..."
      npx tsc --noEmit "$file"
    fi
  done
}

# Run tests
run_tests "Jest" "npm run test -- --watchAll=false --coverage" "$jest_coverage_dir"
run_tests "Vitest" "npm run test:vitest:coverage" "$vitest_coverage_dir"

# Merge coverage reports
merge_coverage_reports

# Compile TypeScript files
changed_files=${CHANGED_FILES:-""}
if [ -n "$changed_files" ]; then
  test_changed_files "$changed_files"
fi

# Upload to Codecov
upload_to_codecov "${CODECOV_TOKEN}"
