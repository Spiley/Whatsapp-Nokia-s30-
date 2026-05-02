const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const fs = require('fs');
const path = require('path');

const AUTH_DIR = '/app/.wwebjs_auth';
if (fs.existsSync(AUTH_DIR)) {
    for (const entry of fs.readdirSync(AUTH_DIR)) {
        const profileDir = path.join(AUTH_DIR, entry);
        if (fs.statSync(profileDir).isDirectory()) {
            for (const lock of ['SingletonLock', 'SingletonCookie', 'SingletonSocket']) {
                try { fs.unlinkSync(path.join(profileDir, lock)); } catch (_) {}
            }
        }
    }
}

const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        executablePath: '/usr/bin/chromium-browser',
        args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage', '--disable-gpu']
    }
});

client.on('qr', qr => qrcode.generate(qr, { small: true }));
client.on('ready', () => console.log('WhatsApp Gateway is ready!'));

module.exports = client;
