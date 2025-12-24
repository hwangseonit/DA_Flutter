import 'package:flutter_test/flutter_test.dart';
import 'package:vipt/app/core/utilities/utils.dart';
import 'package:vipt/app/data/models/collection_setting.dart';
import 'package:vipt/app/data/models/vipt_user.dart';
import 'package:vipt/app/enums/app_enums.dart';

/// Unit Tests cho các hàm tính toán trong Utils
/// Phục vụ cho báo cáo: Chương 5.1 - Unit Test
void main() {
  group('Converter - Chuyển đổi đơn vị', () {
    test('Chuyển đổi Cm sang Ft', () {
      // Test: 170cm = 5.577ft
      double result = Converter.convertCmToFt(170);
      expect(result, closeTo(5.577, 0.01));
    });

    test('Chuyển đổi Ft sang Cm', () {
      // Test: 5.5ft = 167.64cm
      double result = Converter.convertFtToCm(5.5);
      expect(result, closeTo(167.64, 0.01));
    });

    test('Chuyển đổi Kg sang Lbs', () {
      // Test: 70kg = 154.32lbs
      double result = Converter.convertKgToLbs(70);
      expect(result, closeTo(154.32, 0.01));
    });

    test('Chuyển đổi Lbs sang Kg', () {
      // Test: 150lbs = 68.04kg
      double result = Converter.convertLbsToKg(150);
      expect(result, closeTo(68.04, 0.01));
    });

    test('Giá trị âm khi chuyển đổi', () {
      // Kiểm tra xử lý giá trị không hợp lệ
      double result = Converter.convertCmToFt(-10);
      expect(result, lessThan(0));
    });
  });

  group('SessionUtils - Tính calo cho bài tập', () {
    test('Tính calo cho 1 bài tập cơ bản', () {
      // Test: 30 phút, MET=5, cân nặng 70kg
      double calo = SessionUtils.calculateCaloOneWorkout(30, 5, 70);

      // Công thức: (30/60) * 5 * 70 * 3.5 / 200 = 3.0625
      expect(calo, closeTo(3.0625, 0.01));
    });

    test('Tính calo cho bài tập cường độ cao', () {
      // Test: 45 phút, MET=8 (chạy nhanh), cân nặng 80kg
      double calo = SessionUtils.calculateCaloOneWorkout(45, 8, 80);

      // Công thức: (45/60) * 8 * 80 * 3.5 / 200 = 8.4
      expect(calo, closeTo(8.4, 0.01));
    });

    test('Tính calo khi thời gian = 0', () {
      double calo = SessionUtils.calculateCaloOneWorkout(0, 5, 70);
      expect(calo, equals(0));
    });

    test('Tính calo với cân nặng khác nhau', () {
      // Cùng bài tập, người nặng hơn đốt calo nhiều hơn
      double calo50kg = SessionUtils.calculateCaloOneWorkout(30, 5, 50);
      double calo70kg = SessionUtils.calculateCaloOneWorkout(30, 5, 70);
      double calo90kg = SessionUtils.calculateCaloOneWorkout(30, 5, 90);

      expect(calo50kg < calo70kg, isTrue);
      expect(calo70kg < calo90kg, isTrue);
    });
  });

  group('WorkoutCollectionUtils - Tính thời gian tập', () {
    test('Tính thời gian cho 1 workout collection đơn giản', () {
      final setting = CollectionSetting(
        round: 3,
        exerciseTime: 30, // 30 giây/bài
        transitionTime: 5, // 5 giây nghỉ giữa bài
        restTime: 60, // 60 giây nghỉ giữa vòng
        restFrequency: 3, // Nghỉ sau mỗi 3 bài
      );

      // 5 bài tập
      double time = WorkoutCollectionUtils.calculateTime(
        collectionSetting: setting,
        workoutListLength: 5,
      );

      // Tính toán: ((30+5)*5)*3 + nghỉ giữa vòng
      expect(time, greaterThan(0));
      expect(time, lessThan(20)); // Dưới 20 phút
    });

    test('Tính thời gian khi số bài = 0', () {
      final setting = CollectionSetting(
        round: 3,
        exerciseTime: 30,
        transitionTime: 5,
        restTime: 60,
        restFrequency: 3,
      );

      double time = WorkoutCollectionUtils.calculateTime(
        collectionSetting: setting,
        workoutListLength: 0,
      );

      expect(time, equals(0));
    });

    test('So sánh thời gian với số vòng khác nhau', () {
      final setting1Round = CollectionSetting(
        round: 1,
        exerciseTime: 30,
        transitionTime: 5,
        restTime: 60,
        restFrequency: 3,
      );

      final setting3Rounds = CollectionSetting(
        round: 3,
        exerciseTime: 30,
        transitionTime: 5,
        restTime: 60,
        restFrequency: 3,
      );

      double time1 = WorkoutCollectionUtils.calculateTime(
        collectionSetting: setting1Round,
        workoutListLength: 5,
      );

      double time3 = WorkoutCollectionUtils.calculateTime(
        collectionSetting: setting3Rounds,
        workoutListLength: 5,
      );

      // 3 vòng phải dài hơn 1 vòng
      expect(time3, greaterThan(time1));
    });
  });

  group('WorkoutPlanUtils - Tính BMR và TDEE', () {
    test('Tính Daily Goal Calories cho nam giới muốn giảm cân', () {
      // Tạo user test: nam, 25 tuổi, 80kg, 175cm, muốn về 70kg
      final user = ViPTUser(
        id: 'test_user',
        name: 'Test User',
        gender: Gender.male,
        dateOfBirth: DateTime(2000, 1, 1),
        currentWeight: 80,
        currentHeight: 175,
        goalWeight: 70,
        weightUnit: WeightUnit.kg,
        heightUnit: HeightUnit.cm,
        hobbies: [],
        diet: null,
        badHabits: [],
        proteinSources: [],
        limits: [],
        sleepTime: null,
        dailyWater: null,
        mainGoal: null,
        bodyType: null,
        experience: null,
        typicalDay: null,
        activeFrequency: ActiveFrequency.average,
        collectionSetting: CollectionSetting(),
      );

      num goalCalories = WorkoutPlanUtils.createDailyGoalCalories(user);

      // Calories phải > 0
      expect(goalCalories, greaterThan(0));
      // Vì muốn giảm cân, calories phải thấp hơn TDEE
      expect(goalCalories, greaterThan(1500));
      expect(goalCalories, lessThan(3000));
    });

    test('Tính Daily Goal Calories cho nữ muốn tăng cân', () {
      final user = ViPTUser(
        id: 'test_user',
        name: 'Test User',
        gender: Gender.female,
        dateOfBirth: DateTime(2000, 1, 1),
        currentWeight: 50,
        currentHeight: 160,
        goalWeight: 55,
        weightUnit: WeightUnit.kg,
        heightUnit: HeightUnit.cm,
        hobbies: [],
        diet: null,
        badHabits: [],
        proteinSources: [],
        limits: [],
        sleepTime: null,
        dailyWater: null,
        mainGoal: null,
        bodyType: null,
        experience: null,
        typicalDay: null,
        activeFrequency: ActiveFrequency.average,
        collectionSetting: CollectionSetting(),
      );

      num goalCalories = WorkoutPlanUtils.createDailyGoalCalories(user);

      expect(goalCalories, greaterThan(0));
      expect(goalCalories, greaterThan(1200));
      expect(goalCalories, lessThan(2500));
    });

    test('Mức độ hoạt động ảnh hưởng đến TDEE', () {
      // User ít vận động
      final userNotMuch = ViPTUser(
        id: 'test_user',
        name: 'Test User',
        gender: Gender.male,
        dateOfBirth: DateTime(2000, 1, 1),
        currentWeight: 70,
        currentHeight: 175,
        goalWeight: 70,
        weightUnit: WeightUnit.kg,
        heightUnit: HeightUnit.cm,
        hobbies: [],
        diet: null,
        badHabits: [],
        proteinSources: [],
        limits: [],
        sleepTime: null,
        dailyWater: null,
        mainGoal: null,
        bodyType: null,
        experience: null,
        typicalDay: null,
        activeFrequency: ActiveFrequency.notMuch,
        collectionSetting: CollectionSetting(),
      );

      // User rất vận động
      final userSoMuch = ViPTUser(
        id: 'test_user',
        name: 'Test User',
        gender: Gender.male,
        dateOfBirth: DateTime(2000, 1, 1),
        currentWeight: 70,
        currentHeight: 175,
        goalWeight: 70,
        weightUnit: WeightUnit.kg,
        heightUnit: HeightUnit.cm,
        hobbies: [],
        diet: null,
        badHabits: [],
        proteinSources: [],
        limits: [],
        sleepTime: null,
        dailyWater: null,
        mainGoal: null,
        bodyType: null,
        experience: null,
        typicalDay: null,
        activeFrequency: ActiveFrequency.soMuch,
        collectionSetting: CollectionSetting(),
      );

      num caloriesNotMuch =
          WorkoutPlanUtils.createDailyGoalCalories(userNotMuch);
      num caloriesSoMuch = WorkoutPlanUtils.createDailyGoalCalories(userSoMuch);

      // Người vận động nhiều cần calories cao hơn
      expect(caloriesSoMuch, greaterThan(caloriesNotMuch));
    });
  });
}
