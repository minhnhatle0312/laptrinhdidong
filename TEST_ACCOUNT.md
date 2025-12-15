# 📝 Test Account & Sample Data Summary

## Default Test Account

Một tài khoản mặc định đã được tạo sẵn cho việc kiểm thử ứng dụng:

### Thông tin Đăng nhập

```
Email:     test@test.com
Password:  123456
Full Name: Demo User
```

### Cách Sử dụng

**Cách 1: Dùng nút Demo (Nhanh nhất)**
1. Trên màn hình Login, nhấn nút **"Đăng nhập Demo"**
2. Sẽ tự động đăng nhập vào tài khoản demo

**Cách 2: Đăng nhập Thủ công**
1. Nhập email: `test@test.com`
2. Nhập mật khẩu: `123456`
3. Nhấn "Đăng nhập"

### Lần Đầu Tiên?

- Nếu tài khoản chưa tồn tại trong Firebase, nó sẽ được tự động tạo
- Dữ liệu người dùng sẽ lưu trong Firestore (users collection)
- Bạn sẽ được đăng nhập ngay lập tức

---

## Sample Data (Dữ Liệu Mẫu)

### Bãi Xe (Parking Spots)

Hệ thống tự động tạo 5 bãi xe mẫu:

#### Tầng A (Standard)
```json
{
  "id": "spot_001",
  "name": "Spot A1",
  "lat": 10.776530,
  "lng": 106.700981,
  "floor": "A",
  "type": "standard",
  "pricePerHour": 50000,
  "isAvailable": true
}
```

```json
{
  "id": "spot_002",
  "name": "Spot A2",
  "lat": 10.776545,
  "lng": 106.700995,
  "floor": "A",
  "type": "standard",
  "pricePerHour": 50000,
  "isAvailable": true
}
```

```json
{
  "id": "spot_003",
  "name": "Spot A3",
  "lat": 10.776560,
  "lng": 106.701010,
  "floor": "A",
  "type": "standard",
  "pricePerHour": 50000,
  "isAvailable": false
}
```

#### Tầng B (VIP)
```json
{
  "id": "spot_004",
  "name": "Spot B1",
  "lat": 10.776700,
  "lng": 106.701100,
  "floor": "B",
  "type": "vip",
  "pricePerHour": 60000,
  "isAvailable": true
}
```

```json
{
  "id": "spot_005",
  "name": "Spot B2",
  "lat": 10.776720,
  "lng": 106.701120,
  "floor": "B",
  "type": "vip",
  "pricePerHour": 60000,
  "isAvailable": true
}
```

### Bảng Tóm Tắt

| Spot ID | Tên | Tầng | Loại | Giá | Trạng thái |
|---------|-----|------|------|-----|-----------|
| spot_001 | A1 | A | Standard | 50K/h | ✅ Trống |
| spot_002 | A2 | A | Standard | 50K/h | ✅ Trống |
| spot_003 | A3 | A | Standard | 50K/h | ❌ Đã đặt |
| spot_004 | B1 | B | VIP | 60K/h | ✅ Trống |
| spot_005 | B2 | B | VIP | 60K/h | ✅ Trống |

---

## Firebase Setup

### Project Configuration

- **Project ID:** quanlyxe-f18f4
- **Authentication:** Email/Password + Demo
- **Database:** Firestore (Cloud)
- **Storage:** Firebase Hosting (Web)

### Collections in Firestore

#### `users/` - Hồ sơ Người dùng
```json
{
  "uid": "string",
  "email": "string",
  "fullName": "string",
  "role": "user",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### `parking_spots/` - Bãi Xe
```json
{
  "id": "string",
  "name": "string",
  "lat": "number",
  "lng": "number",
  "floor": "string",
  "type": "string",
  "pricePerHour": "number",
  "isAvailable": "boolean",
  "reservedBy": "string (UID)",
  "createdAt": "timestamp"
}
```

#### `reservations/` - Đơn Đặt
```json
{
  "id": "string",
  "spotId": "string",
  "userId": "string",
  "startTime": "timestamp",
  "endTime": "timestamp",
  "status": "pending|confirmed|completed|cancelled",
  "totalPrice": "number",
  "createdAt": "timestamp"
}
```

#### `transactions/` - Giao Dịch Thanh Toán
```json
{
  "id": "string",
  "userId": "string",
  "reservationId": "string",
  "amount": "number",
  "method": "card|cash|online",
  "status": "pending|success|failed",
  "createdAt": "timestamp"
}
```

---

## Khởi Động Ứng Dụng

### Lần Đầu Tiên

```bash
# 1. Clone/Download project
cd "C:\Users\ADMIN\Downloads\Qu-n-l-garage-xe-Application-main (1)\Qu-n-l-garage-xe-Application-main"

# 2. Cài dependencies
flutter pub get

# 3. Chạy trên Web
flutter run -d chrome
```

### Dữ Liệu Sẽ Tự Động Tạo

- ✅ Tài khoản Demo User (test@test.com)
- ✅ 5 Bãi xe mẫu trong Firestore
- ✅ User profile trong users collection

### Lần Tiếp Theo

```bash
flutter run -d chrome
```

Dữ liệu mẫu sẽ được giữ lại (không tạo lại nếu đã tồn tại).

---

## Testing Checklist

Sau khi đăng nhập, kiểm thử:

- [ ] **Login/Logout** - Đăng nhập và đăng xuất bình thường
- [ ] **View Map** - Xem 5 bãi xe trên bản đồ Google Maps
- [ ] **View Parking List** - Danh sách bãi xe với phân loại
- [ ] **Make Reservation** - Đặt một bãi xe trống
- [ ] **View Reservation** - Xem đơn đặt của mình
- [ ] **Payment Simulation** - Mô phỏng thanh toán
- [ ] **Add Vehicle** - Thêm phương tiện mới
- [ ] **Edit Profile** - Sửa thông tin hồ sơ
- [ ] **Transaction History** - Xem lịch sử giao dịch

---

## Troubleshooting

### ❌ Lỗi: "Failed to get document because the client is offline"

**Nguyên nhân:** Firebase đang khởi động  
**Giải pháp:** 
- Chờ 10 giây cho Firebase kết nối
- Kiểm tra kết nối Internet
- Thử nhấn nút Demo Login lại

### ❌ Không thấy bãi xe trên Map

**Nguyên nhân:** Dữ liệu chưa load từ Firestore  
**Giải pháp:**
- Đợi vài giây
- Quay lại Screen khác rồi quay trở lại Map
- Kiểm tra console cho lỗi Firestore

### ❌ Demo Login không hoạt động

**Nguyên nhân:** Firebase chưa sẵn sàng hoặc lỗi mạng  
**Giải pháp:**
- Chờ Firebase khởi động
- Kiểm tra mạng Internet
- Thử Reload App (R key)

---

## Ghi Chú Bảo Mật

⚠️ **DEVELOPMENT ONLY**

- Tài khoản demo được hardcode để tiện test
- **KHÔNG DÙNG** cho production
- Xóa nút "Đăng nhập Demo" trước khi deploy
- Thiết lập Firebase Security Rules
- Bảo vệ các sensitive data

---

**Cần thêm tài khoản?** 
Đi đến Firebase Console → Authentication → Add User

**Thêm dữ liệu mẫu?**
Dùng `lib/utils/firebase_init_sample_data.dart` để tự động hoá

