# 🐛 Hướng dẫn Debug & Troubleshooting

## 🔧 Các vấn đề phổ biến & Giải pháp

### 1️⃣ "No devices connected"

**Lỗi**:
```
Error: No devices connected, please connect a device or start an emulator.
```

**Giải pháp**:
```bash
# Xem danh sách device
flutter devices

# Nếu không có device, chạy emulator
# Android:
emulator -avd Pixel_4

# iOS (macOS only):
open -a Simulator

# Hoặc chạy trên web
flutter run -d chrome
```

---

### 2️⃣ "Gradle build failed"

**Lỗi**:
```
ERROR: Gradle build failed: ...
```

**Giải pháp**:
```bash
# Clean build cache
flutter clean

# Delete gradle cache
rm -rf android/.gradle

# Rebuild
flutter pub get
flutter run
```

---

### 3️⃣ "Dependency version conflict"

**Lỗi**:
```
The current Dart SDK version is ... which does not satisfy the constraints ...
```

**Giải pháp**:
```bash
# Update dependencies
flutter pub upgrade

# Hoặc dùng pub.dev để kiểm tra compatibility
# https://pub.dev/packages/<package_name>

# Cuối cùng
flutter pub get
flutter run
```

---

### 4️⃣ "Emulator crash"

**Giải pháp**:
```bash
# Kill all emulators
adb kill-server

# Restart adb daemon
adb start-server

# Launch emulator lại
emulator -avd Pixel_4
```

---

### 5️⃣ "App freeze/crash trên login"

**Nguyên nhân**: Có thể là async code không được await đúng cách.

**Debug**:
```dart
// Thêm print() để trace
Future<void> _handleLogin() async {
  print('🔍 Login started');
  print('Email: ${_emailController.text}');
  
  setState(() => _isLoading = true);
  print('⏳ Waiting 2 seconds...');
  await Future.delayed(const Duration(seconds: 2));
  
  if (!mounted) {
    print('❌ Widget unmounted, returning');
    return;
  }
  print('✅ Widget still mounted');
  
  setState(() => _isLoading = false);
}
```

Chạy:
```bash
flutter run
# Xem log trong terminal
```

---

### 6️⃣ "Api test button không hoạt động"

**Kiểm tra**:

1. Mở Settings screen
2. Kiểm tra field API Base URL:
   - Nếu **rỗng** → sẽ dùng mock data (nên hoạt động)
   - Nếu **có URL** → sẽ gọi HTTP (cần backend chạy)

3. Click "Kiểm tra API"
4. Xem snackbar message

**Debug**:
```bash
# Xem network requests
# Nếu dùng Android emulator:
adb logcat | grep "http"

# Hoặc thêm log vào api_service.dart
print('📡 Fetching from: $baseUrl/parking-spots');
```

---

### 7️⃣ "SharedPreferences không lưu"

**Kiểm tra**:
```bash
# Sau khi chạy app và save settings

# Android (local):
adb shell
run-as com.example.flutter_application  # Thay tên package
cd /data/data/com.example.flutter_application/shared_prefs
cat shared_preferences.xml
```

**Debug code**:
```dart
// Thêm vào settings_provider.dart
Future<void> saveApiUrl(String url) async {
  print('💾 Saving URL: $url');
  await _prefs.setString('api_base_url', url);
  
  final saved = _prefs.getString('api_base_url');
  print('✅ Saved & verified: $saved');
  
  _apiService.baseUrl = url;
  notifyListeners();
}
```

---

### 8️⃣ "Map không hiển thị markers"

**Kiểm tra**:
1. Xem log có lỗi gì không
2. Kiểm tra `ParkingProvider.spots` có dữ liệu không

**Debug**:
```dart
// Thêm vào map_screen.dart
@override
void initState() {
  super.initState();
  
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final provider = Provider.of<ParkingProvider>(context, listen: false);
    print('🗺️ Spots count: ${provider.spots.length}');
    provider.spots.forEach((spot) {
      print('  - ${spot.name}: (${spot.lat}, ${spot.lng})');
    });
  });
}
```

---

### 9️⃣ "Reservation không lưu"

**Kiểm tra luồng**:
```
ReservationScreen → Click Confirm
  → ApiService.createPayment() [HTTP POST]
  → ApiService.reserve() [HTTP POST]
  → ParkingProvider.reserve() [update local state]
  → TransactionsProvider [add record]
  → Show success message
```

**Debug**:
```dart
// Thêm log vào reservation_screen.dart
try {
  print('💳 Creating payment...');
  await parkingProvider.api.createPayment(amount, 'cash');
  print('✅ Payment created');
  
  print('🔒 Making reservation...');
  await parkingProvider.reserve(spotId, vehicleId);
  print('✅ Reservation successful');
  
  // ...
} catch (e) {
  print('❌ Error: $e');
}
```

---

### 🔟 "Navigation error (GoRouter)"

**Lỗi**:
```
GoRouteMatch not found for location: /invalid
```

**Kiểm tra**:
1. Router path trong `router.dart` có đúng không?
2. Navigation code: `context.go('/correct-path')`

**Debug**:
```dart
// Thêm observer vào GoRouter
GoRouter(
  observers: [
    GoRouterObserver(), // Tạo class này
  ],
  routes: [ /* ... */ ],
)

class GoRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    print('🔗 Pushed: ${route.settings.name}');
  }
  
  @override
  void didPop(Route route, Route? previousRoute) {
    print('🔙 Popped: ${route.settings.name}');
  }
}
```

---

## 📊 Logs & Debugging Tips

### Chạy với verbose logs
```bash
flutter run -v
```

### Filter logs
```bash
flutter run 2>&1 | grep "flutter:"
```

### Attach debugger
```bash
flutter run --debug
# Sau đó sử dụng VS Code debugger
```

### Check app logs (Android)
```bash
adb logcat -s flutter
```

---

## 🔍 Checklist Debug

- [ ] Flutter doctor có issue?
- [ ] Device connect đúng không?
- [ ] Emulator/device có storage đủ?
- [ ] API URL đã cấu hình?
- [ ] Mock data có load?
- [ ] SharedPreferences lưu được?
- [ ] Network request có đi được?
- [ ] Widgets rebuild đúng?
- [ ] Hot reload code có apply?
- [ ] Log có thông báo gì?

---

## 💡 Pro Tips

1. **Print debugging**: Thêm `print()` ở các điểm quan trọng
2. **Breakpoints**: Dùng VS Code debugger (F5)
3. **DevTools**: `flutter pub global activate devtools` → `devtools`
4. **Network tab**: Xem request/response trong DevTools
5. **Widget tree**: Inspect widgets bằng DevTools

---

## 📞 Still Stuck?

1. Xem full log: `flutter run -v > debug.log 2>&1`
2. Check error message carefully (thường có solution)
3. Google error message
4. Stack Overflow / GitHub Issues
5. Hỏi community Flutter Vietnam

---

**Last Updated**: December 11, 2025
