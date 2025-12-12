# 🚀 QUICK START - Chạy ứng dụng ngay

## 1️⃣ Chuẩn bị

Đảm bảo bạn có:
- **Flutter SDK** >= 3.10.0
- **Android Studio** hoặc **Xcode** (tùy thiết bị)
- **Emulator/Device** kết nối sẵn

## 2️⃣ Cài dependencies

```bash
flutter pub get
```

## 3️⃣ Chạy ứng dụng

```bash
flutter run
```

> Nếu có nhiều device, chọn device:
> ```bash
> flutter run -d <device_id>
> ```
> Xem danh sách: `flutter devices`

## 4️⃣ Đăng nhập

Dùng tài khoản test:
- **Email**: `user@test.com`
- **Mật khẩu**: `123456`

## 5️⃣ Khám phá ứng dụng

1. ✅ **Dashboard** - Xem tóm tắt bãi xe
2. ✅ **Danh sách bãi xe** - Click "Đặt" để đặt chỗ
3. ✅ **Bản đồ** - Xem vị trí bãi xe trên bản đồ
4. ✅ **Quản lý phương tiện** - Thêm xe mới
5. ✅ **Cài đặt** - Lưu API URL (nếu có backend)

---

## ❓ Nếu gặp lỗi

### ❌ "No devices connected"
```bash
flutter devices              # Xem danh sách
flutter run -d chrome        # Hoặc chạy trên web
```

### ❌ "Dependency error"
```bash
flutter clean
flutter pub get
flutter run
```

### ❌ "Android build error"
```bash
cd android
./gradlew clean
cd ..
flutter run
```

---

## 🎯 Các chức năng chính

| Chức năng | Hướng dẫn |
|----------|----------|
| **Đặt bãi xe** | Dashboard → Bãi xe → Chọn xe → Xác nhận |
| **Xem bản đồ** | Menu → Bản đồ → Click marker |
| **Quản lý xe** | Menu → Phương tiện → Thêm xe |
| **Lịch sử giao dịch** | Menu → Lịch sử |
| **Cài đặt API** | Menu → Cài đặt → Nhập URL → Lưu |

---

## 💡 Tips

- **Mock data**: Nếu API URL rỗng, ứng dụng dùng dữ liệu giả
- **SharedPreferences**: Lưu baseUrl vĩnh viễn
- **Hot reload**: `r` (để hot reload code)
- **Hot restart**: `R` (để restart app)

---

Chúc bạn sử dụng vui vẻ! 🎉
