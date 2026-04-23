@echo off
setlocal EnableDelayedExpansion

echo ==========================================
echo     WhatsApp Gateway Setup ^& Launcher     
echo ==========================================
echo.

IF NOT EXIST .env (
    echo --- First Time Setup ---
    echo It looks like this is your first time running the server.
    echo We need to set up your secure web interface.
    echo.
    
    set /p "USER_PASS=Create a password for the web interface: "
    
    rem Use PowerShell to generate a secure random 64-character session secret
    for /f "usebackq tokens=*" %%a in (`powershell -Command "[guid]::NewGuid().ToString('N') + [guid]::NewGuid().ToString('N')"`) do (
        set SESSION_SECRET=%%a
    )
    
    echo PASSWORD=!USER_PASS!> .env
    echo SESSION_SECRET=!SESSION_SECRET!>> .env
    echo.
    echo [OK] Configuration saved securely to the .env file!
) ELSE (
    echo [OK] Existing .env configuration found. Skipping setup.
)

echo.
echo --- Starting the Server ---
echo Starting Docker containers in the background...
docker compose up -d --build

echo.
echo ==========================================
echo Server is starting up!
echo.
echo To stop the server later, run: docker compose down
echo Please wait a minute after the gateway is ready before accessing the web interface. This might take a bit of time on the first run as it sets up everything.
echo ==========================================
docker compose logs -f
pause