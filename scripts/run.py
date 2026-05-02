import os
import subprocess
import secrets
import getpass
import sys
import shutil
import platform

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

npm_path = shutil.which("npm")
node_path = shutil.which("node")

def check_requirements():
    if not node_path or not npm_path:
        print("Error: Node.js is not installed or not in PATH.")
        sys.exit(1)

def install_os_dependencies():
    if platform.system() != "Linux":
        return

    print("Linux detected. Installing required headless libraries...")

    apt_deps = [
        "libnss3", "libatk1.0-0", "libatk-bridge2.0-0", "libxcomposite1",
        "libxrandr2", "libxdamage1", "libgbm1", "libasound2", "libpangocairo-1.0-0",
        "libxss1", "libgtk-3-0"
    ]

    if shutil.which("apt-get"):
        try:
            subprocess.run(["sudo", "apt-get", "update"], check=True)
            subprocess.run(["sudo", "apt-get", "install", "-y"] + apt_deps, check=True)
        except subprocess.CalledProcessError:
            print("Failed to install OS dependencies. Ensure you have sudo privileges.")
    elif shutil.which("dnf"):
        dnf_deps = ["nss", "atk", "at-spi2-atk", "libXcomposite", "libXrandr", "libXdamage", "mesa-libgbm", "alsa-lib", "pango", "libXScrnSaver", "gtk3"]
        subprocess.run(["sudo", "dnf", "install", "-y"] + dnf_deps, check=False)
    elif shutil.which("pacman"):
        pacman_deps = ["nss", "atk", "at-spi2-atk", "libxcomposite", "libxrandr", "libxdamage", "mesa", "alsa-lib", "pango", "libxss", "gtk3"]
        subprocess.run(["sudo", "pacman", "-S", "--noconfirm"] + pacman_deps, check=False)

def setup_env():
    env_path = os.path.join(PROJECT_ROOT, ".env")
    if not os.path.exists(env_path):
        print("--- First Time Setup ---")
        password = getpass.getpass("Set a password for the web interface: ")
        session_secret = secrets.token_hex(32)
        access_token = secrets.token_hex(16)

        with open(env_path, "w") as f:
            f.write(f"PASSWORD={password}\nSESSION_SECRET={session_secret}\nACCESS_TOKEN={access_token}\n")

        print(f".env configuration saved.")
        print(f"\n*** Nokia Bookmark URL ***")
        print(f"Bookmark this URL on your Nokia for password-free access:")
        print(f"  http://[your-server-ip]:3000/?token={access_token}\n")

def install_dependencies():
    print("Installing Node dependencies...")
    try:
        subprocess.run([npm_path, "install"], check=True, cwd=PROJECT_ROOT)
    except subprocess.CalledProcessError:
        print("Error installing dependencies.")
        sys.exit(1)

def start_server():
    print("\nStarting WhatsApp Gateway...")
    try:
        subprocess.run([node_path, "index.js"], cwd=PROJECT_ROOT)
    except KeyboardInterrupt:
        print("\nServer stopped.")

if __name__ == "__main__":
    check_requirements()
    install_os_dependencies()
    setup_env()
    install_dependencies()
    start_server()
