# 📖 Index - Hướng dẫn đầu tiên

Chào mừng bạn đến với **Quản lý Garage & Bãi xe**! 🚗

Dưới đây là danh sách các file hướng dẫn. Hãy bắt đầu từ file phù hợp với nhu cầu của bạn:

---

## 🚀 **Tôi muốn chạy app ngay**

👉 Đọc: **[QUICK_START.md](./QUICK_START.md)** (5 phút)

Hoặc gõ:
```bash
# Windows
run.bat

# macOS/Linux
./run.sh
```

Test account: `user@test.com` / `123456`

---

## 📖 **Tôi muốn hiểu kiến trúc**

👉 Đọc: **[ARCHITECTURE.md](./ARCHITECTURE.md)** (20 phút)

Nội dung:
- Cấu trúc thư mục chi tiết
- Luồng dữ liệu
- Diagram hệ thống
- Dependency management
- API endpoints

---

## ❓ **Tôi gặp lỗi**

👉 Đọc: **[DEBUGGING.md](./DEBUGGING.md)** (15 phút)

Giải quyết:
- "No devices connected" ✅
- Gradle build failed ✅
- Dependency errors ✅
- Network issues ✅
- Debug tips & tricks ✅

---

## 📋 **Tôi muốn tổng quan**

👉 Đọc: **[README.md](./README.md)** (10 phút)

Bao gồm:
- Tính năng chính
- Yêu cầu hệ thống
- Cách cài đặt
- Cấu hình API
- Troubleshooting cơ bản

---

## 📊 **Tôi muốn xem trạng thái dự án**

👉 Đọc: **[PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md)** (5 phút)

Nội dung:
- Status: ✅ Ready to Run
- Checklists
- Metrics
- Limitations
- Next steps

---

## 🔧 **Tôi muốn cấu hình API**

👉 Tham khảo: **.env.example**

Hoặc dùng giao diện:
1. Chạy app
2. Đăng nhập
3. Settings → Nhập API Base URL → Lưu

---

## 📂 **Cấu trúc dự án**

```
📦 Project/
├─ 📄 README.md              ← Tổng quan
├─ 📄 QUICK_START.md         ← Chạy nhanh
├─ 📄 ARCHITECTURE.md        ← Chi tiết kỹ thuật
├─ 📄 DEBUGGING.md           ← Fix lỗi
├─ 📄 PROJECT_SUMMARY.md     ← Status & checklist
├─ 📄 INDEX.md               ← File này (bạn ở đây!)
├─ 📄 .env.example           ← Config template
├─ 📄 run.bat / run.sh       ← Auto-run
├─ 📄 pubspec.yaml           ← Dependencies
└─ 📂 lib/                   ← Source code
   ├─ main.dart              (entry point)
   ├─ router.dart            (routes)
   ├─ models/                (5 models)
   ├─ providers/             (4 state managers)
   ├─ services/              (API & settings)
   ├─ screens/               (11 UI screens)
   └─ widgets/               (reusable components)
```

---

## ⏱️ **Thời gian ước lượng**

| Task | Thời gian |
|------|----------|
| Cài Flutter | 10 phút |
| Clone/setup | 5 phút |
| Chạy app | 2 phút |
| Test toàn bộ | 15 phút |
| Hiểu kiến trúc | 30 phút |
| **Tổng cộng** | **~1 giờ** |

---

## 🎯 **Lộ trình đề xuất**

### Cho người mới (20 phút)
1. QUICK_START.md (5 phút)
2. Chạy app (2 phút)
3. Test tính năng (10 phút)
4. Xem README.md (3 phút)

### Cho developer (1 giờ)
1. README.md (10 phút)
2. QUICK_START.md (5 phút)
3. Chạy app (5 phút)
4. ARCHITECTURE.md (30 phút)
5. Test toàn bộ (10 phút)

### Cho debugger (30 phút)
1. DEBUGGING.md (15 phút)
2. Ứng dụng fix (15 phút)

---

## ❓ **FAQ**

### Q: Làm sao để chạy app?
**A**: Xem **QUICK_START.md** hoặc gõ `flutter run`

### Q: Tài khoản test là gì?
**A**: Email: `user@test.com`, Mật khẩu: `123456`

### Q: Làm sao để dùng API thực?
**A**: Settings → Nhập API Base URL → Lưu (xem ARCHITECTURE.md)

### Q: Gặp lỗi "No devices connected"?
**A**: Xem **DEBUGGING.md** phần 1️⃣

### Q: App có support offline không?
**A**: Mock data có, nhưng chưa có full offline support

### Q: Có test được trên web không?
**A**: Có! Gõ: `flutter run -d chrome`

---

## 📞 **Cần giúp?**

1. **Lỗi cơ bản** → QUICK_START.md
2. **Lỗi kỹ thuật** → DEBUGGING.md
3. **Hiểu code** → ARCHITECTURE.md
4. **Chung chung** → README.md
5. **Status dự án** → PROJECT_SUMMARY.md

---

## 🎉 **Bạn sẵn sàng rồi!**

### Chọn một bước tiếp theo:

- 🏃‍♂️ **[Chạy ngay (5 phút)](./QUICK_START.md)**
- 🏗️ **[Hiểu kiến trúc (30 phút)](./ARCHITECTURE.md)**
- 🐛 **[Fix lỗi (theo cần)](./DEBUGGING.md)**
- 📖 **[Đọc toàn bộ (60 phút)](./README.md)**

---

**Happy coding! 🚀**

*Last Updated: December 11, 2025*
