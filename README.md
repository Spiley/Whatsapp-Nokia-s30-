Nokia WhatsApp Gateway
======================

This project provides a WhatsApp server and gateway specifically designed for Nokia or other dumb phones that cannot run the modern WhatsApp application. It provides a lightweight web interface to interact with WhatsApp chats on older hardware.

Features
--------

*   **WhatsApp Integration**: Uses whatsapp-web.js to create a gateway for your WhatsApp account.
    
*   **Legacy Web Interface**: A minimalist HTML interface optimized for small screens (e.g., 240px width) common on older mobile devices.
    
*   **Secure Access**: Features a login system with session management and rate limiting to prevent unauthorized access.
    
*   **Chat Management**: View a list of recent chats with unread message indicators.
    
*   **Messaging**: Read message history and send new text messages directly from the browser.
    
*   **Media Support**: Includes indicators for images, stickers, videos, audio, and documents.
    
*   **Group Support**: Identify individual senders within group chats.
    

Prerequisites
-------------
*   A VPS, homeserver, PC, or laptop that can run 24/7   

Configuration
-------------
1.  Clone the repository using: ` git clone https://github.com/Spiley/Whatsapp-Dumbphone `

Installation & Setup
--------------------

### Windows

click start.bat 

### Windows

click start.bat 


### Manual Setup

Alternatively, you can run the Docker commands manually:

python run.py or python3 run.py


Usage
-----
    
1.  **Scan**: Scan the displayed QR code with your primary WhatsApp device.
    
2.  **Access**: Navigate to http://\[server-ip\]:3000 on your legacy device's browser.
    
3.  **Login**: Enter the PASSWORD defined in your .env file.
    

**Important Note**: After the WhatsApp gateway is ready, wait approximately one minute before it works.

Access
-----
To access the server I would recommend to use a cloudflare tunnel

https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/
