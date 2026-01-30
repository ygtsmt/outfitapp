const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

// Initialize Admin SDK provided it hasn't been already
if (admin.apps.length === 0) {
    admin.initializeApp();
}

/**
 * MARATHON AGENT CHRON JOB
 * Runs every 1 minute for testing (Production: every day 08:00).
 * Checks all active missions, fetches weather, analyzes with Gemini, and sends notifications.
 */
exports.checkActiveMissions = functions.pubsub
    .schedule('every 1 minutes')
    .timeZone('Europe/Istanbul')
    .onRun(async (context) => {
        console.log('🏁 Marathon Agent: Starting daily mission check...');

        const db = admin.firestore();
        const messaging = admin.messaging();

        // 1. Get all active missions using Collection Group Query
        // Note: 'preferences' is the collection name, 'mission_status' is the field we added.
        const missionsSnapshot = await db
            .collectionGroup('preferences')
            .where('mission_status', '==', 'active')
            .get();

        if (missionsSnapshot.empty) {
            console.log('✅ No active missions found.');
            return null;
        }

        console.log(`🚀 Found ${missionsSnapshot.size} active missions.`);

        const promises = missionsSnapshot.docs.map(async (doc) => {
            const missionData = doc.data();
            const userId = doc.ref.parent.parent.id; // user doc id

            // Check if expired (Server-side cleanup)
            const startDateStr = missionData.start_date;
            if (startDateStr) {
                const startDate = new Date(startDateStr);
                const today = new Date();
                today.setHours(0, 0, 0, 0); // Normalize today

                // If trip started before today (and it's a 1-day trip logic), it's over.
                // Or simply: if trip is in the past.
                if (startDate < today) {
                    console.log(`🗑️ Mission expired for user ${userId}. Archiving...`);

                    try {
                        // 1. Add to History
                        await db.collection('users').doc(userId).collection('mission_history').add({
                            ...missionData,
                            archived_at: new Date().toISOString(),
                            status: 'completed_by_agent'
                        });

                        // 2. Delete from Active
                        await doc.ref.delete();
                        console.log(`✅ Mission archived and deleted for user ${userId}`);
                    } catch (err) {
                        console.error(`❌ Failed to archive mission for user ${userId}:`, err);
                    }

                    return Promise.resolve();
                }
            }

            // 2. Fetch Weather (Server-side)
            // You need an OpenWeatherMap Key here. 
            // Best practice: functions.config().weather.key or process.env.WEATHER_API_KEY
            // For hackathon/demo, we might hardcode or expect it in env.
            const weatherApiKey = process.env.WEATHER_API_KEY || 'ad2e81eae6edab030974b401bd0e895a';
            let weatherDesc = 'Unknown';
            let weatherTemp = 0;

            try {
                const weatherUrl = `https://api.openweathermap.org/data/2.5/weather?q=${missionData.destination}&appid=${weatherApiKey}&units=metric`;
                const weatherRes = await axios.get(weatherUrl);
                weatherDesc = weatherRes.data.weather[0].description;
                weatherTemp = weatherRes.data.main.temp;
            } catch (error) {
                console.error(`❌ Weather fetch failed for ${missionData.destination}:`, error.message);
                return; // Skip if weather fails
            }

            // 3. Gemini Analysis (Server-side)
            // Need Gemini API Key
            const geminiApiKey = process.env.GEMINI_API_KEY || 'YOUR_GEMINI_KEY';
            let advice = null;

            try {
                const prompt = `
                ACT AS A TRAVEL GUARDIAN.
                Destination: ${missionData.destination}
                Packed Items: ${missionData.items.join(', ')}
                Current Weather: ${weatherDesc}, ${weatherTemp}C.
                
                TASK:
                Analyze risk. If risky, give a short warning title and body.
                Also give a specific local recommendation for this weather.
                
                OUTPUT JSON:
                {
                    "title": "Short Title",
                    "body": "Friendly advice."
                }
                `;

                const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${geminiApiKey}`;
                const geminiRes = await axios.post(geminiUrl, {
                    contents: [{ parts: [{ text: prompt }] }]
                });

                const textResponse = geminiRes.data.candidates[0].content.parts[0].text;

                // Parse JSON (Robust w/ Regex)
                // Kapsayıcı metinlerden (örn: "Here is the JSON: ...") kurtulmak için
                const match = textResponse.match(/\{[\s\S]*\}/);
                if (!match) throw new Error('Invalid JSON structure from Gemini');

                advice = JSON.parse(match[0]);

            } catch (error) {
                console.error(`❌ Gemini analysis failed for user ${userId}:`, error.message);
                // Fallback advice if AI fails
                advice = {
                    title: `Travel Update: ${missionData.destination}`,
                    body: `Current weather is ${weatherDesc} (${weatherTemp}°C). Enjoy your trip!`
                };
            }

            // 4. Send Notification
            if (advice) {
                // Get User's FCM Token
                const userDoc = await db.collection('users').doc(userId).get();
                const fcmToken = userDoc.data()?.fcm_token;

                if (fcmToken) {
                    await messaging.send({
                        token: fcmToken,
                        notification: {
                            title: advice.title,
                            body: advice.body,
                        },
                        data: {
                            type: 'marathon_agent_alert',
                            payload: JSON.stringify(advice)
                        }
                    });
                    console.log(`🔔 Notification sent to user ${userId}`);
                } else {
                    console.log(`⚠️ No FCM token found for user ${userId}`);
                }
            }
        });

        await Promise.all(promises);
        console.log('✅ Daily check completed.');
    });
