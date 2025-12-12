# 🏗️ Kiến trúc ứng dụng - Garage Management

## 📋 Tổng quan

Ứng dụng sử dụng **Clean Architecture** + **Provider State Management** + **GoRouter Navigation**

```
Presentation (UI)
      ↓
State Management (Provider)
      ↓
Services (API, Auth, Settings)
      ↓
Models (Data Structures)
```

## 📂 Cấu trúc thư mục

```
lib/
├── main.dart                    # Entry point, MultiProvider setup
├── router.dart                  # Navigation routes (GoRouter)
│
├── models/                      # Data models (Entities)
│   ├── parking_spot.dart        # Bãi xe (id, name, lat, lng, isAvailable, pricePerHour)
│   ├── vehicle.dart             # Phương tiện (id, plate, model, ownerName)
│   ├── reservation.dart         # Đặt chỗ (id, spotId, vehicleId, startAt, endAt, status)
│   ├── transaction_record.dart   # Giao dịch (id, amount, date, method, status)
│   ├── car.dart                 # (legacy)
│   ├── customer.dart            # (legacy)
│   └── staff.dart               # (legacy)
│
├── providers/                   # State management (ChangeNotifier)
│   ├── parking_provider.dart    # Quản lý bãi xe (loadSpots, reserve)
│   ├── vehicles_provider.dart   # Quản lý phương tiện (addVehicle, removeVehicle)
│   ├── transactions_provider.dart # Lịch sử giao dịch
│   ├── settings_provider.dart   # Cài đặt (baseUrl, SharedPreferences)
│   └── providers.dart           # Barrel export (tất cả providers)
│
├── services/                    # Business logic & External APIs
│   ├── api_service.dart         # API calls (mock fallback + HTTP)
│   ├── auth_service.dart        # Authentication (login, register) - stub
│   ├── firestore_service.dart   # Firebase Firestore - stub
│   └── firebase_options.dart    # Firebase config - stub
│
├── screens/                     # UI Screens (StatefulWidget/StatelessWidget)
│   ├── auth/
│   │   ├── login_screen.dart    # Đăng nhập (email: user@test.com, pwd: 123456)
│   │   └── register_screen.dart # Đăng ký
│   ├── dashboard/
│   │   └── dashboard_screen.dart # Bảng điều khiển (stats, quick actions)
│   ├── main_menu.dart           # Menu chính (6 nút điều hướng)
│   ├── parking_list_screen.dart # Danh sách bãi xe + tìm kiếm
│   ├── reservation_screen.dart  # Đặt chỗ (chọn xe, số giờ, thanh toán)
│   ├── map_screen.dart          # Bản đồ (FlutterMap + markers)
│   ├── vehicles_screen.dart     # Quản lý phương tiện
│   ├── payment_screen.dart      # Thanh toán
│   ├── transactions_screen.dart # Lịch sử giao dịch
│   └── settings_screen.dart     # Cài đặt API
│
└── widgets/                     # Reusable UI components
    └── parking_card.dart        # Widget hiển thị bãi xe (icon, status, price)
```

## 🔄 Luồng dữ liệu

### 1️⃣ **Authentication Flow**
```
LoginScreen
  ↓ (email, password)
ApiService.authenticate() [Mock]
  ↓ (2s delay, validate hardcoded creds)
Success → context.go('/dashboard')
Fail → show snackbar
```

### 2️⃣ **Parking Management Flow**
```
DashboardScreen (mounted)
  ↓ (didChangeDependencies)
ParkingProvider.loadSpots()
  ↓
ApiService.fetchParkingSpots()
  ↓ (baseUrl? HTTP : mock 6 spots)
Update state → rebuild UI
```

### 3️⃣ **Reservation Flow**
```
ParkingListScreen (tap reserve)
  ↓
ReservationScreen (dropdown vehicles, +/- hours)
  ↓ (click confirm)
ApiService.createPayment() → TransactionRecord
ApiService.reserve() → update spot.isAvailable
ParkingProvider.reserve() → reload spots
  ↓
PaymentScreen (show receipt)
```

### 4️⃣ **Settings Flow**
```
SettingsScreen (input baseUrl)
  ↓ (click Save)
SettingsProvider.saveApiUrl()
  ↓
SharedPreferences.setString('api_base_url', url)
  ↓
ApiService.baseUrl = url
  ↓ (next API call uses new URL)
```

## 🔌 Provider Dependencies

```
MultiProvider(
  ├─ SettingsProvider (loads baseUrl from SharedPreferences)
  ├─ ParkingProvider (depends on ApiService from SettingsProvider)
  ├─ VehiclesProvider (independent, mock data)
  └─ TransactionsProvider (independent, mock data)
)
```

## 🌐 API Endpoints

Nếu `ApiService.baseUrl` không rỗng:

| Endpoint | Method | Response |
|----------|--------|----------|
| `/parking-spots` | GET | List<ParkingSpot> |
| `/reservations` | POST | {success: bool, reservationId: string} |
| `/payments` | POST | {success: bool, transactionId: string} |

## 🗄️ Persistent Storage

Dùng **SharedPreferences**:
- `api_base_url` → API Base URL (cài đặt trong Settings)

## 🎨 UI/UX

### Routing Tree
```
/
├─ /login (entry)
├─ /register
├─ /dashboard
├─ /menu
├─ /parking
├─ /map
├─ /vehicles
├─ /transactions
├─ /settings
└─ /reservation
```

### Color Scheme
- **Primary**: Flutter default (Blue 500)
- **Available spot**: Green (#4CAF50)
- **Booked spot**: Red (#F44336)
- **Text**: Black / White (Material theme)

## 🚀 Performance Notes

1. **Lazy Loading**: Providers lazily initialize ApiService
2. **Provider Rebuild**: Only affected widgets rebuild (not full screen)
3. **Mock Fallback**: No network required for demo
4. **SharedPreferences**: Cached on local storage (fast)

## 🔒 Security Notes

⚠️ **Current State** (Demo):
- Hardcoded test credentials (user@test.com / 123456)
- No real authentication backend
- No token/JWT handling
- No encryption for SharedPreferences

✅ **Production To-Do**:
- Implement real backend authentication
- Add secure token storage
- Use encrypted SharedPreferences
- Validate API responses
- Implement error handling

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5+1          # State management
  go_router: ^17.0.0          # Navigation
  shared_preferences: ^2.2.2  # Local storage
  http: ^0.13.6               # HTTP requests
  flutter_map: ^4.0.0         # Map display
  latlong2: ^0.8.2            # Geolocation
  intl: ^0.19.0               # Localization
```

## 🧪 Testing

### Unit Tests
- Mock ApiService
- Test provider logic
- Test state changes

### Widget Tests
- Test UI rendering
- Test navigation
- Test user interactions

### Integration Tests
- Full app flow (login → dashboard → reserve)
- API integration
- SharedPreferences persistence

---

**Last Updated**: December 11, 2025  
**Architecture Pattern**: Clean + MVVM + Provider  
**State Management**: Provider 6.1.5+1
