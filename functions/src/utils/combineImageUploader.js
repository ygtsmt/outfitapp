const admin = require('firebase-admin');
const axios = require('axios');
const path = require('path');
const os = require('os');
const fs = require('fs');

/**
 * Uploads a generated combine image to Firebase Storage
 * @param {string} imageUrl - The temporary URL from Fal.ai
 * @param {string} requestId - The request ID associated with the generation
 * @returns {Promise<string>} - The public URL of the uploaded image
 */
async function uploadCombineImageToFirebase(imageUrl, requestId) {
    try {
        console.log(`Starting upload for combine image: ${imageUrl}`);

        // Download the image
        const response = await axios({
            url: imageUrl,
            method: 'GET',
            responseType: 'arraybuffer'
        });

        const buffer = Buffer.from(response.data, 'binary');
        const bucket = admin.storage().bucket();

        // Create a unique filename
        const timestamp = Date.now();
        const fileName = `user_images/combines/${requestId}/${timestamp}.png`;
        const file = bucket.file(fileName);

        // Upload to Firebase Storage
        await file.save(buffer, {
            metadata: {
                contentType: 'image/png',
                metadata: {
                    requestId: requestId,
                    source: 'fal_ai_gemini_edit'
                }
            }
        });

        // Make the file public
        await file.makePublic();

        // Get the public URL
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
        console.log(`Combine image uploaded successfully: ${publicUrl}`);

        return publicUrl;
    } catch (error) {
        console.error('Error uploading combine image to Firebase:', error);
        throw error;
    }
}

module.exports = {
    uploadCombineImageToFirebase
};
