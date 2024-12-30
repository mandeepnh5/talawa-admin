#!/bin/bash
set -e

# Variables
prod_port=4173
dev_port=4321
timeout=120

# Helper function for health check
function health_check {
  local port=$1
  local name=$2
  echo "Starting $name health check with ${timeout}s timeout..."
  while ! nc -z localhost "$port" && [ $timeout -gt 0 ]; do
    sleep 1
    timeout=$((timeout - 1))
    if [ $((timeout % 10)) -eq 0 ]; then
      echo "Still waiting for $name to start... ${timeout}s remaining."
    fi
  done
  if [ $timeout -eq 0 ]; then
    echo "Timeout waiting for $name to start."
    exit 1
  fi
  echo "$name started successfully."
}

# Start production app
echo "Starting production app..."
npm run preview &
echo $! > .pidfile_prod
health_check "$prod_port" "Production app"

# Stop production app
function cleanup_prod {
  if [ -f .pidfile_prod ]; then
    echo "Stopping production app..."
    kill "$(cat .pidfile_prod)"
    rm -f .pidfile_prod
  fi
}
trap cleanup_prod EXIT

# Start development app
echo "Starting development app..."
npm run serve &
echo $! > .pidfile_dev
health_check "$dev_port" "Development app"

# Stop development app
function cleanup_dev {
  if [ -f .pidfile_dev ]; then
    echo "Stopping development app..."
    kill "$(cat .pidfile_dev)"
    rm -f .pidfile_dev
  fi
}
trap cleanup_dev EXIT
