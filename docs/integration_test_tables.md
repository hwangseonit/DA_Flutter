# 5.2. INTEGRATION TEST

## 5.2.1. Mô tả

Integration Test (Kiểm thử tích hợp) là quá trình kiểm tra sự tương tác và hoạt động phối hợp giữa nhiều components, modules, hoặc services trong ứng dụng. Khác với Unit Test kiểm tra từng function độc lập, Integration Test đảm bảo các thành phần hoạt động đúng đắn khi kết hợp với nhau.

**Mục đích:**

- Kiểm tra luồng dữ liệu giữa các components
- Đảm bảo các services tương tác chính xác
- Phát hiện lỗi xảy ra khi tích hợp nhiều modules
- Validate business logic phức tạp cần nhiều bước xử lý

**Phạm vi kiểm thử:**

- Authentication Flow: Đăng ký, đăng nhập với validation
- User Profile Management: Validate và chuyển đổi dữ liệu người dùng
- Workout Collection: Quản lý bài tập, tính toán thời gian và calo
- Exercise Tracking: Lưu trữ và đọc dữ liệu lịch sử tập luyện
- Business Logic: Tính toán BMR, TDEE, calories goal

---

## 5.2.2. Chi tiết test cases

### Bảng test case IT - Authentication Flow

| ID    | Tên Test Case                                  | Các bước thực hiện                                                                                                                                                                                                                                                                                                                   | Kết quả kỳ vọng                                                                                           |
| ----- | ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------- |
| IT001 | Đăng ký tài khoản - validate email và password | 1. Nhập email: `newuser@fitness.com`<br>2. Nhập password: `password123`<br>3. Nhập confirmPassword: `password123`<br>4. Gọi `GetUtils.isEmail(email)`<br>5. Kiểm tra `password.length >= 6`<br>6. Kiểm tra `password == confirmPassword`<br>7. Validate tổng hợp: `canRegister = isEmailValid && isPasswordValid && isPasswordMatch` | - Email hợp lệ: true<br>- Password đủ độ dài: true<br>- Password khớp: true<br>- Cho phép đăng ký: true   |
| IT002 | Đăng nhập - validate credentials               | 1. Nhập email: `user@fitness.com`<br>2. Nhập password: `secure123`<br>3. Gọi `GetUtils.isEmail(email)`<br>4. Kiểm tra `password.length >= 6`<br>5. Validate credentials                                                                                                                                                              | - Email hợp lệ: true<br>- Password đủ độ dài: true<br>- Credentials valid, cho phép đăng nhập             |
| IT003 | Đăng nhập thất bại - email sai format          | 1. Nhập email: `invalid-email` (không có @)<br>2. Nhập password: `password123`<br>3. Gọi `GetUtils.isEmail(email)`<br>4. Kiểm tra kết quả validation                                                                                                                                                                                 | - Email không hợp lệ: false<br>- Không cho phép đăng nhập<br>- Hiển thị lỗi "Email không đúng định dạng"  |
| IT004 | Đăng ký thất bại - password không khớp         | 1. Nhập password: `password123`<br>2. Nhập confirmPassword: `password456`<br>3. So sánh `password == confirmPassword`<br>4. Kiểm tra kết quả                                                                                                                                                                                         | - Password không khớp: false<br>- Không cho phép đăng ký<br>- Hiển thị lỗi "Mật khẩu xác nhận không khớp" |

---

### Bảng test case IT - User Profile Validation

| ID    | Tên Test Case                             | Các bước thực hiện                                                                                                                                                                                                                                                             | Kết quả kỳ vọng                                                                                                           |
| ----- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| IT005 | Validate thông tin cơ bản người dùng      | 1. Nhập height: 175cm<br>2. Nhập weight: 70kg<br>3. Nhập age: 25<br>4. Nhập name: `"Nguyễn Văn A"`<br>5. Kiểm tra `100 <= height <= 250`<br>6. Kiểm tra `30 <= weight <= 200`<br>7. Kiểm tra `16 <= age <= 40`<br>8. Kiểm tra `name.trim().isNotEmpty`<br>9. Validate tổng hợp | - Height valid: true<br>- Weight valid: true<br>- Age valid: true<br>- Name valid: true<br>- Profile hợp lệ, cho phép lưu |
| IT006 | Reject profile với chiều cao không hợp lệ | 1. Nhập height: 300cm (quá cao)<br>2. Kiểm tra `100 <= height <= 250`<br>3. Validate kết quả                                                                                                                                                                                   | - Height invalid: false<br>- Từ chối lưu profile<br>- Hiển thị lỗi "Chiều cao phải từ 100-250cm"                          |
| IT007 | Reject profile với cân nặng không hợp lệ  | 1. Nhập weight: 250kg (quá nặng)<br>2. Kiểm tra `30 <= weight <= 200`<br>3. Validate kết quả                                                                                                                                                                                   | - Weight invalid: false<br>- Từ chối lưu profile<br>- Hiển thị lỗi "Cân nặng phải từ 30-200kg"                            |
| IT008 | Chuyển đổi đơn vị chiều cao và cân nặng   | 1. User nhập height: 175cm, weight: 70kg<br>2. Chuyển đổi sang imperial:<br>&nbsp;&nbsp;&nbsp;- `Converter.convertCmToFt(175)`<br>&nbsp;&nbsp;&nbsp;- `Converter.convertKgToLbs(70)`<br>3. Kiểm tra kết quả chuyển đổi<br>4. Hiển thị cho user cả 2 hệ đơn vị                  | - 175cm → 5.74 ft (±0.01)<br>- 70kg → 154.32 lbs (±0.1)<br>- User có thể xem thông tin theo cả 2 hệ đo lường              |

---

### Bảng test case IT - Workout Collection Management

| ID    | Tên Test Case                            | Các bước thực hiện                                                                                                                                                                                                                                                                                                                         | Kết quả kỳ vọng                                                                                                                                                            |
| ----- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| IT009 | Tạo collection setting và tính thời gian | 1. Tạo CollectionSetting:<br>&nbsp;&nbsp;&nbsp;- round: 3<br>&nbsp;&nbsp;&nbsp;- numOfWorkoutPerRound: 5<br>&nbsp;&nbsp;&nbsp;- exerciseTime: 30s<br>&nbsp;&nbsp;&nbsp;- transitionTime: 10s<br>&nbsp;&nbsp;&nbsp;- restTime: 60s<br>2. Tính thời gian mỗi bài: 30 + 10 = 40s<br>3. Tính tổng thời gian: 40 × 5 × 3<br>4. Kiểm tra kết quả | - Thời gian mỗi bài: 40s<br>- Tổng thời gian: 600s (10 phút)<br>- Setting được lưu thành công                                                                              |
| IT010 | Clone collection setting                 | 1. Tạo setting gốc: round=4, exerciseTime=25, isShuffle=false<br>2. Gọi `CollectionSetting.fromCollectionSetting(original)`<br>3. Kiểm tra cloned setting<br>4. So sánh tất cả properties                                                                                                                                                  | - Cloned.round = 4 (giống original)<br>- Cloned.exerciseTime = 25 (giống original)<br>- Cloned.isShuffle = false (giống original)<br>- Tất cả properties khớp với original |
| IT011 | Tạo workout session và tính calo         | 1. User bắt đầu workout session<br>2. Thông số: bodyWeight=70kg, exerciseTime=30 phút, MET=5.0<br>3. Gọi `SessionUtils.calculateCaloOneWorkout(30, 5.0, 70)`<br>4. Áp dụng công thức MET: (time/60) × MET × weight × 3.5 / 200<br>5. Lưu kết quả vào tracker                                                                               | - Calo tính toán: 3.0625 (±0.01)<br>- Kết quả > 0<br>- Calories được lưu vào session history                                                                               |
| IT012 | Tính tổng calo cho workout collection    | 1. Setting: 5 bài × 3 vòng, exerciseTime=10s/bài<br>2. User: weight=75kg, avgMET=6.0<br>3. Tính tổng số bài tập: 5 × 3 = 15<br>4. Tính calo cho 1 bài (10s)<br>5. Tính tổng calo: calo/bài × 15<br>6. Lưu vào ExerciseTracker                                                                                                              | - Tổng số bài: 15<br>- Total calories > 0<br>- Tracker lưu đúng sessionNumber=15<br>- Tracker lưu đúng outtakeCalories                                                     |

---

### Bảng test case IT - Exercise Tracking & Persistence

| ID    | Tên Test Case                    | Các bước thực hiện                                                                                                                                                                                                                                                                                                | Kết quả kỳ vọng                                                                                                                                          |
| ----- | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| IT013 | Tạo và lưu exercise tracker      | 1. Tạo ExerciseTracker:<br>&nbsp;&nbsp;&nbsp;- id: 1<br>&nbsp;&nbsp;&nbsp;- date: 2025-12-23<br>&nbsp;&nbsp;&nbsp;- outtakeCalories: 250<br>&nbsp;&nbsp;&nbsp;- sessionNumber: 5<br>&nbsp;&nbsp;&nbsp;- totalTime: 45 phút<br>2. Gọi `tracker.toMap()`<br>3. Kiểm tra Map output<br>4. Mô phỏng lưu vào Firestore | - Map['id'] = 1<br>- Map['outtakeCalories'] = 250<br>- Map['sessionNumber'] = 5<br>- Map['totalTime'] = 45<br>- Data ready để lưu vào database           |
| IT014 | Đọc exercise tracker từ database | 1. Mô phỏng đọc Map từ Firestore:<br>&nbsp;&nbsp;&nbsp;{id: 2, date: "2025-12-22", outtakeCalories: 300, sessionNumber: 7, totalTime: 60}<br>2. Gọi `ExerciseTracker.fromMap(map)`<br>3. Kiểm tra object được tạo<br>4. Validate tất cả fields                                                                    | - tracker.id = 2<br>- tracker.outtakeCalories = 300<br>- tracker.sessionNumber = 7<br>- tracker.totalTime = 60<br>- Object được restore đúng từ database |
| IT015 | Cập nhật exercise tracker        | 1. Tạo tracker với outtakeCalories=100, sessionNumber=3, totalTime=20<br>2. User hoàn thành thêm bài tập<br>3. Cập nhật:<br>&nbsp;&nbsp;&nbsp;- outtakeCalories = 250<br>&nbsp;&nbsp;&nbsp;- sessionNumber = 6<br>&nbsp;&nbsp;&nbsp;- totalTime = 45<br>4. Kiểm tra properties sau update                         | - outtakeCalories đã thay đổi thành 250<br>- sessionNumber đã thay đổi thành 6<br>- totalTime đã thay đổi thành 45<br>- Update thành công                |
| IT016 | Track nhiều sessions trong ngày  | 1. Tạo array `sessions = []`<br>2. Loop 3 lần, mỗi lần tạo 1 ExerciseTracker:<br>&nbsp;&nbsp;&nbsp;- Session 1: 100 calo<br>&nbsp;&nbsp;&nbsp;- Session 2: 150 calo<br>&nbsp;&nbsp;&nbsp;- Session 3: 200 calo<br>3. Add vào array<br>4. Tính tổng calo: fold từ 0, cộng dồn<br>5. Kiểm tra kết quả               | - sessions.length = 3<br>- totalCalories = 450 (100 + 150 + 200)<br>- Có thể track multiple sessions cùng ngày                                           |

---

### Bảng test case IT - Business Logic Integration

| ID    | Tên Test Case                             | Các bước thực hiện                                                                                                                                                                                                                                                                                                                                                                                                                | Kết quả kỳ vọng                                                                                                                                                                      |
| ----- | ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| IT017 | Tính BMR cho nam giới                     | 1. Nhập thông tin user nam:<br>&nbsp;&nbsp;&nbsp;- weight: 70kg<br>&nbsp;&nbsp;&nbsp;- height: 175cm<br>&nbsp;&nbsp;&nbsp;- age: 25<br>2. Áp dụng công thức Mifflin-St Jeor cho nam:<br>&nbsp;&nbsp;&nbsp;`BMR = (10 × weight) + (6.25 × height) - (5 × age) + 5`<br>3. Tính toán: (10×70) + (6.25×175) - (5×25) + 5<br>4. Kiểm tra kết quả                                                                                       | - BMR = 1673.75 kcal/ngày<br>- Công thức tính đúng:<br>&nbsp;&nbsp;700 + 1093.75 - 125 + 5 = 1673.75<br>- Đây là năng lượng cơ bản cần thiết mỗi ngày                                |
| IT018 | Tính BMR cho nữ giới                      | 1. Nhập thông tin user nữ:<br>&nbsp;&nbsp;&nbsp;- weight: 60kg<br>&nbsp;&nbsp;&nbsp;- height: 165cm<br>&nbsp;&nbsp;&nbsp;- age: 25<br>2. Áp dụng công thức Mifflin-St Jeor cho nữ:<br>&nbsp;&nbsp;&nbsp;`BMR = (10 × weight) + (6.25 × height) - (5 × age) - 161`<br>3. Tính toán: (10×60) + (6.25×165) - (5×25) - 161<br>4. Kiểm tra kết quả                                                                                     | - BMR = 1345.25 kcal/ngày<br>- Công thức tính đúng:<br>&nbsp;&nbsp;600 + 1031.25 - 125 - 161 = 1345.25<br>- BMR nữ thấp hơn nam do khác biệt sinh lý                                 |
| IT019 | Tính TDEE và daily calories goal          | 1. Lấy BMR đã tính: 1673.75 (nam, 70kg, 175cm, 25 tuổi)<br>2. User chọn mức độ hoạt động: 1.5 (trung bình)<br>3. Tính TDEE: `BMR × activityFactor`<br>4. Tính calories goal theo mục tiêu:<br>&nbsp;&nbsp;&nbsp;- Giảm cân: TDEE - 500<br>&nbsp;&nbsp;&nbsp;- Tăng cân: TDEE + 500<br>5. Validate kết quả                                                                                                                         | - TDEE = 2510.625 kcal/ngày<br>- Calo để giảm cân: 2010.625<br>- Calo để tăng cân: 3010.625<br>- Chênh lệch 500 calo/ngày là an toàn                                                 |
| IT020 | Flow hoàn chỉnh - từ setting đến tracking | 1. Tạo workout setting: 3 vòng × 5 bài, 30s/bài<br>2. Tính số bài tập: 5 × 3 = 15<br>3. Tính thời gian: 30s × 15 = 450s<br>4. User tập với weight=70kg, avgMET=5.5<br>5. Tính calo: `calculateCaloOneWorkout(450, 5.5, 70)`<br>6. Tạo ExerciseTracker:<br>&nbsp;&nbsp;&nbsp;- outtakeCalories: từ bước 5<br>&nbsp;&nbsp;&nbsp;- sessionNumber: 15<br>&nbsp;&nbsp;&nbsp;- totalTime: 450/60 = 7.5 phút<br>7. Validate toàn bộ flow | - Setting.round = 3<br>- Tổng bài tập: 15<br>- Total calories > 0<br>- Tracker.sessionNumber = 15<br>- Tracker.outtakeCalories > 0<br>- Flow hoàn chỉnh: Setting → Calculate → Track |

---

## 5.2.3. Kết quả

### Tổng kết kết quả Integration Test

**Tổng số test cases: 20**  
**Kết quả: 20/20 PASSED (100%)**

### Thời gian thực thi

- Tổng thời gian chạy test: < 1 giây
- Lệnh thực thi: `flutter test test/integration/app_integration_test.dart`

### Báo cáo chi tiết theo nhóm chức năng

| Nhóm Test                       | Số lượng | Kết quả           |
| ------------------------------- | -------- | ----------------- |
| Authentication Flow             | 4        | ✅ 4/4 PASS       |
| User Profile Validation         | 4        | ✅ 4/4 PASS       |
| Workout Collection Management   | 4        | ✅ 4/4 PASS       |
| Exercise Tracking & Persistence | 4        | ✅ 4/4 PASS       |
| Business Logic Integration      | 4        | ✅ 4/4 PASS       |
| **TỔNG**                        | **20**   | **✅ 20/20 PASS** |

### Đánh giá

**Tỷ lệ thành công:** 100%

**Các luồng nghiệp vụ đã được kiểm tra:**

- ✅ Đăng ký/Đăng nhập với validation đầy đủ
- ✅ Quản lý thông tin người dùng với chuyển đổi đơn vị
- ✅ Tạo và quản lý workout collection
- ✅ Tính toán thời gian và calo chính xác
- ✅ Lưu trữ và đọc dữ liệu lịch sử tập luyện
- ✅ Tính toán BMR, TDEE theo công thức khoa học
- ✅ Flow tích hợp hoàn chỉnh từ setting đến tracking

**Kết luận:**  
Tất cả các integration test đều PASS, chứng tỏ các components trong ứng dụng hoạt động tốt khi tích hợp với nhau. Các luồng nghiệp vụ phức tạp như tính toán calo, quản lý workout, và tracking lịch sử đều hoạt động chính xác. Dữ liệu được serialize/deserialize đúng đắn, sẵn sàng tương tác với Firebase backend.

---

## 5.2.4. So sánh Unit Test vs Integration Test

| Tiêu chí           | Unit Test                          | Integration Test                             |
| ------------------ | ---------------------------------- | -------------------------------------------- |
| **Số lượng**       | 54 test cases                      | 20 test cases                                |
| **Phạm vi**        | Test từng function/class độc lập   | Test nhiều components phối hợp               |
| **Mục đích**       | Đảm bảo từng đơn vị hoạt động đúng | Đảm bảo tích hợp hoạt động đúng              |
| **Độ phức tạp**    | Đơn giản, tập trung 1 chức năng    | Phức tạp, nhiều bước logic                   |
| **Ví dụ**          | Test hàm `convertCmToFt()`         | Test flow: input → validate → convert → save |
| **Thời gian chạy** | Rất nhanh (< 1s)                   | Nhanh (< 1s)                                 |
| **Coverage**       | Chi tiết từng function             | Bao quát business flow                       |

**Kết hợp cả 2 loại test:**

- Unit Test đảm bảo nền tảng vững chắc (54/54 PASS)
- Integration Test đảm bảo hệ thống hoạt động trơn tru (20/20 PASS)
- **Tổng cộng: 74/74 tests PASS (100%)**
