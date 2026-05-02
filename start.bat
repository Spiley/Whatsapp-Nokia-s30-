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

    rem Generate a random access token for Nokia bookmark access
    for /f "usebackq tokens=*" %%a in (`powershell -Command "[guid]::NewGuid().ToString('N')"`) do (
        set ACCESS_TOKEN=%%a
    )

    echo PASSWORD=!USER_PASS!> .env
    echo SESSION_SECRET=!SESSION_SECRET!>> .env
    echo ACCESS_TOKEN=!ACCESS_TOKEN!>> .env
    echo.
    echo [OK] Configuration saved securely to the .env file!
) ELSE (
    echo [OK] Existing .env configuration found. Skipping setup.

    rem If ACCESS_TOKEN is missing from an older .env, generate and add it now
    findstr /b "ACCESS_TOKEN=" .env >nul 2>&1
    IF ERRORLEVEL 1 (
        for /f "usebackq tokens=*" %%a in (`powershell -Command "[guid]::NewGuid().ToString('N')"`) do (
            set ACCESS_TOKEN=%%a
        )
        echo ACCESS_TOKEN=!ACCESS_TOKEN!>> .env
        echo [OK] Access token added to existing .env
    )
)

rem Read the ACCESS_TOKEN from .env so we can display it
for /f "tokens=1,* delims==" %%a in ('findstr /b "ACCESS_TOKEN=" .env') do (
    set DISPLAY_TOKEN=%%b
)

echo.
echo --- Starting the Server ---
echo Starting Docker containers in the background...
docker compose up -d --build

echo.
echo ==========================================
echo Server is starting up!
echo.
echo *** Nokia Bookmark URL ***
echo Save this URL as a bookmark on your Nokia for password-free access:
echo.
echo   http://[your-server-ip]:3000/?token=!DISPLAY_TOKEN!
echo.
echo Replace [your-server-ip] with the actual IP or hostname.
echo If using Cloudflare Tunnel, replace the whole host part with your tunnel domain.
echo.
echo To stop the server later, run: docker compose down
echo Please wait a minute after the gateway is ready before accessing the web interface.
echo This might take a bit of time on the first run as it sets up everything.
echo ==========================================
docker compose logs -f
pause
