#!/bin/bash
set -e

cd ./docs

echo "Installing dependencies..."
yarn install --frozen-lockfile

echo "Building the website..."
yarn build

echo "Docusaurus build completed successfully!"