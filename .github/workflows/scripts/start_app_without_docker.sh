#!/bin/bash
set -e

prod_port=4173
dev_port=4321
timeout=120

echo "Starting production app..."
npm run preview &
echo $! > .pidfile_prod

echo "Starting Production app health check with ${timeout}s timeout..."
while ! nc -z localhost "$prod_port" && [ $timeout -gt 0 ]; do
  sleep 1
  timeout=$((timeout - 1))
  if [ $((timeout % 10)) -eq 0 ]; then
    echo "Still waiting for Production app to start... ${timeout}s remaining."
  fi
done
if [ $timeout -eq 0 ]; then
  echo "Timeout waiting for Production app to start."
  exit 1
fi
echo "Production app started successfully."

trap 'if [ -f .pidfile_prod ]; then echo "Stopping production app..."; kill "$(cat .pidfile_prod)"; rm -f .pidfile_prod; fi' EXIT

echo "Starting development app..."
npm run serve &
echo $! > .pidfile_dev

timeout=120
echo "Starting Development app health check with ${timeout}s timeout..."
while ! nc -z localhost "$dev_port" && [ $timeout -gt 0 ]; do
  sleep 1
  timeout=$((timeout - 1))
  if [ $((timeout % 10)) -eq 0 ]; then
    echo "Still waiting for Development app to start... ${timeout}s remaining."
  fi
done
if [ $timeout -eq 0 ]; then
  echo "Timeout waiting for Development app to start."
  exit 1
fi
echo "Development app started successfully."

trap 'if [ -f .pidfile_dev ]; then echo "Stopping development app..."; kill "$(cat .pidfile_dev)"; rm -f .pidfile_dev; fi' EXIT
