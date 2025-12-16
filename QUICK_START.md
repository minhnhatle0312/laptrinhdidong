# 🚀 QUICK START - Chạy ứng dụng ngay

## 1️⃣ Chuẩn bị

Đảm bảo bạn có:
- **Flutter SDK** >= 3.10.0
- **Android Studio** hoặc **Xcode** (tùy thiết bị)
- **Emulator/Device** kết nối sẵn
- **Internet kết nối** để Firebase hoạt động

## 2️⃣ Cài dependencies

```bash
flutter pub get
```

## 3️⃣ Chạy ứng dụng

```bash
flutter run -d chrome
```

> Nếu có nhiều device, chọn device:
> ```bash
> flutter run -d <device_id>
> ```
> Xem danh sách: `flutter devices`

## 4️⃣ Đăng nhập

**Sử dụng tài khoản Demo (khuyên dùng):**
- Trên màn hình login, nhấn nút **"Đăng nhập Demo"**
- Sẽ tự động đăng nhập với tài khoản: `test@test.com` / `123456`

**Hoặc đăng nhập thủ công:**
- **Email**: `test@test.com`
- **Mật khẩu**: `123456`

## 5️⃣ Khám phá ứng dụng

Sau khi đăng nhập, bạn có thể:

1. ✅ **Bản đồ** - Xem vị trí 5 bãi xe mẫu trên Google Map
2. ✅ **Danh sách bãi xe** - Duyệt các chỗ đậu (trống/đã đặt)
3. ✅ **Đặt chỗ** - Nhấn vào chỗ đậu để đặt giữ
4. ✅ **Thanh toán** - Mô phỏng thanh toán cho đơn đặt
5. ✅ **Quản lý phương tiện** - Thêm/sửa/xóa xe của bạn
6. ✅ **Lịch sử giao dịch** - Xem các đơn đặt trước đó
7. ✅ **Cài đặt** - Tuỳ chỉnh ứng dụng

## 📊 Dữ liệu Mẫu

### Bãi xe (tự động tạo)

| Spot ID | Tên | Vị trí | Tầng | Loại | Giá | Trạng thái |
|---------|-----|--------|------|------|-----|-----------|
| spot_001 | Spot A1 | 10.776530, 106.700981 | A | Tiêu chuẩn | 50,000 VND/h | Trống |
| spot_002 | Spot A2 | 10.776545, 106.700995 | A | Tiêu chuẩn | 50,000 VND/h | Trống |
| spot_003 | Spot A3 | 10.776560, 106.701010 | A | Tiêu chuẩn | 50,000 VND/h | Đã đặt |
| spot_004 | Spot B1 | 10.776700, 106.701100 | B | VIP | 60,000 VND/h | Trống |
| spot_005 | Spot B2 | 10.776720, 106.701120 | B | VIP | 60,000 VND/h | Trống |

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
