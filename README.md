# VIPT - Ứng dụng Fitness & Nutrition

Ứng dụng quản lý tập luyện và dinh dưỡng được xây dựng bằng Flutter với Firebase.

## 👥 Thành viên nhóm

| Họ và Tên           | Mã sinh viên | Tài khoản   |
| ------------------- | ------------ | ----------- |
| Trần Văn Sơn        | 25A4041913   | HwangseonIT |
| Phàn Văn Dài        | 25A4041529   | Vandai-25   |
| Lê Minh Hải         | 25A4041539   | Lehai-svg   |
| Nguyễn Sỹ Quang Huy | 25A4041547   | Quanghuy299 |

## 🛠️ Công nghệ sử dụng

- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Firestore, Cloud Storage)
- **State Management**: GetX
- **UI/UX**: Google Fonts, Flutter SVG, Carousel Slider
- **Charts**: FL Chart
- **Navigation**: Persistent Bottom Nav Bar

## ✨ Chức năng chính

- 🔐 **Xác thực người dùng**: Đăng ký, đăng nhập với Firebase Auth
- 💪 **Quản lý tập luyện**: Xem và theo dõi các bài tập, kế hoạch workout
- 🍎 **Dinh dưỡng**: Theo dõi chế độ ăn uống và dinh dưỡng
- 📅 **Kế hoạch hàng ngày**: Lên lịch tập luyện và dinh dưỡng
- 💬 **Chatbot**: Hỗ trợ tư vấn tự động
- 📚 **Thư viện**: Bài tập và công thức dinh dưỡng
- 📊 **Thống kê**: Biểu đồ theo dõi tiến trình
- 👤 **Hồ sơ cá nhân**: Quản lý thông tin người dùng
- 👨‍💼 **Quản trị viên**: Module admin quản lý hệ thống

## 🚀 Cách chạy dự án

### Cài đặt từ APK

- Tải file APK và cài đặt trực tiếp trên thiết bị Android

### Chạy từ mã nguồn

**Yêu cầu**: Flutter SDK (>=2.14.0 <3.0.0)

**Các bước:**

1. **Làm sạch dự án**

   ```bash
   flutter clean
   ```

2. **Cài đặt dependencies**

   ```bash
   flutter pub get
   ```

3. **Cấu hình API Cloudinary**

   Tạo file `.env` trong thư mục gốc với nội dung:

   ```
   CLOUDINARY_CLOUD_NAME=dejlpxxrz
   CLOUDINARY_API_KEY=588845788459418
   CLOUDINARY_API_SECRET=nyrYwb-rf5ucfj_0NAzVx0Zwjw0
   CLOUDINARY_UPLOAD_PRESET=flutter_uploads
   ```

4. **Cấu hình API Gemini**

   Thêm vào file `.env`:

   ```
   GEMINI_API_KEY=AIzaSyAl3HdEbFswuSO5kpdvR_VW3OW-vSfXAVs
   ```

5. **Chạy ứng dụng**

   ```bash
   flutter run                        # App người dùng
   flutter run -t lib/main_admin.dart # App admin

   # Web
   flutter build web
   ```

## 📁 Cấu trúc thư mục

```
lib/
├── app/
│   ├── core/          # Theme, utilities, controllers
│   ├── data/          # Models, providers, services
│   ├── global_widgets/# Widgets dùng chung
│   ├── modules/       # Các module chức năng
│   └── routes/        # Định tuyến
├── main.dart          # Entry point app user
└── main_admin.dart    # Entry point app admin
```

## 🧪 Testing

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/
```

---

_Dự án được phát triển bởi nhóm sinh viên Flutter_
