import os
import subprocess
import secrets
import getpass
import sys
import shutil
import platform

def install_nodejs():
    print("Node.js is missing. Attempting automatic installation...")
    os_system = platform.system()

    try:
        if os_system == "Windows":
            subprocess.run(["winget", "install", "-e", "--id", "OpenJS.NodeJS", "--accept-source-agreements", "--accept-package-agreements"], check=True)
        elif os_system == "Darwin":
            subprocess.run(["brew", "install", "node"], check=True)
        elif os_system == "Linux":
            subprocess.run(["sudo", "apt-get", "update"], check=True)
            subprocess.run(["sudo", "apt-get", "install", "-y", "nodejs", "npm"], check=True)
        else:
            print(f"Automatic installation not supported for {os_system}.")
            print("Please install manually from https://nodejs.org/")
            sys.exit(1)
        
        print("\nNode.js installed successfully.")
        print("IMPORTANT: You must close this terminal/window and open a new one for the changes to take effect.")
        print("After restarting, run the start script again.")
        sys.exit(0)

    except (subprocess.CalledProcessError, FileNotFoundError):
        print("\nAutomatic installation failed. Package manager (winget/brew/apt) might be missing or requires permissions.")
        print("Please install Node.js manually from https://nodejs.org/")
        sys.exit(1)

npm_path = shutil.which("npm")
node_path = shutil.which("node")

if not node_path or not npm_path:
    install_nodejs()

def setup_env():
    if not os.path.exists(".env"):
        print("--- First Time Setup ---")
        password = getpass.getpass("Set a password for the web interface: ")
        session_secret = secrets.token_hex(32)
        
        with open(".env", "w") as f:
            f.write(f"PASSWORD={password}\nSESSION_SECRET={session_secret}\n")
        print(".env configuration saved.")

def install_dependencies():
    print("Installing dependencies... (This downloads Chromium and may take a moment)")
    try:
        subprocess.run([npm_path, "install"], check=True)
    except subprocess.CalledProcessError:
        print("Error installing Node.js dependencies. Check your internet connection.")
        sys.exit(1)

def start_server():
    print("\nStarting WhatsApp Gateway...")
    try:
        subprocess.run([node_path, "index.js"])
    except KeyboardInterrupt:
        print("\nServer stopped.")

if __name__ == "__main__":
    setup_env()
    install_dependencies()
    start_server()