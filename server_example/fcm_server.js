// Example Node.js server for FCM v1 API
// This should be deployed on your backend server

const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');

// Initialize Firebase Admin SDK with service account
const serviceAccount = require('./path/to/your/service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const app = express();
app.use(cors());
app.use(express.json());

// Endpoint to send notifications
app.post('/send-notification', async (req, res) => {
  try {
    const { token, title, body, data } = req.body;
    
    const message = {
      notification: {
        title: title,
        body: body
      },
      data: data || {},
      token: token
    };
    
    const response = await admin.messaging().send(message);
    res.status(200).json({ success: true, messageId: response });
    
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`FCM Server running on port ${PORT}`);
});