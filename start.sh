#!/bin/bash

echo "=========================================="
echo "    WhatsApp Gateway Setup & Launcher     "
echo "=========================================="
echo ""

if [ ! -f .env ]; then
    echo "--- First Time Setup ---"
    echo "It looks like this is your first time running the server."
    echo "Let's set up your secure environment."
    echo ""

    read -p "Create a password for the web interface: " USER_PASS

    # Generate a secure 64-character hex string for the session secret
    SESSION_SECRET=$(openssl rand -hex 32)

    # Generate a random access token for Nokia bookmark access
    ACCESS_TOKEN=$(openssl rand -hex 16)

    echo "PASSWORD=$USER_PASS" > .env
    echo "SESSION_SECRET=$SESSION_SECRET" >> .env
    echo "ACCESS_TOKEN=$ACCESS_TOKEN" >> .env

    echo ""
    echo "[OK] Configuration saved securely to the .env file!"
else
    echo "[OK] Existing .env configuration found. Skipping setup."

    # If ACCESS_TOKEN is missing from an older .env, generate and add it now
    if ! grep -q "^ACCESS_TOKEN=" .env; then
        ACCESS_TOKEN=$(openssl rand -hex 16)
        echo "ACCESS_TOKEN=$ACCESS_TOKEN" >> .env
        echo "[OK] Access token added to existing .env"
    fi
fi

# Read the ACCESS_TOKEN from .env so we can display it
ACCESS_TOKEN=$(grep "^ACCESS_TOKEN=" .env | cut -d'=' -f2)

echo ""
echo "--- Starting the Server ---"
echo "Starting Docker containers in the background..."
docker compose up -d --build

echo ""
echo "=========================================="
echo "Server is starting up!"
echo ""
echo "*** Nokia Bookmark URL ***"
echo "Save this URL as a bookmark on your Nokia for password-free access:"
echo ""
echo "  http://[your-server-ip]:3000/?token=$ACCESS_TOKEN"
echo ""
echo "Replace [your-server-ip] with the actual IP or hostname."
echo "If using Cloudflare Tunnel, replace the whole host part with your tunnel domain."
echo ""
echo "To stop the server later, run: docker compose down"
echo "Please wait a minute after the gateway is ready before accessing the web interface."
echo "This might take a bit of time on the first run as it sets up everything."
echo "=========================================="
docker compose logs -f
