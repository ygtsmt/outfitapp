#!/bin/bash

# RevenueCat Webhook Test Script
# Test webhook endpoint and verify credit processing

PROJECT_ID="disciplify-26970"
LOCATION="us-central1"
WEBHOOK_URL="https://${LOCATION}-${PROJECT_ID}.cloudfunctions.net/revenueCatWebhook"

echo "🧪 Testing RevenueCat Webhook..."
echo "URL: $WEBHOOK_URL"
echo ""

# Test 1: INITIAL_PURCHASE event
echo "📝 Test 1: INITIAL_PURCHASE"
echo "─────────────────────────────"

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "INITIAL_PURCHASE",
    "app_user_id": "test_user_123",
    "product_id": "comby_plus_weekly",
    "entitlement_id": "premium",
    "event": {
      "transaction_id": "test_txn_001",
      "price": 9.99,
      "currency": "USD",
      "country_code": "US",
      "store": "PLAY_STORE",
      "environment": "SANDBOX",
      "renewal_number": 1,
      "expiration_at_ms": 1735689600000,
      "purchased_at_ms": 1735603200000
    }
  }'

echo ""
echo ""

# Test 2: ONE_TIME_PURCHASE event
echo "📝 Test 2: ONE_TIME_PURCHASE"
echo "─────────────────────────────"

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "ONE_TIME_PURCHASE",
    "app_user_id": "test_user_456",
    "product_id": "comby_extra_credit",
    "event": {
      "transaction_id": "test_txn_002",
      "price": 4.99,
      "currency": "USD",
      "country_code": "US",
      "store": "APP_STORE",
      "environment": "SANDBOX"
    }
  }'

echo ""
echo ""

# Test 3: RENEWAL event
echo "📝 Test 3: RENEWAL"
echo "─────────────────────────────"

curl -X POST "$WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "RENEWAL",
    "app_user_id": "test_user_123",
    "product_id": "comby_plus_weekly",
    "event": {
      "transaction_id": "test_txn_003",
      "price": 9.99,
      "currency": "USD",
      "country_code": "US",
      "store": "PLAY_STORE",
      "environment": "SANDBOX",
      "renewal_number": 2
    }
  }'

echo ""
echo ""
echo "✅ All tests completed!"
echo ""
echo "📊 Next Steps:"
echo "1. Check Firebase Functions logs: firebase functions:log"
echo "2. Check Cloud Tasks queue: gcloud tasks queues describe payment-processing --location=${LOCATION}"
echo "3. Verify credits in Firestore for test users"
echo ""






