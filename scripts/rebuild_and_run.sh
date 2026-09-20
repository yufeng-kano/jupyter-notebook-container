#!/bin/bash

# Script to rebuild and restart Docker Compose containers
# Usage: ./rebuild_and_run.sh

set -e  # Exit on error

echo "Starting Docker Compose rebuild and restart process..."

# Navigate to the project root directory (one level up from scripts/)
cd "$(dirname "$0")/.."

echo "Building Docker Compose images..."
docker compose build

echo "Stopping running containers..."
docker compose stop

echo "Starting containers in detached mode..."
docker compose up -d

echo "Done! Containers are now running."
echo "Use 'docker compose logs -f' to view logs."
