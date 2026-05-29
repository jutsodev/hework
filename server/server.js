require('dotenv').config();
const express = require('express');
const cors = require('cors');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const admin = require('firebase-admin');

// ============================================================
// HeWork Messenger Backend Server
// Email Verification & Push Notification Service
// ============================================================

const app = express();
app.use(cors());
app.use(express.json());

// MARK: - Firebase Admin Initialization

let firebaseApp;
try {
    firebaseApp = admin.initializeApp({
        credential: admin.credential.cert({
            projectId: process.env.FIREBASE_PROJECT_ID,
            privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        }),
    });
    console.log('✅ Firebase Admin initialized');
} catch (error) {
    console.warn('⚠️ Firebase Admin not initialized:', error.message);
}

// MARK: - Email Transport Configuration

const emailTransport = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.hework.io',
    port: parseInt(process.env.SMTP_PORT || '465'),
    secure: process.env.SMTP_SECURE !== 'false',
    auth: {
        user: process.env.SMTP_USER || 'verification@hework.io',
        pass: process.env.SMTP_PASS,
    },
});

// MARK: - In-Memory Verification Codes Store
// In production, use Redis or Firestore

const verificationCodes = new Map();

// MARK: - Generate Verification Code

function generateCode() {
    return crypto.randomInt(100000, 999999).toString();
}

// MARK: - API Routes

// Health Check
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'HeWork API',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
    });
});

// MARK: - Send Verification Code

app.post('/api/auth/send-code', async (req, res) => {
    try {
        const { email } = req.body;

        if (!email || !email.includes('@')) {
            return res.status(400).json({
                error: 'Неверный формат электронной почты',
                code: 'INVALID_EMAIL',
            });
        }

        // Rate limiting check
        const existing = verificationCodes.get(email);
        if (existing && Date.now() - existing.timestamp < 60000) {
            return res.status(429).json({
                error: 'Подождите перед повторной отправкой',
                code: 'RATE_LIMITED',
                retryAfter: Math.ceil((60000 - (Date.now() - existing.timestamp)) / 1000),
            });
        }

        const code = generateCode();
        const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes

        // Store verification code
        verificationCodes.set(email, {
            code,
            expiresAt,
            timestamp: Date.now(),
            attempts: 0,
        });

        // Send email
        const mailOptions = {
            from: `"HeWork" <${process.env.SMTP_USER || 'verification@hework.io'}>`,
            to: email,
            subject: 'Код подтверждения HeWork',
            html: generateEmailTemplate(code),
        };

        await emailTransport.sendMail(mailOptions);
        console.log(`✅ Verification code sent to ${email}: ${code}`);

        res.json({
            success: true,
            message: 'Код подтверждения отправлен',
            expiresAt,
        });
    } catch (error) {
        console.error('❌ Send code error:', error);
        res.status(500).json({
            error: 'Ошибка отправки кода. Попробуйте позже.',
            code: 'SEND_FAILED',
        });
    }
});

// MARK: - Verify Code

app.post('/api/auth/verify-code', async (req, res) => {
    try {
        const { email, code } = req.body;

        if (!email || !code) {
            return res.status(400).json({
                error: 'Email и код обязательны',
                code: 'MISSING_FIELDS',
            });
        }

        const stored = verificationCodes.get(email);

        if (!stored) {
            return res.status(400).json({
                error: 'Код не найден. Запросите новый код.',
                code: 'CODE_NOT_FOUND',
            });
        }

        // Check expiry
        if (Date.now() > stored.expiresAt) {
            verificationCodes.delete(email);
            return res.status(400).json({
                error: 'Код истёк. Запросите новый код.',
                code: 'CODE_EXPIRED',
            });
        }

        // Check attempts
        if (stored.attempts >= 5) {
            verificationCodes.delete(email);
            return res.status(400).json({
                error: 'Слишком много попыток. Запросите новый код.',
                code: 'TOO_MANY_ATTEMPTS',
            });
        }

        // Verify code
        if (stored.code !== code) {
            stored.attempts++;
            return res.status(400).json({
                error: 'Неверный код подтверждения',
                code: 'INVALID_CODE',
                attemptsRemaining: 5 - stored.attempts,
            });
        }

        // Code verified - clean up
        verificationCodes.delete(email);

        // Create or get Firebase user
        let uid;
        try {
            const userRecord = await admin.auth().getUserByEmail(email);
            uid = userRecord.uid;
        } catch (e) {
            // User doesn't exist, create new
            const userRecord = await admin.auth().createUser({
                email,
                emailVerified: true,
            });
            uid = userRecord.uid;

            // Create user profile in Firestore
            if (firebaseApp) {
                const db = admin.firestore();
                await db.collection('users').doc(uid).set({
                    id: uid,
                    username: email.split('@')[0],
                    handle: '@' + email.split('@')[0],
                    email: email,
                    bio: '',
                    uniqueID: crypto.randomBytes(16).toString('hex'),
                    isOnline: true,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });
            }
        }

        // Generate custom token for client
        const customToken = await admin.auth().createCustomToken(uid);

        console.log(`✅ User verified: ${email}`);

        res.json({
            success: true,
            customToken,
            uid,
        });
    } catch (error) {
        console.error('❌ Verify code error:', error);
        res.status(500).json({
            error: 'Ошибка верификации. Попробуйте позже.',
            code: 'VERIFY_FAILED',
        });
    }
});

// MARK: - Register Push Token

app.post('/api/notifications/register-token', (req, res) => {
    try {
        const { token, userId, platform } = req.body;

        if (!token || !userId) {
            return res.status(400).json({ error: 'Token and userId required' });
        }

        // Store FCM token (in production, use Firestore)
        console.log(`✅ FCM token registered for user ${userId} on ${platform}`);

        if (firebaseApp) {
            const db = admin.firestore();
            db.collection('fcmTokens').doc(userId).set({
                token,
                platform,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        }

        res.json({ success: true });
    } catch (error) {
        console.error('❌ Register token error:', error);
        res.status(500).json({ error: 'Failed to register token' });
    }
});

// MARK: - Send Push Notification

app.post('/api/notifications/send', async (req, res) => {
    try {
        const { chatId, senderId, text } = req.body;

        if (!chatId || !senderId || !text) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        if (!firebaseApp) {
            return res.status(503).json({ error: 'Push notifications not configured' });
        }

        const db = admin.firestore();

        // Get chat participants
        const chatDoc = await db.collection('chats').doc(chatId).get();
        if (!chatDoc.exists) {
            return res.status(404).json({ error: 'Chat not found' });
        }

        const chat = chatDoc.data();
        const recipientIds = chat.participants.filter(id => id !== senderId);

        // Get sender info
        const senderDoc = await db.collection('users').doc(senderId).get();
        const senderName = senderDoc.exists ? senderDoc.data().username : 'Пользователь';

        // Send notification to each recipient
        for (const recipientId of recipientIds) {
            const tokenDoc = await db.collection('fcmTokens').doc(recipientId).get();
            if (!tokenDoc.exists) continue;

            const fcmToken = tokenDoc.data().token;

            const message = {
                notification: {
                    title: senderName,
                    body: text.length > 100 ? text.substring(0, 100) + '...' : text,
                },
                data: {
                    chatId,
                    senderId,
                    type: 'new_message',
                },
                token: fcmToken,
                apns: {
                    payload: {
                        aps: {
                            badge: 1,
                            sound: 'default',
                        },
                    },
                },
            };

            try {
                await admin.messaging().send(message);
                console.log(`✅ Push sent to ${recipientId}`);
            } catch (error) {
                console.error(`❌ Push failed for ${recipientId}:`, error.message);
            }
        }

        res.json({ success: true });
    } catch (error) {
        console.error('❌ Send notification error:', error);
        res.status(500).json({ error: 'Failed to send notification' });
    }
});

// MARK: - Email Template

function generateEmailTemplate(code) {
    return `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>HeWork — Код подтверждения</title>
</head>
<body style="margin: 0; padding: 0; background-color: #0D0D0D; font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', Roboto, sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #0D0D0D; padding: 40px 20px;">
        <tr>
            <td align="center">
                <table width="400" cellpadding="0" cellspacing="0" style="max-width: 400px;">
                    <!-- Logo -->
                    <tr>
                        <td align="center" style="padding-bottom: 32px;">
                            <div style="font-size: 40px; margin-bottom: 8px;">💬</div>
                            <h1 style="color: #FFFFFF; font-size: 28px; font-weight: 700; margin: 0; letter-spacing: -0.5px;">HeWork</h1>
                        </td>
                    </tr>

                    <!-- Code Card -->
                    <tr>
                        <td style="background: linear-gradient(135deg, rgba(156, 39, 176, 0.15), rgba(233, 30, 99, 0.15)); border: 1px solid rgba(255,255,255,0.1); border-radius: 20px; padding: 32px; text-align: center;">
                            <p style="color: #999999; font-size: 14px; margin: 0 0 16px 0;">Ваш код подтверждения</p>
                            <div style="font-size: 42px; font-weight: 800; letter-spacing: 8px; color: #FFFFFF; font-variant-numeric: tabular-nums; font-feature-settings: 'tnum';">${code}</div>
                            <p style="color: #666666; font-size: 12px; margin: 16px 0 0 0;">Код действителен 5 минут</p>
                        </td>
                    </tr>

                    <!-- Info -->
                    <tr>
                        <td style="padding-top: 24px; text-align: center;">
                            <p style="color: #666666; font-size: 13px; margin: 0; line-height: 1.5;">
                                Если вы не запрашивали код, проигнорируйте это письмо.
                            </p>
                        </td>
                    </tr>

                    <!-- Footer -->
                    <tr>
                        <td style="padding-top: 40px; text-align: center; border-top: 1px solid rgba(255,255,255,0.06); margin-top: 32px;">
                            <p style="color: #444444; font-size: 11px; margin: 0;">
                                HeWork Messenger • verification@hework.io
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>`;
}

// MARK: - Cleanup Expired Codes (every 10 minutes)

setInterval(() => {
    const now = Date.now();
    for (const [email, data] of verificationCodes.entries()) {
        if (now > data.expiresAt) {
            verificationCodes.delete(email);
        }
    }
}, 10 * 60 * 1000);

// MARK: - Start Server

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`
    ╔══════════════════════════════════════╗
    ║     🚀 HeWork API Server            ║
    ║     Port: ${PORT}                      ║
    ║     Email: verification@hework.io    ║
    ╚══════════════════════════════════════╝
    `);
});

module.exports = app;
