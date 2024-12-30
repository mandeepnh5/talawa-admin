#!/bin/bash
set -e

# Navigate to the Docusaurus directory
cd ./docs

# Install dependencies
echo "Installing dependencies..."
yarn install --frozen-lockfile

# Build the website
echo "Building the website..."
yarn build

echo "Docusaurus build completed successfully!"