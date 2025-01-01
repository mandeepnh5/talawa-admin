#!/bin/bash
set -e

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --count) changed_files_count="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

echo "Number of files changed: ${changed_files_count}"

threshold=100
if [ "${changed_files_count}" -gt "${threshold}" ]; then
  echo "Error: Too many files (greater than ${threshold}) changed in the pull request."
  echo "Possible issues:"
  echo "- Contributor may be merging into an incorrect branch."
  echo "- Source branch may be incorrect. Please use develop as the source branch."
  exit 1
fi

echo "File change count is within acceptable limits."
