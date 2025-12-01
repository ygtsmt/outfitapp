# Ginly

AI-powered image and video generation app built with Flutter.

## 📱 Subscription Plans

### Current Plan Information (Updated)

| Plan | Credits/Week | Price (VAT Excluded) | Features |
|------|--------------|---------------------|----------|
| **Plus** | 350 | 119 TL | Basic AI generation, 24/7 support |
| **Pro** | 750 | 229 TL | Advanced AI models, priority processing |
| **Ultra** | 2000 | 699 TL | All AI models, custom training, VIP support |

## 🚀 Getting Started

1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure Firebase
4. Run the app: `flutter run`

## 🔧 Development

### Firebase Setup
- Plans collection contains credit amounts and benefits
- Prices are fetched from Google Play Store via RevenueCat
- Credit amounts are managed in Firebase Functions

### Architecture
- **Frontend:** Flutter with BLoC pattern
- **Backend:** Firebase (Firestore, Auth, Storage, Functions)
- **Payments:** RevenueCat + Google Play Store
- **AI:** External AI services integration

## 📝 Notes

- **Prices are managed in Google Play Console**
- **Credits and benefits are managed in Firebase**
- **RevenueCat handles subscription management**
- **Credit amounts are calculated in Firebase Functions**
