#!/bin/bash

# Cloud Tasks Queue Oluşturma Scripti
# RevenueCat webhook payment processing için gerekli

PROJECT_ID="disciplify-26970"
LOCATION="us-central1"
QUEUE_NAME="payment-processing"

echo "🚀 Creating Cloud Tasks Queue..."
echo "Project: $PROJECT_ID"
echo "Location: $LOCATION"
echo "Queue: $QUEUE_NAME"
echo ""

# Queue oluştur
gcloud tasks queues create $QUEUE_NAME \
  --project=$PROJECT_ID \
  --location=$LOCATION \
  --max-dispatches-per-second=500 \
  --max-concurrent-dispatches=1000 \
  --max-attempts=3 \
  --min-backoff=1s \
  --max-backoff=60s \
  --max-doublings=3

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Queue created successfully!"
  echo ""
  echo "📋 Queue details:"
  gcloud tasks queues describe $QUEUE_NAME \
    --project=$PROJECT_ID \
    --location=$LOCATION
else
  echo "❌ Failed to create queue"
  echo "Queue might already exist, checking..."
  echo ""
  gcloud tasks queues describe $QUEUE_NAME \
    --project=$PROJECT_ID \
    --location=$LOCATION
fi






