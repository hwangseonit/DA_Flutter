import 'package:flutter_test/flutter_test.dart';
import 'package:vipt/app/data/models/exercise_tracker.dart';
import 'package:vipt/app/data/models/collection_setting.dart';

/// Unit Tests cho Models (Data Models) - Version đơn giản
/// Phục vụ cho báo cáo: Chương 5.1 - Unit Test
void main() {
  group('ExerciseTracker - Model test', () {
    test('Tạo ExerciseTracker từ constructor', () {
      final tracker = ExerciseTracker(
        id: 1,
        date: DateTime(2024, 1, 15),
        outtakeCalories: 250,
        sessionNumber: 5,
        totalTime: 45,
        userID: 'user123',
      );

      expect(tracker.id, equals(1));
      expect(tracker.date, equals(DateTime(2024, 1, 15)));
      expect(tracker.outtakeCalories, equals(250));
      expect(tracker.sessionNumber, equals(5));
      expect(tracker.totalTime, equals(45));
      expect(tracker.userID, equals('user123'));
    });

    test('Chuyển ExerciseTracker thành Map (toMap)', () {
      final tracker = ExerciseTracker(
        id: 2,
        date: DateTime(2024, 1, 16),
        outtakeCalories: 300,
        sessionNumber: 6,
        totalTime: 50,
        userID: 'user456',
      );

      final map = tracker.toMap();
      
      expect(map['id'], equals(2));
      expect(map['date'], isNotNull);
      expect(map['outtakeCalories'], equals(300));
      expect(map['sessionNumber'], equals(6));
      expect(map['totalTime'], equals(50));
      expect(map['userID'], equals('user456'));
    });

    test('Tạo ExerciseTracker từ Map (fromMap)', () {
      final map = {
        'id': 3,
        'date': '2024-01-17 10:00:00.000',
        'outtakeCalories': 280,
        'sessionNumber': 7,
        'totalTime': 40,
        'userID': 'user789',
      };

      final tracker = ExerciseTracker.fromMap(map);
      
      expect(tracker.id, equals(3));
      expect(tracker.outtakeCalories, equals(280));
      expect(tracker.sessionNumber, equals(7));
      expect(tracker.totalTime, equals(40));
    });

    test('ExerciseTracker với giá trị mặc định khi fromMap', () {
      final map = {
        'id': 4,
        'date': '2024-01-18 10:00:00.000',
        // Thiếu một số field
      };

      final tracker = ExerciseTracker.fromMap(map);
      
      expect(tracker.id, equals(4));
      expect(tracker.outtakeCalories, equals(0)); // Default
      expect(tracker.sessionNumber, equals(0)); // Default
      expect(tracker.totalTime, equals(0)); // Default
    });

    test('Cập nhật ExerciseTracker', () {
      final tracker = ExerciseTracker(
        id: 5,
        date: DateTime(2024, 1, 19),
        outtakeCalories: 200,
        sessionNumber: 3,
        totalTime: 30,
      );

      // Cập nhật giá trị
      tracker.outtakeCalories = 350;
      tracker.sessionNumber = 8;
      tracker.totalTime = 60;

      expect(tracker.outtakeCalories, equals(350));
      expect(tracker.sessionNumber, equals(8));
      expect(tracker.totalTime, equals(60));
    });
  });

  group('CollectionSetting - Model test', () {
    test('Tạo CollectionSetting với giá trị mặc định', () {
      final setting = CollectionSetting();

      expect(setting.round, equals(3));
      expect(setting.numOfWorkoutPerRound, equals(5));
      expect(setting.isStartWithWarmUp, equals(true));
      expect(setting.isShuffle, equals(true));
      expect(setting.exerciseTime, equals(10));
      expect(setting.transitionTime, equals(10));
      expect(setting.restTime, equals(10));
      expect(setting.restFrequency, equals(10));
    });

    test('Tạo CollectionSetting với các tham số custom', () {
      final setting = CollectionSetting(
        round: 5,
        numOfWorkoutPerRound: 8,
        exerciseTime: 15,
        transitionTime: 5,
        restTime: 20,
        restFrequency: 3,
        isStartWithWarmUp: false,
        isShuffle: false,
      );

      expect(setting.round, equals(5));
      expect(setting.numOfWorkoutPerRound, equals(8));
      expect(setting.exerciseTime, equals(15));
      expect(setting.transitionTime, equals(5));
      expect(setting.restTime, equals(20));
      expect(setting.restFrequency, equals(3));
      expect(setting.isStartWithWarmUp, equals(false));
      expect(setting.isShuffle, equals(false));
    });

    test('Tính tổng thời gian tập luyện', () {
      final setting = CollectionSetting(
        round: 3,
        numOfWorkoutPerRound: 5,
        exerciseTime: 10,
        transitionTime: 5,
        restTime: 30,
        restFrequency: 5,
      );

      // Tổng thời gian = (exerciseTime * số bài tập) + (transitionTime * số bài tập) + (restTime * số lần nghỉ)
      // = (10 * 15) + (5 * 15) + (30 * 3)
      int totalExerciseTime = setting.exerciseTime * setting.numOfWorkoutPerRound * setting.round;
      int totalTransitionTime = setting.transitionTime * setting.numOfWorkoutPerRound * setting.round;
      
      expect(totalExerciseTime, equals(150)); // 10 * 5 * 3 = 150 giây
      expect(totalTransitionTime, equals(75)); // 5 * 5 * 3 = 75 giây
    });

    test('CollectionSetting - Kiểm tra chế độ Shuffle', () {
      final setting1 = CollectionSetting(isShuffle: true);
      final setting2 = CollectionSetting(isShuffle: false);

      expect(setting1.isShuffle, equals(true));
      expect(setting2.isShuffle, equals(false));
      expect(setting1.isShuffle, isNot(equals(setting2.isShuffle)));
    });

    test('CollectionSetting - Kiểm tra Warm Up', () {
      final withWarmUp = CollectionSetting(isStartWithWarmUp: true);
      final withoutWarmUp = CollectionSetting(isStartWithWarmUp: false);

      expect(withWarmUp.isStartWithWarmUp, equals(true));
      expect(withoutWarmUp.isStartWithWarmUp, equals(false));
    });

    test('CollectionSetting - Clone/Copy từ instance khác', () {
      final original = CollectionSetting(
        round: 4,
        numOfWorkoutPerRound: 6,
        exerciseTime: 12,
      );

      final copied = CollectionSetting.fromCollectionSetting(original);

      expect(copied.round, equals(original.round));
      expect(copied.numOfWorkoutPerRound, equals(original.numOfWorkoutPerRound));
      expect(copied.exerciseTime, equals(original.exerciseTime));
    });
  });
}
