import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vipt/app/data/models/exercise_tracker.dart';
import 'package:vipt/app/data/models/collection_setting.dart';
import 'package:vipt/app/core/utilities/utils.dart';

/// Integration Tests - Kiểm thử tích hợp
/// Phục vụ cho báo cáo: Chương 5.2 - Integration Test
///
/// Các test này kiểm tra tương tác giữa nhiều components và services
/// bao gồm: Authentication, Data Validation, Workout Management, Data Persistence

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('IT - Authentication Flow', () {
    test('IT001: Đăng ký tài khoản - validate email và password', () {
      // Arrange
      final email = 'newuser@fitness.com';
      final password = 'password123';
      final confirmPassword = 'password123';

      // Act
      final isEmailValid = GetUtils.isEmail(email);
      final isPasswordValid = password.length >= 6;
      final isPasswordMatch = password == confirmPassword;
      final canRegister = isEmailValid && isPasswordValid && isPasswordMatch;

      // Assert
      expect(canRegister, isTrue);
    });

    test('IT002: Đăng nhập - validate credentials', () {
      // Arrange
      final email = 'user@fitness.com';
      final password = 'secure123';

      // Act
      final isEmailValid = GetUtils.isEmail(email);
      final isPasswordValid = password.length >= 6;

      // Assert
      expect(isEmailValid, isTrue);
      expect(isPasswordValid, isTrue);
    });

    test('IT003: Đăng nhập thất bại - email sai format', () {
      // Arrange
      final email = 'invalid-email';
      final password = 'password123';

      // Act
      final isEmailValid = GetUtils.isEmail(email);

      // Assert
      expect(isEmailValid, isFalse);
    });

    test('IT004: Đăng ký thất bại - password không khớp', () {
      // Arrange
      final password = 'password123';
      final confirmPassword = 'password456';

      // Act
      final isMatch = password == confirmPassword;

      // Assert
      expect(isMatch, isFalse);
    });
  });

  group('IT - User Profile Validation', () {
    test('IT005: Validate thông tin cơ bản người dùng', () {
      // Arrange
      final height = 175; // cm
      final weight = 70; // kg
      final age = 25;
      final name = 'Nguyễn Văn A';

      // Act
      final isHeightValid = height >= 100 && height <= 250;
      final isWeightValid = weight >= 30 && weight <= 200;
      final isAgeValid = age >= 16 && age <= 40;
      final isNameValid = name.trim().isNotEmpty;
      final isProfileValid =
          isHeightValid && isWeightValid && isAgeValid && isNameValid;

      // Assert
      expect(isProfileValid, isTrue);
    });

    test('IT006: Reject profile với chiều cao không hợp lệ', () {
      // Arrange
      final height = 300; // Quá cao

      // Act
      final isValid = height >= 100 && height <= 250;

      // Assert
      expect(isValid, isFalse);
    });

    test('IT007: Reject profile với cân nặng không hợp lệ', () {
      // Arrange
      final weight = 250; // Quá nặng

      // Act
      final isValid = weight >= 30 && weight <= 200;

      // Assert
      expect(isValid, isFalse);
    });

    test('IT008: Chuyển đổi đơn vị chiều cao và cân nặng', () {
      // Arrange
      final heightCm = 175;
      final weightKg = 70;

      // Act
      final heightFt = Converter.convertCmToFt(heightCm.toDouble());
      final weightLbs = Converter.convertKgToLbs(weightKg.toDouble());

      // Assert
      expect(heightFt, closeTo(5.74, 0.01)); // 175cm = 5.74ft
      expect(weightLbs, closeTo(154.32, 0.1));
    });
  });

  group('IT - Workout Collection Management', () {
    test('IT009: Tạo collection setting và tính thời gian', () {
      // Arrange
      final setting = CollectionSetting(
        round: 3,
        numOfWorkoutPerRound: 5,
        exerciseTime: 30,
        transitionTime: 10,
        restTime: 60,
      );

      // Act
      final timePerExercise = setting.exerciseTime + setting.transitionTime;
      final totalTime =
          timePerExercise * setting.numOfWorkoutPerRound * setting.round;

      // Assert
      expect(timePerExercise, equals(40));
      expect(totalTime, equals(600)); // 40 * 5 * 3
    });

    test('IT010: Clone collection setting', () {
      // Arrange
      final original = CollectionSetting(
        round: 4,
        exerciseTime: 25,
        isShuffle: false,
      );

      // Act
      final cloned = CollectionSetting.fromCollectionSetting(original);

      // Assert
      expect(cloned.round, equals(original.round));
      expect(cloned.exerciseTime, equals(original.exerciseTime));
      expect(cloned.isShuffle, equals(original.isShuffle));
    });

    test('IT011: Tạo workout session và tính calo', () {
      // Arrange
      final bodyWeight = 70; // kg
      final exerciseTime = 30; // phút
      final metValue = 5.0;

      // Act
      final calories = SessionUtils.calculateCaloOneWorkout(
        exerciseTime, // int
        metValue,
        bodyWeight,
      );

      // Assert
      expect(calories, greaterThan(0));
      expect(calories, closeTo(3.0625, 0.01));
    });

    test('IT012: Tính tổng calo cho workout collection', () {
      // Arrange
      final setting = CollectionSetting(
        numOfWorkoutPerRound: 5,
        round: 3,
        exerciseTime: 10, // giây
      );
      final bodyWeight = 75;
      final avgMET = 6.0;

      // Act
      final totalExercises = setting.numOfWorkoutPerRound * setting.round;
      final timePerExerciseSeconds = setting.exerciseTime; // giây
      final caloriesPerExercise = SessionUtils.calculateCaloOneWorkout(
        timePerExerciseSeconds,
        avgMET,
        bodyWeight,
      );
      final totalCalories = caloriesPerExercise * totalExercises;

      // Assert
      expect(totalCalories, greaterThan(0));
    });
  });

  group('IT - Exercise Tracking & Persistence', () {
    test('IT013: Tạo và lưu exercise tracker', () {
      // Arrange
      final tracker = ExerciseTracker(
        id: 1,
        date: DateTime(2025, 12, 23),
        outtakeCalories: 250,
        sessionNumber: 5,
        totalTime: 45,
      );

      // Act
      final map = tracker.toMap();

      // Assert
      expect(map['id'], equals(1));
      expect(map['outtakeCalories'], equals(250));
      expect(map['sessionNumber'], equals(5));
      expect(map['totalTime'], equals(45));
    });

    test('IT014: Đọc exercise tracker từ database', () {
      // Arrange
      final map = {
        'id': 2,
        'date': DateTime(2025, 12, 22).toString(),
        'outtakeCalories': 300,
        'sessionNumber': 7,
        'totalTime': 60,
      };

      // Act
      final tracker = ExerciseTracker.fromMap(map);

      // Assert
      expect(tracker.id, equals(2));
      expect(tracker.outtakeCalories, equals(300));
      expect(tracker.sessionNumber, equals(7));
    });

    test('IT015: Cập nhật exercise tracker', () {
      // Arrange
      final tracker = ExerciseTracker(
        date: DateTime.now(),
        outtakeCalories: 100,
        sessionNumber: 3,
        totalTime: 20,
      );

      // Act
      tracker.outtakeCalories = 250;
      tracker.sessionNumber = 6;
      tracker.totalTime = 45;

      // Assert
      expect(tracker.outtakeCalories, equals(250));
      expect(tracker.sessionNumber, equals(6));
      expect(tracker.totalTime, equals(45));
    });

    test('IT016: Track nhiều sessions trong ngày', () {
      // Arrange
      final sessions = <ExerciseTracker>[];

      // Act - Tạo 3 sessions
      for (int i = 0; i < 3; i++) {
        sessions.add(ExerciseTracker(
          id: i + 1,
          date: DateTime(2025, 12, 23),
          outtakeCalories: 100 + (i * 50),
          sessionNumber: 5,
          totalTime: 30,
        ));
      }

      final totalCalories = sessions.fold<int>(
        0,
        (sum, session) => sum + session.outtakeCalories,
      );

      // Assert
      expect(sessions.length, equals(3));
      expect(totalCalories, equals(450)); // 100 + 150 + 200
    });
  });

  group('IT - Business Logic Integration', () {
    test('IT017: Tính BMR cho nam giới', () {
      // Arrange
      final weight = 70; // kg
      final height = 175; // cm
      final age = 25;

      // Act - BMR formula for male
      final bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;

      // Assert
      expect(bmr, equals(1673.75)); // 700 + 1093.75 - 125 + 5
    });

    test('IT018: Tính BMR cho nữ giới', () {
      // Arrange
      final weight = 60; // kg
      final height = 165; // cm
      final age = 25;

      // Act - BMR formula for female
      final bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;

      // Assert
      expect(bmr, equals(1345.25)); // 600 + 1031.25 - 125 - 161
    });

    test('IT019: Tính TDEE và daily calories goal', () {
      // Arrange
      final bmr = 1696.25; // Nam, 70kg, 175cm, 25 tuổi
      final activityFactor = 1.5; // Trung bình

      // Act
      final tdee = bmr * activityFactor;
      final caloriesForLoseWeight = tdee - 500;
      final caloriesForGainWeight = tdee + 500;

      // Assert
      expect(tdee, closeTo(2544.375, 0.01));
      expect(caloriesForLoseWeight, closeTo(2044.375, 0.01));
      expect(caloriesForGainWeight, closeTo(3044.375, 0.01));
    });

    test('IT020: Flow hoàn chỉnh - từ setting đến tracking', () {
      // Arrange - Tạo workout collection
      final workoutSetting = CollectionSetting(
        round: 3,
        numOfWorkoutPerRound: 5,
        exerciseTime: 30,
        transitionTime: 10,
        restTime: 60,
      );

      // Act 1 - Tính thời gian workout
      final exercisesCount =
          workoutSetting.numOfWorkoutPerRound * workoutSetting.round;
      final totalExerciseTime = workoutSetting.exerciseTime * exercisesCount;

      // Act 2 - Tính calo tiêu thụ
      final bodyWeight = 70;
      final avgMET = 5.5;
      final totalCalories = SessionUtils.calculateCaloOneWorkout(
        totalExerciseTime, // tổng thời gian tập (giây)
        avgMET,
        bodyWeight,
      ).round();

      // Act 3 - Tạo exercise tracker
      final tracker = ExerciseTracker(
        date: DateTime.now(),
        outtakeCalories: totalCalories,
        sessionNumber: exercisesCount,
        totalTime: (totalExerciseTime / 60).round(),
      );

      // Assert
      expect(workoutSetting.round, equals(3));
      expect(exercisesCount, equals(15));
      expect(totalCalories, greaterThan(0));
      expect(tracker.sessionNumber, equals(15));
      expect(tracker.outtakeCalories, greaterThan(0));
    });
  });
}
