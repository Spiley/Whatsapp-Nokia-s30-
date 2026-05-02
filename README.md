Nokia WhatsApp Gateway
======================

This project provides a WhatsApp server and gateway specifically designed for Nokia or other dumb phones that cannot run the modern WhatsApp application. It provides a lightweight web interface to interact with WhatsApp chats on older hardware.

Features
--------

*   **WhatsApp Integration**: Uses whatsapp-web.js to create a gateway for your WhatsApp account.

*   **Legacy Web Interface**: A minimalist HTML interface optimized for small screens (e.g., 240px width) common on older mobile devices.

*   **Password-Free Nokia Access**: A secret token baked into a bookmark URL lets your Nokia open the gateway without ever typing a password. Sessions also persist for 30 days on browsers that support cookies.

*   **Secure Access**: Password login with session management and rate limiting is still available for other browsers.

*   **Chat Management**: View a list of recent chats with unread message indicators.

*   **Messaging**: Read message history and send new text messages directly from the browser.

*   **Media Support**: Includes indicators for images, stickers, videos, audio, and documents.

*   **Group Support**: Identify individual senders within group chats.


Prerequisites
-------------
*   A VPS, homeserver, PC, or laptop that can run 24/7
*   Docker

Configuration
-------------
1.  Clone the repository using: ` git clone https://github.com/Spiley/Whatsapp-Dumbphone `

Installation & Setup
--------------------
### setup
[![Watch the video](https://img.youtube.com/vi/djEMivwf7oo/maxresdefault.jpg)](https://www.youtube.com/watch?v=djEMivwf7oo)
### Windows
click on start.bat

### MacOS
click on start.sh

### Linux
` sudo sh start.sh `

### Manual Setup

Alternatively, you can run the commands manually:

` docker compose up -d --build `

` docker compose logs -f `


Usage
-----

1.  **Scan**: Scan the displayed QR code with your primary WhatsApp device.

2.  **Access**: Navigate to `http://[server-ip]:3000` on your legacy device's browser.

3.  **Login**: Enter the PASSWORD defined in your .env file — or use the Nokia bookmark URL (see below).


Nokia Bookmark URL (password-free access)
-----------------------------------------

When you run `start.bat` or `start.sh`, the script automatically generates a secret access token and prints a ready-to-use bookmark URL at the end, like this:

```
http://[your-server-ip]:3000/?token=e887b0f2e9c76a9b51b16b584efdc813
```

**Save this URL as a bookmark on your Nokia.** Opening it skips the login screen entirely — no password to type. Every link inside the gateway (chat list, back button, send form) automatically keeps the token in the URL, so you stay logged in as you navigate.

If you are using a Cloudflare Tunnel, replace the host part with your tunnel domain:

```
https://your-tunnel-domain.example.com/?token=e887b0f2e9c76a9b51b16b584efdc813
```

The token is stored in `ACCESS_TOKEN` in your `.env` file. If you ever need to look it up again, open `.env` — or just rerun the start script and it will be printed again. If you want to revoke access, delete the `ACCESS_TOKEN` line from `.env` and restart the server; a new token will be generated next time you run the start script.


**Important Note**: After the WhatsApp gateway is ready, wait approximately one or two minute(s) before it works.

Access
-----
To access the server I would recommend to use a cloudflare tunnel

https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/

When this is done, you can access your WhatsApp on your own domain or IP address.
