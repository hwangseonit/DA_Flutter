# VIPT - Ứng dụng Fitness & Nutrition

Ứng dụng quản lý tập luyện và dinh dưỡng được xây dựng bằng Flutter với Firebase.

## 👥 Thành viên nhóm

| Họ và Tên           | Mã sinh viên | Tài khoản |
| ------------------- | ------------ | --------- |
| Trần Văn Sơn        |              |           |
| Phàn Văn Dài        |              |           |
| Lê Minh Hải         |              |           |
| Nguyễn Sỹ Quang Huy |              |           |

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

### Yêu cầu

- Flutter SDK (>=2.14.0 <3.0.0)
- Android Studio / Xcode (cho iOS)
- Tài khoản Firebase

### Các bước chạy

1. **Clone project**

   ```bash
   git clone <repository-url>
   cd DA_Flutter
   ```

2. **Cài đặt dependencies**

   ```bash
   flutter pub get
   ```

3. **Cấu hình Firebase**

   - Thêm file `google-services.json` vào `android/app/`
   - Cấu hình Firebase cho iOS (nếu cần)

4. **Chạy ứng dụng**

   ```bash
   # Chạy app người dùng
   flutter run

   # Chạy app admin
   flutter run -t lib/main_admin.dart
   ```

5. **Build ứng dụng**

   ```bash
   # Android
   flutter build apk

   # iOS
   flutter build ios

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
