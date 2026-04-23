#!/bin/bash

echo "=========================================="
echo "    WhatsApp Gateway Setup & Launcher     "
echo "=========================================="
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "--- First Time Setup ---"
    echo "It looks like this is your first time running the server."
    echo "Let's set up your secure environment."
    echo ""
    
    read -p "Create a password for the web interface: " USER_PASS
    
    # Generate a secure 64-character hex string for the session secret
    SESSION_SECRET=$(openssl rand -hex 32)
    
    echo "PASSWORD=$USER_PASS" > .env
    echo "SESSION_SECRET=$SESSION_SECRET" >> .env
    
    echo ""
    echo "[OK] Configuration saved securely to the .env file!"
else
    echo "[OK] Existing .env configuration found. Skipping setup."
fi

echo ""
echo "--- Starting the Server ---"
echo "Starting Docker containers in the background..."
docker compose up -d --build

echo ""
echo "=========================================="
echo "Server is starting up!"
echo ""
echo "To stop the server later, run: docker compose down"
echo "Please wait a minute after the gateway is ready before accessing the web interface. This might take a bit of time on the first run as it sets up everything."
echo "=========================================="
docker compose logs -f