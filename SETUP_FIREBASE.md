# Firebase Setup Guide

## Default Test Account

A default test account has been configured in the app for easy development and testing:

**Email:** `test@test.com`  
**Password:** `123456`  
**Name:** Demo User

### How to Use

1. **On Login Screen:** Click the **"Đăng nhập bằng tài khoản Demo"** button to auto-login with the test account.
2. **Manual Login:** Enter the email and password above in the regular login form.

## Firebase Configuration

The app is already configured to connect to Firebase project: **quanlyxe-f18f4**

### Firebase Setup in Your Project

If you need to set up Firebase from scratch:

1. **Android Setup:**
   - The `google-services.json` file is already configured in `android/app/`
   - No additional action needed

2. **iOS Setup:**
   - The `GoogleService-Info.plist` file is already configured in `ios/Runner/`
   - No additional action needed

3. **Web Setup:**
   - Firebase is initialized in `lib/main.dart` using `DefaultFirebaseOptions.web`
   - The web config is auto-detected from `lib/firebase_options.dart`

### Database Structure

#### Firestore Collections

**Users Collection (`users/`):**
```json
{
  "uid": "user-unique-id",
  "email": "user@example.com",
  "fullName": "User Full Name",
  "role": "user",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Parking Spots Collection (`parking_spots/`):**
```json
{
  "id": "spot-id",
  "name": "Spot A1",
  "lat": 10.776530,
  "lng": 106.700981,
  "isAvailable": true,
  "pricePerHour": 50000,
  "reservedBy": "user-uid",
  "createdAt": "timestamp"
}
```

### Auto-Create Demo Account

The first time you tap "Demo Login" on a fresh Firebase project:
- If the account doesn't exist, it will be automatically created
- User data is stored in Firestore under the `users` collection
- You're instantly logged in and can access the dashboard

## Testing the App

```bash
# Run on Chrome (Web)
flutter run -d chrome

# Run on Android Emulator
flutter run -d emulator-5554

# Run on iOS Simulator
flutter run -d iOS
```

After launching, tap **"Đăng nhập bằng tài khoản Demo"** to log in with the test account.

## Security Note

⚠️ **For Development Only**  
The demo account credentials are hardcoded in the app for testing purposes. For production:
- Remove or secure the demo login button
- Implement proper user authentication flows
- Use Firebase Security Rules to protect your data
