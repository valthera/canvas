#!/bin/sh
set -e

echo "Ensuring environment variable files exist..."

# Ensure a root .env exists. If /app/.env.example exists, copy it; otherwise, create an empty file.
if [ ! -f /app/.env ]; then
  if [ -f /app/.env.example ]; then
    cp /app/.env.example /app/.env
    echo "Copied /app/.env.example to /app/.env"
  else
    echo "No /app/.env.example found at root. Creating empty /app/.env file."
    touch /app/.env
  fi
fi

# For each subdirectory, if .env doesn't exist, copy .env.example to .env
for env_dir in /app/apps/agents /app/apps/web; do
  if [ -f "$env_dir/.env.example" ]; then
    if [ ! -f "$env_dir/.env" ]; then
      cp "$env_dir/.env.example" "$env_dir/.env"
      echo "Copied $env_dir/.env.example to $env_dir/.env"
    else
      echo "$env_dir/.env already exists."
    fi
  else
    echo "No .env.example found in $env_dir, skipping."
  fi
done

cd /app

# Force install all dependencies (including dev dependencies) even if NODE_ENV is production
echo "Installing all dependencies (including dev dependencies)..."
NODE_ENV=development yarn install

# Build the project with NODE_ENV set to development so that dev dependencies are available
echo "Building the project..."
NODE_ENV=development yarn build

if [ "$NODE_ENV" = "production" ]; then
  echo "Running in production mode..."

  echo "Starting LangGraph server (agents)..."
  cd /app/apps/agents
  yarn start &

  echo "Starting Web application..."
  cd /app/apps/web
  yarn start
else
  echo "Running in development mode..."
  echo "Starting LangGraph server (agents)..."
  cd /app/apps/agents
  yarn dev &

  echo "Starting Web application..."
  cd /app/apps/web
  yarn dev
fi
