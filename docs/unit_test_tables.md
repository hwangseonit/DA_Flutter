# 5.1. UNIT TEST

## 5.1.1. Các lớp/function được test

Unit test được thực hiện để kiểm tra tính đúng đắn của các chức năng cốt lõi trong ứng dụng. Tổng cộng có **54 test cases** được viết cho **3 nhóm chức năng chính**: Utils Classes, Validation, và Models. Các test được thiết kế để kiểm tra cả trường hợp bình thường và các trường hợp biên (edge cases) như giá trị âm, giá trị 0, dữ liệu không hợp lệ.

### 1. Utils Classes (Lớp tiện ích) - 15 test cases

Nhóm này chứa các class tiện ích xử lý các tính toán quan trọng trong ứng dụng fitness.

#### 1.1. Converter (5 test cases)

**Mục đích:** Chuyển đổi giữa các đơn vị đo lường khác nhau (hệ metric và imperial) phục vụ cho việc nhập liệu và hiển thị thông tin người dùng.

**Các function được test:**

- `convertCmToFt(double cm)` - Chuyển đổi chiều cao từ centimeters sang feet

  - **Công thức:** 1 cm = 0.0328084 ft
  - **Mục đích:** Cho phép người dùng ở các quốc gia sử dụng hệ imperial xem chiều cao theo đơn vị quen thuộc
  - **Test case:** Kiểm tra với giá trị 170cm → kết quả mong đợi 5.577ft (±0.001)

- `convertFtToCm(double ft)` - Chuyển đổi chiều cao từ feet sang centimeters

  - **Công thức:** 1 ft = 30.48 cm
  - **Mục đích:** Chuyển đổi ngược lại khi người dùng nhập dữ liệu theo feet
  - **Test case:** Kiểm tra với 5.577ft → kết quả mong đợi 170cm (±0.01)

- `convertKgToLbs(double kg)` - Chuyển đổi cân nặng từ kilograms sang pounds

  - **Công thức:** 1 kg = 2.20462 lbs
  - **Mục đích:** Hiển thị cân nặng theo đơn vị pounds cho người dùng hệ imperial
  - **Test case:** Kiểm tra với 70kg → kết quả mong đợi 154.32lbs (±0.01)

- `convertLbsToKg(double lbs)` - Chuyển đổi cân nặng từ pounds sang kilograms

  - **Công thức:** 1 lbs = 0.453592 kg
  - **Mục đích:** Chuyển đổi ngược lại khi người dùng nhập cân nặng theo pounds
  - **Test case:** Kiểm tra với 154.32lbs → kết quả mong đợi 70kg (±0.01)

- **Edge case:** Kiểm tra xử lý giá trị âm để đảm bảo không có lỗi runtime

#### 1.2. SessionUtils (4 test cases)

**Mục đích:** Tính toán lượng calo tiêu thụ trong quá trình tập luyện dựa trên phương pháp MET (Metabolic Equivalent of Task).

**Các function được test:**

- `calculateCaloOneWorkout(double time, double met, double bodyWeight)` - Tính calo tiêu thụ cho một bài tập
  - **Công thức MET:** Calories = (Time/60) × MET × BodyWeight × 3.5 / 200
  - **Tham số:**
    - `time`: Thời gian tập (phút)
    - `met`: Chỉ số MET của bài tập (mức độ cường độ)
    - `bodyWeight`: Cân nặng người tập (kg)
  - **Mục đích:** Giúp người dùng theo dõi lượng calo đã đốt cháy để đạt mục tiêu giảm cân hoặc tăng cân
  - **Test cases:**
    - Bài tập cơ bản: 30 phút, MET=5, 70kg → 3.0625 calo
    - Bài tập cường độ cao: 45 phút, MET=8, 80kg → 8.4 calo
    - Edge case: time=0 → 0 calo
    - So sánh cân nặng khác nhau: 80kg đốt cháy nhiều hơn 60kg

#### 1.3. WorkoutCollectionUtils (3 test cases)

**Mục đích:** Tính toán tổng thời gian cần thiết để hoàn thành một bộ bài tập (workout collection).

**Các function được test:**

- `calculateTime(CollectionSetting setting)` - Tính tổng thời gian tập luyện
  - **Công thức:** TotalTime = duration × numOfWorkoutPerRound × round
  - **Tham số từ CollectionSetting:**
    - `duration`: Thời gian mỗi bài tập (giây)
    - `numOfWorkoutPerRound`: Số bài tập mỗi vòng
    - `round`: Số vòng lặp lại
  - **Mục đích:** Giúp người dùng biết trước tổng thời gian cần để hoàn thành workout
  - **Test cases:**
    - Bộ bài tập chuẩn: 30s × 5 bài × 3 vòng = 450 giây
    - Edge case: numOfWorkoutPerRound=0 → 0 giây
    - So sánh: 2 vòng < 3 vòng

#### 1.4. WorkoutPlanUtils (3 test cases)

**Mục đích:** Tính toán lượng calo mục tiêu hàng ngày dựa trên BMR (Basal Metabolic Rate) và TDEE (Total Daily Energy Expenditure) để lập kế hoạch tập luyện phù hợp.

**Các function được test:**

- `calculateDailyGoalCalories(User user, String goal)` - Tính calo mục tiêu hàng ngày
  - **Bước 1: Tính BMR** (Tỷ lệ trao đổi chất cơ bản)
    - Nam: BMR = 10 × weight + 6.25 × height - 5 × age + 5
    - Nữ: BMR = 10 × weight + 6.25 × height - 5 × age - 161
  - **Bước 2: Tính TDEE** (Tổng năng lượng tiêu thụ hàng ngày)
    - TDEE = BMR × Activity Factor (1.2 - 1.9)
  - **Bước 3: Điều chỉnh theo mục tiêu**
    - Giảm cân: Goal = TDEE - 500 calo
    - Tăng cân: Goal = TDEE + 500 calo
    - Duy trì: Goal = TDEE
  - **Test cases:**
    - Nam 70kg, 175cm, 25 tuổi, giảm cân → ~1600 calo/ngày
    - Nữ 60kg, 165cm, 25 tuổi, tăng cân → ~2000 calo/ngày
    - Activity 1.7 > Activity 1.3 (mức độ hoạt động cao tiêu thụ nhiều hơn)

---

### 2. Validation (Kiểm tra tính hợp lệ) - 28 test cases

Nhóm này kiểm tra tính hợp lệ của dữ liệu đầu vào từ người dùng để đảm bảo ứng dụng hoạt động ổn định và đúng đắn.

#### 2.1. Email Validation (3 test cases)

**Mục đích:** Đảm bảo email người dùng nhập vào có định dạng hợp lệ trước khi gửi đến Firebase Authentication.

**Function được test:**

- `GetUtils.isEmail(String email)` - Kiểm tra định dạng email
  - **Quy tắc:** Phải có dạng `localpart@domain.extension`
  - **Test cases:**
    - Email hợp lệ: `user@example.com` → true
    - Email thiếu local part: `@example.com` → false
    - Email thiếu domain: `user@` → false
    - Chuỗi rỗng: `''` → false
    - Ký tự đặc biệt không hợp lệ: `user@exam ple.com`, `user@@example.com` → false

#### 2.2. Password Validation (4 test cases)

**Mục đích:** Đảm bảo mật khẩu đủ mạnh và nhất quán trước khi tạo tài khoản hoặc đổi mật khẩu.

**Các quy tắc được test:**

- **Độ dài tối thiểu:** Password phải có ít nhất 6 ký tự (yêu cầu của Firebase)

  - Test case: `'123456'` (6 ký tự) → valid
  - Test case: `'12345'` (5 ký tự) → invalid

- **Khớp mật khẩu:** Password và confirmPassword phải giống nhau
  - Test case: `'123456'` == `'123456'` → true
  - Test case: `'123456'` == `'abcdef'` → false

#### 2.3. User Info Validation (7 test cases)

**Mục đích:** Đảm bảo thông tin cá nhân người dùng nhập vào nằm trong phạm vi hợp lý cho ứng dụng fitness.

**Các field được validate:**

- **Chiều cao (Height):** 100cm - 250cm

  - **Lý do giới hạn:** Phạm vi chiều cao phù hợp cho người trưởng thành
  - Test valid: 150cm, 180cm
  - Test invalid: 90cm (< 100), 260cm (> 250)

- **Cân nặng (Weight):** 30kg - 200kg

  - **Lý do giới hạn:** Phạm vi cân nặng an toàn cho việc tính toán và tập luyện
  - Test valid: 50kg, 80kg
  - Test invalid: 25kg (< 30), 210kg (> 200)

- **Tuổi (Age):** 16 - 40 tuổi

  - **Lý do giới hạn:** Độ tuổi phù hợp cho ứng dụng (target audience)
  - Test valid: 20 tuổi, 35 tuổi
  - Test invalid: 15 tuổi (< 16), 45 tuổi (> 40)

- **Tên (Name):** Không được rỗng
  - Test: `'  John  '.trim()` → `'John'` (isNotEmpty = true)

#### 2.4. Date Validation (4 test cases)

**Mục đích:** Đảm bảo ngày tháng hợp lệ và tính toán tuổi chính xác.

**Các quy tắc được test:**

- **Ngày sinh phải trong quá khứ**

  - Test valid: 2000-01-01 < 2025-12-23 (hiện tại) → hợp lệ
  - Test invalid: 2026-01-01 > 2025-12-23 → không hợp lệ

- **Tính tuổi từ ngày sinh**

  - Công thức: age = currentYear - birthYear
  - Test: Birthday 2000-06-10, hiện tại 2025-12-23 → age = 25

- **Kiểm tra độ tuổi hợp lệ**
  - Kết hợp với validation: 16 <= age <= 40
  - Test: age = 25 → hợp lệ

#### 2.5. Logic & Comparison (2 test cases)

**Mục đích:** Kiểm tra các phép so sánh và tính toán logic trong ứng dụng.

**Các logic được test:**

- **So sánh cân nặng hiện tại vs mục tiêu**

  - currentWeight = 70kg, goalWeight = 65kg
  - 70 > 65 → đang muốn giảm cân

- **Tính tiến độ giảm cân**
  - Công thức: progress = (startWeight - currentWeight) / (startWeight - goalWeight) × 100
  - Test: start=75kg, current=70kg, goal=65kg → progress = 50%

#### 2.6. String Manipulation (3 test cases)

**Mục đích:** Kiểm tra xử lý chuỗi ký tự để tránh lỗi khi hiển thị hoặc lưu trữ dữ liệu.

**Các function được test:**

- `trim()` - Loại bỏ khoảng trắng đầu cuối

  - Test: `'  hello world  '` → `'hello world'`

- `isEmpty` / `isNotEmpty` - Kiểm tra chuỗi rỗng

  - Test: `''`.isEmpty → true
  - Test: `'hello'`.isNotEmpty → true

- `toUpperCase()` / `toLowerCase()` - Chuyển đổi chữ hoa/thường
  - Test: `'Hello'` → `'HELLO'` và `'hello'`

#### 2.7. Number Validation (5 test cases)

**Mục đích:** Đảm bảo parse số từ string an toàn, tránh crash khi người dùng nhập dữ liệu không hợp lệ.

**Các function được test:**

- `int.tryParse(String)` - Parse số nguyên

  - Test valid: `'123'` → 123
  - Test invalid: `'abc'` → null

- `double.tryParse(String)` - Parse số thập phân

  - Test valid: `'12.5'` → 12.5
  - Test invalid: `'12.5.3'` → null

- `isNegative` - Kiểm tra số âm
  - Test: 5.isNegative → false
  - Test: (-5).isNegative → true
  - Test: 0 == 0 → true

---

### 3. Models (Mô hình dữ liệu) - 11 test cases

Nhóm này kiểm tra việc khởi tạo, serialization/deserialization của các model class để đảm bảo dữ liệu được lưu và đọc từ database chính xác.

#### 3.1. ExerciseTracker Model (5 test cases)

**Mục đích:** Model để theo dõi lịch sử tập luyện của người dùng, lưu trữ thông tin về phiên tập đã hoàn thành.

**Các properties:**

- `id`: ID của bản ghi
- `date`: Ngày tập luyện
- `outtakeCalories`: Lượng calo đã đốt cháy
- `sessionNumber`: Số phiên tập
- `totalTime`: Tổng thời gian tập (phút)

**Các function được test:**

- **Constructor** - Khởi tạo object với các tham số

  - Test: Tạo ExerciseTracker với id=1, outtakeCalories=250, sessionNumber=5, totalTime=45
  - Verify: Tất cả properties khớp với giá trị đã truyền

- `toMap()` - Chuyển object sang Map để lưu vào Firestore

  - Test: tracker.toMap() → Map chứa các keys: 'id', 'outtakeCalories', 'sessionNumber', etc.
  - Mục đích: Serialize data trước khi lưu vào database

- `fromMap(Map)` - Tạo object từ Map khi đọc từ Firestore

  - Test: ExerciseTracker.fromMap(map) → object với đầy đủ properties
  - Mục đích: Deserialize data từ database

- **Default values** - Xử lý khi Map thiếu một số field

  - Test: Map chỉ có id, date → các field khác có giá trị mặc định = 0
  - Mục đích: Tránh crash khi data không đầy đủ

- **Update properties** - Cập nhật thông tin
  - Test: Sửa outtakeCalories = 350, totalTime = 60 → properties được cập nhật thành công

#### 3.2. CollectionSetting Model (6 test cases)

**Mục đích:** Model lưu trữ cấu hình cho một bộ bài tập (workout collection), bao gồm số vòng, số bài tập, thời gian mỗi bài, thời gian nghỉ, v.v.

**Các properties:**

- `round`: Số vòng lặp lại (default: 3)
- `numOfWorkoutPerRound`: Số bài tập mỗi vòng (default: 5)
- `exerciseTime`: Thời gian mỗi bài tập (giây, default: 10)
- `transitionTime`: Thời gian chuyển bài (giây, default: 10)
- `restTime`: Thời gian nghỉ giữa các vòng (giây, default: 10)
- `isStartWithWarmUp`: Bắt đầu với khởi động (default: true)
- `isShuffle`: Xáo trộn thứ tự bài tập (default: true)

**Các function được test:**

- **Default constructor** - Khởi tạo với giá trị mặc định

  - Test: CollectionSetting() → round=3, numOfWorkoutPerRound=5, exerciseTime=10, etc.
  - Mục đích: Người dùng không cần nhập, ứng dụng tự động có setting mặc định

- **Custom constructor** - Khởi tạo với tham số tùy chỉnh

  - Test: CollectionSetting(round=5, numOfWorkoutPerRound=8, exerciseTime=15)
  - Verify: Tất cả properties khớp với giá trị custom

- **Tính tổng thời gian** - Calculate total exercise time

  - Công thức: totalTime = exerciseTime × numOfWorkoutPerRound × round
  - Test: 10s × 5 bài × 3 vòng = 150 giây

- **Shuffle mode** - Kiểm tra chế độ xáo trộn

  - Test: isShuffle=true vs isShuffle=false → giá trị khác nhau

- **Warm up mode** - Kiểm tra chế độ khởi động

  - Test: isStartWithWarmUp=true vs isStartWithWarmUp=false → giá trị khác nhau

- `fromCollectionSetting()` - Clone/Copy setting
  - Test: Tạo copy từ original → tất cả properties giống original
  - Mục đích: Cho phép người dùng tạo setting mới dựa trên setting có sẵn

---

## 5.1.2. Chi tiết test cases

### Bảng test case Converter - Chuyển đổi đơn vị

| ID    | Tên Test Case             | Các bước thực hiện                                                   | Kết quả kỳ vọng                          |
| ----- | ------------------------- | -------------------------------------------------------------------- | ---------------------------------------- |
| UT001 | Chuyển đổi Cm sang Ft     | 1. Gọi hàm `Converter.convertCmToFt(170)`<br>2. Kiểm tra kết quả     | Trả về giá trị 5.577ft (±0.001)          |
| UT002 | Chuyển đổi Ft sang Cm     | 1. Gọi hàm `Converter.convertFtToCm(5.577)`<br>2. Kiểm tra kết quả   | Trả về giá trị 170cm (±0.01)             |
| UT003 | Chuyển đổi Kg sang Lbs    | 1. Gọi hàm `Converter.convertKgToLbs(70)`<br>2. Kiểm tra kết quả     | Trả về giá trị 154.32lbs (±0.01)         |
| UT004 | Chuyển đổi Lbs sang Kg    | 1. Gọi hàm `Converter.convertLbsToKg(154.32)`<br>2. Kiểm tra kết quả | Trả về giá trị 70kg (±0.01)              |
| UT005 | Giá trị âm khi chuyển đổi | 1. Gọi hàm convert với giá trị âm (vd: -10)<br>2. Kiểm tra kết quả   | Giá trị âm không bị thay đổi, trả về -10 |

### Bảng test case SessionUtils - Tính Calo

| ID    | Tên Test Case                      | Các bước thực hiện                                                                                                                  | Kết quả kỳ vọng                                                  |
| ----- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| UT006 | Tính calo cho 1 bài tập cơ bản     | 1. Gọi `SessionUtils.calculateCaloOneWorkout(30, 5, 70)`<br>2. Tham số: time=30 phút, MET=5, bodyWeight=70kg<br>3. Kiểm tra kết quả | Trả về 3.0625 calo (±0.01) theo công thức: (30/60)*5*70\*3.5/200 |
| UT007 | Tính calo cho bài tập cường độ cao | 1. Gọi `SessionUtils.calculateCaloOneWorkout(45, 8, 80)`<br>2. Tham số: time=45 phút, MET=8, bodyWeight=80kg<br>3. Kiểm tra kết quả | Trả về 8.4 calo (±0.01)                                          |
| UT008 | Tính calo khi thời gian = 0        | 1. Gọi `SessionUtils.calculateCaloOneWorkout(0, 5, 70)`<br>2. Thời gian = 0<br>3. Kiểm tra kết quả                                  | Trả về 0 calo                                                    |
| UT009 | Tính calo với cân nặng khác nhau   | 1. Gọi hàm với cân nặng 60kg<br>2. Gọi hàm với cân nặng 80kg<br>3. So sánh kết quả                                                  | Cân nặng 80kg cho calo cao hơn 60kg                              |

---

| #     | ID                                      | Tên Test Case                                                                                                                                     | Các bước thực hiện            | Kết quả kỳ vọng |
| ----- | --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- | --------------- |
| UT010 | Tính thời gian cho 1 workout collection | 1. Tạo CollectionSetting: duration=30s, numOfWorkoutPerRound=5, round=3<br>2. Gọi `WorkoutCollectionUtils.calculateTime()`<br>3. Kiểm tra kết quả | Trả về 450 giây (30 × 5 × 3)  |
| UT011 | Tính thời gian khi số bài = 0           | 1. Tạo CollectionSetting với numOfWorkoutPerRound=0<br>2. Gọi calculateTime()<br>3. Kiểm tra kết quả                                              | Trả về 0 giây                 |
| UT012 | So sánh thời gian với số vòng khác nhau | 1. Tính time với round=2<br>2. Tính time với round=3<br>3. So sánh kết quả                                                                        | Time(round=2) < Time(round=3) |

---

| #     | ID                                        | Tên Test Case                                                                                                                                                  | Các bước thực hiện                 | Kết quả kỳ vọng |
| ----- | ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- | --------------- |
| UT013 | Tính Daily Goal Calories cho nam giảm cân | 1. Tạo User: Nam, 70kg, 175cm, 25 tuổi, activity=1.5<br>2. Mục tiêu: Giảm cân<br>3. Gọi `WorkoutPlanUtils.calculateDailyGoalCalories()`<br>4. Kiểm tra kết quả | Trả về ~1600 calo/ngày (BMR - 500) |
| UT014 | Tính Daily Goal Calories cho nữ tăng cân  | 1. Tạo User: Nữ, 60kg, 165cm, 25 tuổi, activity=1.5<br>2. Mục tiêu: Tăng cân<br>3. Gọi calculateDailyGoalCalories()<br>4. Kiểm tra kết quả                     | Trả về ~2000 calo/ngày (BMR + 500) |
| UT015 | Mức độ hoạt động ảnh hưởng TDEE           | 1. Tính TDEE với activity=1.3<br>2. Tính TDEE với activity=1.7<br>3. So sánh kết quả                                                                           | TDEE(1.7) > TDEE(1.3)              |

---

| #     | ID                                   | Tên Test Case                                                                                                      | Các bước thực hiện  | Kết quả kỳ vọng |
| ----- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------ | ------------------- | --------------- |
| UT016 | Email hợp lệ                         | 1. Gọi `GetUtils.isEmail('user@example.com')`<br>2. Kiểm tra kết quả                                               | Trả về true         |
| UT017 | Email không hợp lệ                   | 1. Test với `@example.com` (thiếu local part)<br>2. Test với `user@` (thiếu domain)<br>3. Test với chuỗi rỗng `''` | Tất cả trả về false |
| UT018 | Email có ký tự đặc biệt không hợp lệ | 1. Test với `user@exam ple.com` (có space)<br>2. Test với `user@@example.com` (có @@)<br>3. Kiểm tra kết quả       | Tất cả trả về false |

---

## Bảng test case Password Validation

#| UT019 | Mật khẩu đủ độ dài | 1. Kiểm tra password `'123456'` (6 ký tự)<br>2. Kiểm tra password `'12345678'` (8 ký tự) | Cả 2 đều valid (length >= 6) |
| UT020 | Mật khẩu quá ngắn | 1. Kiểm tra password `'12345'` (5 ký tự)<br>2. Kiểm tra password `'abc'` (3 ký tự) | Cả 2 đều invalid (length < 6) |
| UT021 | Mật khẩu khớp nhau | 1. password = `'123456'`<br>2. confirmPassword = `'123456'`<br>3. So sánh `password == confirmPassword` | Trả về true |
| UT022 | Mật khẩu không khớp | 1. password = `'123456'`<br>2. confirmPassword = `'abcdef'`<br>3. So sánh `password == confirmPassword` | Trả về false |

---

## Bảng test case User Info Validation

#| UT023 | Chiều cao hợp lệ | 1. Kiểm tra height = 150cm<br>2. Kiểm tra height = 180cm<br>3. Điều kiện: 100 <= height <= 250 | Cả 2 đều valid |
| UT024 | Chiều cao không hợp lệ | 1. Kiểm tra height = 90cm (< 100)<br>2. Kiểm tra height = 260cm (> 250) | Cả 2 đều invalid |
| UT025 | Cân nặng hợp lệ | 1. Kiểm tra weight = 50kg<br>2. Kiểm tra weight = 80kg<br>3. Điều kiện: 30 <= weight <= 200 | Cả 2 đều valid |
| UT026 | Cân nặng không hợp lệ | 1. Kiểm tra weight = 25kg (< 30)<br>2. Kiểm tra weight = 210kg (> 200) | Cả 2 đều invalid |
| UT027 | Tuổi hợp lệ | 1. Kiểm tra age = 20<br>2. Kiểm tra age = 35<br>3. Điều kiện: 16 <= age <= 40 | Cả 2 đều valid |
| UT028 | Tuổi không hợp lệ | 1. Kiểm tra age = 15 (< 16)<br>2. Kiểm tra age = 45 (> 40) | Cả 2 đều invalid |
| UT029 | Tên không được rỗng | 1. Nhập name = `'  John  '`<br>2. Trim: `name.trim()`<br>3. Kiểm tra `isNotEmpty` | Sau trim: `'John'`, isNotEmpty = true |

---

## Bảng test case Date Validation

#| UT030 | Ngày sinh hợp lệ (trong quá khứ) | 1. Ngày hiện tại: 2025-12-23<br>2. Kiểm tra birthday = 2000-01-01<br>3. So sánh `birthday.isBefore(DateTime.now())` | Trả về true (hợp lệ) |
| UT031 | Ngày sinh không hợp lệ (tương lai) | 1. Ngày hiện tại: 2025-12-23<br>2. Kiểm tra birthday = 2026-01-01<br>3. So sánh `birthday.isAfter(DateTime.now())` | Trả về true → invalid |
| UT032 | Tính tuổi từ ngày sinh | 1. Ngày hiện tại: 2025-12-23<br>2. Birthday = 2000-06-10<br>3. Tính age = currentYear - birthYear | Trả về age = 25 |
| UT033 | Kiểm tra tuổi hợp lệ cho app | 1. Tính age từ birthday<br>2. Kiểm tra điều kiện 16 <= age <= 40<br>3. Test với age = 25 | Trả về true (hợp lệ) |

---

## Bảng test case Logic & Comparison

| ID  | Tên Test Case | Các bước thực hiện | Kết quả kỳ vọng |
| --- | ------------- | ------------------ | --------------- |

#

---

## Bảng test case String Manipulation

| ID  | Tên Test Case | Các bước thực hiện        | Kết quả kỳ vọng                                                                           |
| --- | ------------- | ------------------------- | ----------------------------------------------------------------------------------------- | ---------------------- |
| #   | UT038         | Chuyển đổi chữ hoa/thường | 1. String = `'Hello'`<br>2. Gọi `toUpperCase()` và `toLowerCase()`<br>3. Kiểm tra kết quả | `'HELLO'` và `'hello'` |

---

## Bảng test case Number Validation

| ID    | Tên Test Case                   | Các bước thực hiện                                                                  | Kết quả kỳ vọng                                         |
| ----- | ------------------------------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------- | -------------------- |
| #     | UT041                           | Parse số thập phân hợp lệ                                                           | 1. Gọi `double.tryParse('12.5')`<br>2. Kiểm tra kết quả | Trả về 12.5 (double) |
| UT042 | Parse số thập phân không hợp lệ | 1. Gọi `double.tryParse('12.5.3')`<br>2. Kiểm tra kết quả                           | Trả về null                                             |
| UT043 | Số dương, âm, zero              | 1. Kiểm tra `5.isNegative`<br>2. Kiểm tra `(-5).isNegative`<br>3. Kiểm tra `0 == 0` | false, true, true                                       |

---

## Bảng test case ExerciseTracker Model

| ID    | Tên Test Case                      | Các bước thực hiện                                                                                                                  | Kết quả kỳ vọng                                                                                          |
| ----- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| UT044 | Tạo ExerciseTracker từ constructor | 1. Gọi constructor với tham số: id=1, date, outtakeCalories=250, sessionNumber=5, totalTime=45<br>2. Kiểm tra các properties        | Tất cả properties khớp với giá trị đã truyền vào                                                         |
| UT045 | Chuyển ExerciseTracker thành Map   | 1. Tạo ExerciseTracker object<br>2. Gọi `tracker.toMap()`<br>3. Kiểm tra Map có chứa keys: 'id', 'outtakeCalories', 'sessionNumber' | Map chứa đầy đủ các field với giá trị đúng                                                               |
| #     | UT048                              | Cập nhật ExerciseTracker                                                                                                            | 1. Tạo ExerciseTracker object<br>2. Sửa: outtakeCalories = 350, totalTime = 60<br>3. Kiểm tra properties | Properties được cập nhật thành công |

---

## Bảng test case CollectionSetting Model

| ID    | Tên Test Case                              | Các bước thực hiện                                                                                                  | Kết quả kỳ vọng                                                                                                          |
| ----- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------------------------------- |
| UT049 | Tạo CollectionSetting với giá trị mặc định | 1. Gọi `CollectionSetting()` không truyền tham số<br>2. Kiểm tra các properties                                     | round=3, numOfWorkoutPerRound=5, exerciseTime=10, transitionTime=10, restTime=10, isStartWithWarmUp=true, isShuffle=true |
| UT050 | Tạo CollectionSetting với tham số custom   | 1. Gọi constructor với: round=5, numOfWorkoutPerRound=8, exerciseTime=15<br>2. Kiểm tra properties                  | Tất cả properties khớp với giá trị custom                                                                                |
| #     | UT053                                      | Kiểm tra tính năng Warm Up                                                                                          | 1. Tạo setting với isStartWithWarmUp=true<br>2. Tạo setting với isStartWithWarmUp=false<br>3. Kiểm tra giá trị           | Giá trị khác nhau (true vs false) |
| UT054 | Clone/Copy CollectionSetting               | 1. Tạo original setting<br>2. Gọi `CollectionSetting.fromCollectionSetting(original)`<br>3. Kiểm tra copied setting | Tất cả properties giống original                                                                                         |

---

## Tổng kết

**Tổng số test cases: 54**
**Kết quả: 54/54 PASSED (100%)**

| Nhóm Test | Số lượng | Kết quả     |
| --------- | -------- | ----------- |
| Converter | 5        | ✅ 5/5 PASS |

| S5.1.3. Kết quả

### Tổng kết kết quả Unit Test

**Tổng số test cases: 54**  
**Kết quả: 54/54 PASSED (100%)**

### Thời gian thực thi

- Tổng thời gian chạy test: 1 giây
- Lệnh thực thi: `flutter test test/unit`

### Báo cáo chi tiết theo nhóm chức năngASS |

| Password Validation | 4 | ✅ 4/4 PASS |
| User Info Validation | 7 | ✅ 7/7 PASS |
| Date Validation | 4 | ✅ 4/4 PASS |
| Logic & Comparison | 2 | ✅ 2/2 PASS |
| String Manipulation | 3 | ✅ 3/3 PASS |
| Number Validation | 5 | ✅ 5/5 PASS |
| ExerciseTracker Model | 5 | ✅ 5/5 PASS |
| CollectionSetting Model | 6 | ✅ 6/6 PASS |
| **TỔNG** | **54** | **✅ 54/54 PASS** |

### Đánh giá

**Tỷ lệ thành công:** 100%

**Các chức năng đã được kiểm tra:**

- ✅ Chuyển đổi đơn vị đo lường (cm/ft, kg/lbs)
- ✅ Tính toán calo tiêu thụ theo công thức MET
- ✅ Tính toán thời gian tập luyện
- ✅ Tính toán BMR, TDEE và lượng calo mục tiêu
- ✅ Validation dữ liệu đầu vào (email, password, thông tin cá nhân)
- ✅ Xử lý dữ liệu ngày tháng
- ✅ Serialization/Deserialization của các model

**Kết luận:**  
Tất cả các unit test đều PASS, chứng tỏ các function cốt lõi của ứng dụng hoạt động đúng như mong đợi. Các trường hợp biên (edge cases) như giá trị âm, giá trị 0, dữ liệu không hợp lệ đều được xử lý chính xác.
