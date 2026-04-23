require('dotenv').config();
const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const bodyParser = require('body-parser');
const session = require('express-session');
const rateLimit = require('express-rate-limit');

const app = express();
const PASSWORD = process.env.PASSWORD || 'admin123'; 

app.use(bodyParser.urlencoded({ extended: true }));
app.use(session({
    secret: process.env.SESSION_SECRET || 'fallback-secret-key',
    resave: false,
    saveUninitialized: true
}));

const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 5,
    message: "Too many login attempts. Please try again later."
});

const checkAuth = (req, res, next) => {
    if (req.session.loggedIn) return next();
    res.send(`<html><head><meta name="viewport" content="width=240, initial-scale=1.0"></head>
        <body style="background:#000;color:#fff;font-family:sans-serif;">
        <h3>Login</h3>
        <form action="/login" method="post">
            <input type="password" name="pw"><br><br>
            <input type="submit" value="login">
        </form>
    </body></html>`);
};

app.post('/login', loginLimiter, (req, res) => {
    if (req.body.pw === PASSWORD) {
        req.session.loggedIn = true;
        res.redirect('/');
    } else {
        res.send("Invalid password. <a href='/'>Try again</a>");
    }
});

const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: { 
        executablePath: '/usr/bin/chromium-browser', // Explicitly point to Alpine's Chromium
        args: [
            '--no-sandbox', 
            '--disable-setuid-sandbox', 
            '--disable-dev-shm-usage',
            '--disable-gpu'
        ] 
    }
});

client.on('qr', qr => {
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => console.log('WhatsApp Gateway is ready!'));

app.get('/', checkAuth, async (req, res) => {
    try {
        const chats = await client.getChats();
        let html = `<html><head><meta name="viewport" content="width=240, initial-scale=1.0"></head>
        <body style="background:#000;color:#fff;font-family:sans-serif;margin:0;padding:0;">
        <div style="background:#25D366;color:#000;padding:5px;"><b>WhatsApp</b></div>
        <table width="100%" border="0" cellspacing="0" cellpadding="8">`;
        
        chats.slice(0, 20).forEach(chat => {
            const hasUnread = chat.unreadCount > 0;
            const titleColor = hasUnread ? '#25D366' : '#ffffff';
            const unreadText = hasUnread ? ` <b>(${chat.unreadCount})</b>` : '';
            
            html += `<tr><td style="border-bottom:1px solid #333;">
                <a href="/chat/${chat.id._serialized}" style="color:${titleColor};text-decoration:none;">
                    ${chat.name || chat.id.user}${unreadText}
                </a>
            </td></tr>`;
        });
        
        html += `</table></body></html>`;
        res.send(html);
    } catch (e) { res.send("Wrong: " + e.message); }
});

app.get('/chat/:id', checkAuth, async (req, res) => {
    try {
        const chat = await client.getChatById(req.params.id);
        if (chat.unreadCount > 0) await chat.sendSeen();
        
        let msgs = [];
        try { msgs = await chat.fetchMessages({ limit: 10 }); } catch (msgErr) { console.error(msgErr); }

        let html = `<html><head><meta name="viewport" content="width=240, initial-scale=1.0"></head>
        <body style="background:#eee;color:#000;font-family:sans-serif;margin:0;padding:0;">
        <div style="background:#25D366;color:#000;padding:5px;">
            <a href="/" style="color:#000;text-decoration:none;"><b>[< Back]</b></a> ${chat.name}
        </div>
        <div style="padding:4px;">`;
        
        if (msgs.length === 0) html += `<i>No messages.</i><br><br>`;

        for (let m of msgs) {
            const align = m.fromMe ? 'right' : 'left';
            const bg = m.fromMe ? '#dcf8c6' : '#ffffff';
            const date = new Date(m.timestamp * 1000);
            const timeStr = date.getHours().toString().padStart(2, '0') + ':' + date.getMinutes().toString().padStart(2, '0');

            let senderHtml = '';
            if (!m.fromMe && chat.isGroup) {
                try {
                    const contact = await m.getContact();
                    const senderName = contact.name || contact.pushname || contact.number;
                    senderHtml = `<div style="font-size:10px; color:#128C7E; font-weight:bold; margin-bottom:2px;">${senderName}</div>`;
                } catch (e) { senderHtml = `<div style="font-size:10px; color:#128C7E; font-weight:bold; margin-bottom:2px;">Contact</div>`; }
            }

            let mediaHtml = '';
            if (m.hasMedia) {
                let mediaType = "Media";
                if (m.type === 'image') mediaType = "image";
                if (m.type === 'sticker') mediaType = "Sticker";
                if (m.type === 'video') mediaType = "Video";
                if (m.type === 'audio' || m.type === 'ptt') mediaType = "audio";
                if (m.type === 'document') mediaType = "Document";
                mediaHtml = `<div style="font-size:11px; color:#555; font-style:italic; margin-bottom: 2px;">[${mediaType}]</div>`;
            }

            html += `<div style="text-align:${align}; margin-bottom:5px;">
                <div style="background:${bg}; border:1px solid #ccc; padding:4px; display:inline-block; text-align:left; max-width:90%;">
                    ${senderHtml}
                    ${mediaHtml}
                    <div style="font-size:12px;">${m.body || ''}</div>
                    <div style="font-size:9px; color:#888; text-align:right; margin-top:3px;">${timeStr}</div>
                </div>
            </div>`;
        }

        html += `</div><hr>
        <form action="/send" method="post" style="padding:4px;margin:0;">
            <input type="hidden" name="to" value="${req.params.id}">
            <input type="text" name="msg" style="width:140px;">
            <input type="submit" value="OK">
        </form><br><br></body></html>`;
        
        res.send(html);
    } catch (err) { res.send("Error loading chat: " + err.message + " <br><a href='/'>Back</a>"); }
});

app.post('/send', checkAuth, async (req, res) => {
    await client.sendMessage(req.body.to, req.body.msg);
    res.redirect('/chat/' + req.body.to);
});

client.initialize();
app.listen(3000, '0.0.0.0');