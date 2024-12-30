#!/bin/bash
set -e

# Variables
image_name="talawa-admin-app"
container_name="talawa-admin-app-container"
port=4321
timeout="${HEALTH_CHECK_TIMEOUT:-120}"

# Build Docker image
echo "Building Docker image..."
docker build -t "$image_name" .
echo "Docker image built successfully."

# Run Docker container
echo "Starting Docker container..."
docker run -d --name "$container_name" -p "$port:$port" "$image_name"
echo "Docker container started successfully."

# Check if the application is running
echo "Starting health check with ${timeout}s timeout..."
while ! nc -z localhost "$port" && [ $timeout -gt 0 ]; do
  sleep 1
  timeout=$((timeout-1))
  if [ $((timeout % 10)) -eq 0 ]; then
    echo "Still waiting for app to start... ${timeout}s remaining"
  fi
done

if [ $timeout -eq 0 ]; then
  echo "Timeout waiting for application to start."
  echo "Container logs:"
  docker logs "$container_name"
  docker stop "$container_name"
  docker rm "$container_name"
  exit 1
fi

echo "Health check passed, application is running on port $port."

# Cleanup
trap "docker stop $container_name && docker rm $container_name" EXIT
