# CHƯƠNG 5.1: UNIT TEST - BÁO CÁO KIỂM THỬ

## 1. Giới thiệu

Unit Test là phương pháp kiểm thử mức độ nhỏ nhất, kiểm tra từng đơn vị (hàm, phương thức, class) độc lập để đảm bảo logic hoạt động đúng.

**✅ Kết quả tổng thể: 54/54 tests PASSED (100%)**

## 2. Công cụ sử dụng

- **Framework**: Flutter Test (built-in SDK)
- **Assertions**: `expect()`, `equals()`, `closeTo()`, `isTrue`, `isFalse`
- **Test runner**: `flutter test`
- **Môi trường**: Flutter SDK >=2.14.0 <3.0.0

## 3. Cấu trúc thư mục

```
test/
  unit/
    utils_test.dart          - 15 tests (Converter, SessionUtils, WorkoutCollectionUtils, WorkoutPlanUtils)
    validation_test.dart     - 28 tests (Email, Password, User Info, Date, String, Number validation)
    models_test.dart         - 11 tests (ExerciseTracker, CollectionSetting models)
```

## 4. Chi tiết các Test Cases

### 4.1. Utils Test (utils_test.dart) - 15 tests ✅

#### Converter - Chuyển đổi đơn vị (5 tests)

| STT | Tên Test                  | Mô tả                     | Kết quả |
| --- | ------------------------- | ------------------------- | ------- |
| 1   | Chuyển đổi Cm sang Ft     | Convert 170cm → 5.577ft   | ✅ PASS |
| 2   | Chuyển đổi Ft sang Cm     | Convert 5.577ft → 170cm   | ✅ PASS |
| 3   | Chuyển đổi Kg sang Lbs    | Convert 70kg → 154.32lbs  | ✅ PASS |
| 4   | Chuyển đổi Lbs sang Kg    | Convert 154.32lbs → 70kg  | ✅ PASS |
| 5   | Giá trị âm khi chuyển đổi | Giá trị âm không thay đổi | ✅ PASS |

**Code snippet:**

```dart
test('Chuyển đổi Cm sang Ft', () {
  double result = Converter.convertCmToFt(170);
  expect(result, closeTo(5.577, 0.001));
});
```

#### SessionUtils - Tính Calo (4 tests)

| STT | Tên Test                           | Mô tả                               | Kết quả |
| --- | ---------------------------------- | ----------------------------------- | ------- |
| 6   | Tính calo cho 1 bài tập cơ bản     | 30 phút, MET=5, 70kg → 3.0625 calo  | ✅ PASS |
| 7   | Tính calo cho bài tập cường độ cao | 45 phút, MET=8, 80kg → 8.4 calo     | ✅ PASS |
| 8   | Tính calo khi thời gian = 0        | Thời gian = 0 → 0 calo              | ✅ PASS |
| 9   | Tính calo với cân nặng khác nhau   | Cân nặng khác nhau → calo khác nhau | ✅ PASS |

**Công thức tính calo:**

```
Calo = (time/60) * metValue * bodyWeight * 3.5 / 200
```

#### WorkoutCollectionUtils - Tính thời gian (3 tests)

| STT | Tên Test                                | Mô tả                     | Kết quả |
| --- | --------------------------------------- | ------------------------- | ------- |
| 10  | Tính thời gian cho 1 workout collection | 30s, 5 bài, 3 vòng → 450s | ✅ PASS |
| 11  | Tính thời gian khi số bài = 0           | Không có bài tập → 0s     | ✅ PASS |
| 12  | So sánh thời gian với số vòng khác nhau | 2 vòng < 3 vòng           | ✅ PASS |

#### WorkoutPlanUtils - Tính BMR/TDEE (3 tests)

| STT | Tên Test                            | Mô tả                                      | Kết quả |
| --- | ----------------------------------- | ------------------------------------------ | ------- |
| 13  | Tính Daily Goal Calories cho nam    | Nam, 70kg, 175cm, 25 tuổi → 1600 calo/ngày | ✅ PASS |
| 14  | Tính Daily Goal Calories cho nữ     | Nữ, 60kg, 165cm, 25 tuổi → 2000 calo/ngày  | ✅ PASS |
| 15  | Mức độ hoạt động ảnh hưởng đến TDEE | Activity 1.3 < Activity 1.7                | ✅ PASS |

**Công thức BMR (Basal Metabolic Rate):**

- Nam: BMR = 10 × weight + 6.25 × height - 5 × age + 5
- Nữ: BMR = 10 × weight + 6.25 × height - 5 × age - 161

**TDEE = BMR × Activity Level**

### 4.2. Validation Test (validation_test.dart) - 28 tests ✅

#### Email Validation (3 tests)

| STT | Tên Test                | Mô tả                             | Kết quả |
| --- | ----------------------- | --------------------------------- | ------- |
| 16  | Email hợp lệ            | `user@example.com` → valid        | ✅ PASS |
| 17  | Email không hợp lệ      | `@example.com`, `user@` → invalid | ✅ PASS |
| 18  | Email có ký tự đặc biệt | Space, @@ → invalid               | ✅ PASS |

#### Password Validation (4 tests)

| STT | Tên Test            | Mô tả                         | Kết quả |
| --- | ------------------- | ----------------------------- | ------- |
| 19  | Mật khẩu đủ độ dài  | >= 6 ký tự → valid            | ✅ PASS |
| 20  | Mật khẩu quá ngắn   | < 6 ký tự → invalid           | ✅ PASS |
| 21  | Mật khẩu khớp nhau  | password == confirm → valid   | ✅ PASS |
| 22  | Mật khẩu không khớp | password != confirm → invalid | ✅ PASS |

#### User Info Validation (7 tests)

| STT | Tên Test               | Mô tả                      | Kết quả |
| --- | ---------------------- | -------------------------- | ------- |
| 23  | Chiều cao hợp lệ       | 100-250 cm → valid         | ✅ PASS |
| 24  | Chiều cao không hợp lệ | < 100 hoặc > 250 → invalid | ✅ PASS |
| 25  | Cân nặng hợp lệ        | 30-200 kg → valid          | ✅ PASS |
| 26  | Cân nặng không hợp lệ  | < 30 hoặc > 200 → invalid  | ✅ PASS |
| 27  | Tuổi hợp lệ            | 16-40 tuổi → valid         | ✅ PASS |
| 28  | Tuổi không hợp lệ      | < 16 hoặc > 40 → invalid   | ✅ PASS |
| 29  | Tên không được rỗng    | Trim và check empty        | ✅ PASS |

#### Date Validation (4 tests)

| STT | Tên Test               | Mô tả                      | Kết quả |
| --- | ---------------------- | -------------------------- | ------- |
| 30  | Ngày sinh hợp lệ       | Trong quá khứ → valid      | ✅ PASS |
| 31  | Ngày sinh không hợp lệ | Trong tương lai → invalid  | ✅ PASS |
| 32  | Tính tuổi từ ngày sinh | Birthday → Age calculation | ✅ PASS |
| 33  | Kiểm tra tuổi hợp lệ   | Age trong 16-40 → valid    | ✅ PASS |

#### Logic & Comparison (2 tests)

| STT | Tên Test         | Mô tả                  | Kết quả |
| --- | ---------------- | ---------------------- | ------- |
| 34  | So sánh cân nặng | Current vs Goal weight | ✅ PASS |
| 35  | Kiểm tra tiến độ | Progress percentage    | ✅ PASS |

#### String Manipulation (3 tests)

| STT | Tên Test                  | Mô tả                        | Kết quả |
| --- | ------------------------- | ---------------------------- | ------- |
| 36  | Trim khoảng trắng         | `"  text  "` → `"text"`      | ✅ PASS |
| 37  | Kiểm tra chuỗi rỗng       | `isEmpty`, `isNotEmpty`      | ✅ PASS |
| 38  | Chuyển đổi chữ hoa/thường | `toUpperCase`, `toLowerCase` | ✅ PASS |

#### Number Validation (5 tests)

| STT | Tên Test                        | Mô tả                      | Kết quả |
| --- | ------------------------------- | -------------------------- | ------- |
| 39  | Parse số nguyên hợp lệ          | `"123"` → `123`            | ✅ PASS |
| 40  | Parse số nguyên không hợp lệ    | `"abc"` → `null`           | ✅ PASS |
| 41  | Parse số thập phân hợp lệ       | `"12.5"` → `12.5`          | ✅ PASS |
| 42  | Parse số thập phân không hợp lệ | `"12.5.3"` → `null`        | ✅ PASS |
| 43  | Số dương, âm, zero              | `isPositive`, `isNegative` | ✅ PASS |

### 4.3. Models Test (models_test.dart) - 11 tests ✅

#### ExerciseTracker Model (5 tests)

| STT | Tên Test                             | Mô tả                          | Kết quả |
| --- | ------------------------------------ | ------------------------------ | ------- |
| 44  | Tạo ExerciseTracker từ constructor   | Khởi tạo với đầy đủ tham số    | ✅ PASS |
| 45  | Chuyển ExerciseTracker thành Map     | `toMap()` method               | ✅ PASS |
| 46  | Tạo ExerciseTracker từ Map           | `fromMap()` factory            | ✅ PASS |
| 47  | ExerciseTracker với giá trị mặc định | Default values khi thiếu field | ✅ PASS |
| 48  | Cập nhật ExerciseTracker             | Modify properties              | ✅ PASS |

**Code snippet:**

```dart
test('Chuyển ExerciseTracker thành Map (toMap)', () {
  final tracker = ExerciseTracker(
    id: 2,
    date: DateTime(2024, 1, 16),
    outtakeCalories: 300,
    sessionNumber: 6,
    totalTime: 50,
  );

  final map = tracker.toMap();
  expect(map['outtakeCalories'], equals(300));
});
```

#### CollectionSetting Model (6 tests)

| STT | Tên Test                       | Mô tả                     | Kết quả |
| --- | ------------------------------ | ------------------------- | ------- |
| 49  | Tạo CollectionSetting mặc định | Default values            | ✅ PASS |
| 50  | Tạo CollectionSetting custom   | Custom parameters         | ✅ PASS |
| 51  | Tính tổng thời gian tập        | Calculate total time      | ✅ PASS |
| 52  | Kiểm tra chế độ Shuffle        | Shuffle on/off            | ✅ PASS |
| 53  | Kiểm tra Warm Up               | WarmUp on/off             | ✅ PASS |
| 54  | Clone CollectionSetting        | `fromCollectionSetting()` | ✅ PASS |

**Default CollectionSetting values:**

- round: 3
- numOfWorkoutPerRound: 5
- exerciseTime: 10s
- transitionTime: 10s
- restTime: 10s
- isStartWithWarmUp: true
- isShuffle: true

## 5. Hướng dẫn chạy tests

### 5.1. Chạy tất cả Unit Tests

```bash
flutter test test/unit
```

**Kết quả mong đợi:**

```
00:01 +54: All tests passed!
```

### 5.2. Chạy từng file test riêng lẻ

```bash
# Test utilities
flutter test test/unit/utils_test.dart

# Test validations
flutter test test/unit/validation_test.dart

# Test models
flutter test test/unit/models_test.dart
```

### 5.3. Chạy test với báo cáo chi tiết

```bash
flutter test test/unit --reporter=expanded
```

## 6. Tổng kết kết quả

| File Test            | Số lượng tests | Passed | Failed |
| -------------------- | -------------- | ------ | ------ |
| utils_test.dart      | 15             | 15     | 0      |
| validation_test.dart | 28             | 28     | 0      |
| models_test.dart     | 11             | 11     | 0      |
| **TỔNG**             | **54**         | **54** | **0**  |

**Tỷ lệ thành công: 100%**

## 7. Screenshot kết quả

```
00:00 +54: All tests passed!
```

## 8. Kết luận

✅ **Hoàn thành 100% Unit Tests**

**Các điểm quan trọng đã kiểm tra:**

1. **Converter utils**: Chuyển đổi đơn vị đo lường (cm/ft, kg/lbs) - 5 tests
2. **Calculation utils**: Tính toán calo, BMR, TDEE, thời gian tập - 7 tests
3. **Validation logic**: Email, password, thông tin cá nhân - 28 tests
4. **Data models**: Serialization/Deserialization (toMap/fromMap) - 11 tests
5. **Edge cases**: Giá trị null, 0, âm, chuỗi rỗng - 3 tests

**Phạm vi coverage:**

- ✅ Utilities (Converter, SessionUtils, WorkoutCollectionUtils, WorkoutPlanUtils)
- ✅ Validations (Email, Password, User info, Date, String, Number)
- ✅ Models (ExerciseTracker, CollectionSetting)

**Đánh giá:**

- Code hoạt động ổn định và đúng logic nghiệp vụ
- Xử lý tốt các edge cases (null, empty, negative values)
- Formula calculations chính xác (BMR, TDEE, Calories)
- Data models serialize/deserialize đúng

Tất cả 54 test cases đều **PASSED**, đảm bảo chất lượng code và sẵn sàng cho giai đoạn integration test tiếp theo.
