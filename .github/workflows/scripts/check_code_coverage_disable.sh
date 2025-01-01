#!/bin/bash
set -e

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --files) changed_files="$2"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

python_version="3.9"
echo "Setting up Python ${python_version}..."
python -m venv env
source env/bin/activate
pip install --upgrade pip

python_script=".github/workflows/code_coverage_disable_check.py"
echo "Running Python script: ${python_script} for files: ${changed_files}"
python "${python_script}" --files "${changed_files}"

# Clean up virtual environment
deactivate
rm -rf env
echo "Check for code coverage disable completed successfully."
