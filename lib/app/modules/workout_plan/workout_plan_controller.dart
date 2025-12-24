import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vipt/app/core/values/colors.dart';
import 'package:vipt/app/data/models/collection_setting.dart';
import 'package:vipt/app/data/models/exercise_tracker.dart';
import 'package:vipt/app/data/models/meal_nutrition.dart';
import 'package:vipt/app/data/models/meal_nutrition_tracker.dart';
import 'package:vipt/app/data/models/plan_exercise.dart';
import 'package:vipt/app/data/models/plan_exercise_collection_setting.dart';
import 'package:vipt/app/data/models/plan_meal.dart';
import 'package:vipt/app/data/models/plan_meal_collection.dart';
import 'package:vipt/app/data/models/streak.dart';
import 'package:vipt/app/data/models/weight_tracker.dart';
import 'package:vipt/app/data/models/workout_collection.dart';
import 'package:vipt/app/data/models/workout_plan.dart';
import 'package:vipt/app/data/models/plan_exercise_collection.dart';
import 'package:vipt/app/data/others/tab_refesh_controller.dart';
import 'package:vipt/app/data/providers/exercise_nutrition_route_provider.dart';
import 'package:vipt/app/data/providers/exercise_track_provider.dart';
import 'package:vipt/app/data/providers/meal_nutrition_track_provider.dart';
import 'package:vipt/app/data/providers/meal_provider.dart';
import 'package:vipt/app/data/providers/plan_exercise_collection_setting_provider.dart';
import 'package:vipt/app/data/providers/plan_exercise_provider.dart';
import 'package:vipt/app/data/providers/plan_meal_collection_provider.dart';
import 'package:vipt/app/data/providers/plan_meal_provider.dart';
import 'package:vipt/app/data/providers/streak_provider.dart';
import 'package:vipt/app/data/providers/user_provider.dart';
import 'package:vipt/app/data/providers/weight_tracker_provider.dart';
import 'package:vipt/app/data/providers/plan_exercise_collection_provider.dart';
import 'package:vipt/app/data/providers/workout_plan_provider.dart';
import 'package:vipt/app/data/services/data_service.dart';
import 'package:vipt/app/enums/app_enums.dart';
import 'package:vipt/app/global_widgets/custom_confirmation_dialog.dart';
import 'package:vipt/app/routes/pages.dart';

class WorkoutPlanController extends GetxController {
  static const num defaultWeightValue = 0;
  static const WeightUnit defaultWeightUnit = WeightUnit.kg;
  static const int defaultCaloriesValue = 0;

  // --------------- LOG WEIGHT --------------------------------

  final _weighTrackProvider = WeightTrackerProvider();
  final _userProvider = UserProvider();
  Rx<num> currentWeight = defaultWeightValue.obs;
  Rx<num> goalWeight = defaultWeightValue.obs;
  WeightUnit weightUnit = defaultWeightUnit;

  String get unit => weightUnit == WeightUnit.kg ? 'kg' : 'lbs';

  Future<void> loadWeightValues() async {
    final _userInfo = DataService.currentUser;
    if (_userInfo == null) {
      return;
    }

    currentWeight.value = _userInfo.currentWeight;
    goalWeight.value = _userInfo.goalWeight;
    weightUnit = _userInfo.weightUnit;
  }

  Future<void> logWeight(String newWeightStr) async {
    int? newWeight = int.tryParse(newWeightStr);
    if (newWeight == null) {
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return CustomConfirmationDialog(
            icon: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.error_rounded,
                  color: AppColor.errorColor, size: 48),
            ),
            label: 'Đã xảy ra lỗi',
            content: 'Giá trị cân nặng không đúng định dạng',
            showOkButton: false,
            labelCancel: 'Đóng',
            onCancel: () {
              Navigator.of(context).pop();
            },
            buttonsAlignment: MainAxisAlignment.center,
            buttonFactorOnMaxWidth: double.infinity,
          );
        },
      );
      return;
    }

    currentWeight.value = newWeight;

    await _weighTrackProvider
        .add(WeightTracker(date: DateTime.now(), weight: newWeight));

    final _userInfo = DataService.currentUser;
    if (_userInfo != null) {
      _userInfo.currentWeight = newWeight;
      await _userProvider.update(_userInfo.id ?? '', _userInfo);
    }

    _markRelevantTabToUpdate();
  }

  // --------------- WORKOUT + MEAL PLAN --------------------------------
  final _nutriTrackProvider = MealNutritionTrackProvider();
  final _exerciseTrackProvider = ExerciseTrackProvider();
  final _workoutPlanProvider = WorkoutPlanProvider();
  final _wkExerciseCollectionProvider = PlanExerciseCollectionProvider();
  final _wkExerciseProvider = PlanExerciseProvider();
  final _colSettingProvider = PlanExerciseCollectionSettingProvider();
  final _wkMealCollectionProvider = PlanMealCollectionProvider();
  final _wkMealProvider = PlanMealProvider();

  RxBool isLoading = false.obs;

  RxInt intakeCalories = defaultCaloriesValue.obs;
  RxInt outtakeCalories = defaultCaloriesValue.obs;
  RxInt get dailyDiffCalories =>
      (intakeCalories.value - outtakeCalories.value).obs;
  RxInt dailyGoalCalories = defaultCaloriesValue.obs;

  // Chuyển thành RxList để UI tự động rebuild khi có thay đổi
  final RxList<PlanExerciseCollection> planExerciseCollection =
      <PlanExerciseCollection>[].obs;
  List<PlanExercise> planExercise = <PlanExercise>[];
  List<PlanExerciseCollectionSetting> collectionSetting =
      <PlanExerciseCollectionSetting>[];

  final RxList<PlanMealCollection> planMealCollection =
      <PlanMealCollection>[].obs;
  List<PlanMeal> planMeal = [];

  final Rx<WorkoutPlan?> currentWorkoutPlan = Rx<WorkoutPlan?>(null);

  RxBool isAllMealListLoading = false.obs;
  RxBool isTodayMealListLoading = false.obs;

  // Stream subscriptions cho real-time updates
  StreamSubscription<List<PlanExerciseCollection>>?
      _exerciseCollectionSubscription;
  StreamSubscription<List<PlanMealCollection>>? _mealCollectionSubscription;

  Future<void> loadDailyGoalCalories() async {
    WorkoutPlan? list = await _workoutPlanProvider
        .fetchByUserID(DataService.currentUser!.id ?? '');
    if (list != null) {
      currentWorkoutPlan.value = list;
      dailyGoalCalories.value = list.dailyGoalCalories.toInt();
    }
  }

  Future<void> loadPlanExerciseCollectionList(int planID) async {
    // Nếu planID = 0, chỉ load default collections
    if (planID == 0) {
      List<PlanExerciseCollection> defaultCollections =
          await _wkExerciseCollectionProvider.fetchByPlanID(0);

      if (defaultCollections.isNotEmpty) {
        defaultCollections.sort((a, b) => a.date.compareTo(b.date));
        planExerciseCollection.assignAll(defaultCollections);

        planExercise.clear();
        collectionSetting.clear();

        for (int i = 0; i < defaultCollections.length; i++) {
          await loadCollectionSetting(
              defaultCollections[i].collectionSettingID);
          if (defaultCollections[i].id != null &&
              defaultCollections[i].id!.isNotEmpty) {
            await loadPlanExerciseList(defaultCollections[i].id!);
          }
        }
      }
    } else {
      // Nếu có user plan, chỉ load user collections
      List<PlanExerciseCollection> userCollections =
          await _wkExerciseCollectionProvider.fetchByPlanID(planID);

      if (userCollections.isNotEmpty) {
        // Sắp xếp theo ngày
        userCollections.sort((a, b) => a.date.compareTo(b.date));
        planExerciseCollection.assignAll(userCollections);

        planExercise.clear();
        collectionSetting.clear();

        for (int i = 0; i < userCollections.length; i++) {
          await loadCollectionSetting(userCollections[i].collectionSettingID);
          if (userCollections[i].id != null &&
              userCollections[i].id!.isNotEmpty) {
            await loadPlanExerciseList(userCollections[i].id!);
          }
        }
      } else {
        // Nếu user plan không có collections, fallback về default
        List<PlanExerciseCollection> defaultCollections =
            await _wkExerciseCollectionProvider.fetchByPlanID(0);

        if (defaultCollections.isNotEmpty) {
          defaultCollections.sort((a, b) => a.date.compareTo(b.date));
          planExerciseCollection.assignAll(defaultCollections);

          planExercise.clear();
          collectionSetting.clear();

          for (int i = 0; i < defaultCollections.length; i++) {
            await loadCollectionSetting(
                defaultCollections[i].collectionSettingID);
            if (defaultCollections[i].id != null &&
                defaultCollections[i].id!.isNotEmpty) {
              await loadPlanExerciseList(defaultCollections[i].id!);
            }
          }
        }
      }
    }
  }

  Future<void> loadPlanExerciseList(String listID) async {
    planExercise.removeWhere((element) => element.listID == listID);
    List<PlanExercise> _list = await _wkExerciseProvider.fetchByListID(listID);
    if (_list.isNotEmpty) {
      planExercise.addAll(_list);
    }
  }

  Future<void> loadCollectionSetting(String id) async {
    var _list = await _colSettingProvider.fetch(id);
    collectionSetting.add(_list);
  }

  Future<void> loadDailyCalories() async {
    final date = DateTime.now();
    final List<MealNutritionTracker> tracks =
        await _nutriTrackProvider.fetchByDate(date);
    final List<ExerciseTracker> exerciseTracks =
        await _exerciseTrackProvider.fetchByDate(date);

    outtakeCalories.value = 0;
    exerciseTracks.map((e) {
      outtakeCalories.value += e.outtakeCalories;
    }).toList();

    intakeCalories.value = 0;
    dailyDiffCalories.value = 0;

    tracks.map((e) {
      intakeCalories.value += e.intakeCalories;
    }).toList();

    dailyDiffCalories.value = intakeCalories.value - outtakeCalories.value;
    await _validateDailyCalories();
  }

  Future<void> _validateDailyCalories() async {
    if (currentWorkoutPlan.value == null) {
      return;
    }

    DateTime dateKey = DateUtils.dateOnly(DateTime.now());
    final _streakProvider = StreakProvider();
    List<Streak> streakList = await _streakProvider.fetchByDate(dateKey);
    if (streakList.isNotEmpty) {
      // Tìm streak với planID khớp, có thể không tìm thấy
      var matchingStreaks = streakList
          .where((element) => element.planID == currentWorkoutPlan.value!.id)
          .toList();

      if (matchingStreaks.isEmpty) {
        return;
      }

      Streak todayStreak = matchingStreaks.first;
      bool todayStreakValue = todayStreak.value;

      if (dailyDiffCalories.value >= dailyGoalCalories.value - 100 &&
          dailyDiffCalories.value <= dailyGoalCalories.value + 100) {
        if (!todayStreakValue) {
          Streak newStreak = Streak(
              date: todayStreak.date, planID: todayStreak.planID, value: true);
          await _streakProvider.update(todayStreak.id ?? 0, newStreak);
        }
      } else {
        if (todayStreakValue) {
          Streak newStreak = Streak(
              date: todayStreak.date, planID: todayStreak.planID, value: false);
          await _streakProvider.update(todayStreak.id ?? 0, newStreak);
        }
      }
    }
  }

  List<WorkoutCollection> loadAllWorkoutCollection() {
    var collection = planExerciseCollection.toList();

    if (collection.isNotEmpty) {
      // Nhóm collections theo ngày
      Map<DateTime, List<PlanExerciseCollection>> collectionsByDate = {};
      for (var col in collection) {
        final dateKey = DateUtils.dateOnly(col.date);
        if (!collectionsByDate.containsKey(dateKey)) {
          collectionsByDate[dateKey] = [];
        }
        collectionsByDate[dateKey]!.add(col);
      }

      // Tạo danh sách WorkoutCollection theo thứ tự ngày
      List<WorkoutCollection> result = [];
      final sortedDates = collectionsByDate.keys.toList()..sort();

      for (var date in sortedDates) {
        final dayCollections = collectionsByDate[date]!;
        for (int i = 0; i < dayCollections.length; i++) {
          final col = dayCollections[i];
          List<PlanExercise> exerciseList =
              planExercise.where((p0) => p0.listID == col.id).toList();

          result.add(WorkoutCollection(col.id ?? '',
              title: 'Bài tập thứ ${i + 1}',
              description: '',
              asset: '',
              generatorIDs: exerciseList.map((e) => e.exerciseID).toList(),
              categoryIDs: []));
        }
      }

      return result;
    }
    return <WorkoutCollection>[];
  }

  List<WorkoutCollection> loadWorkoutCollectionToShow(DateTime date) {
    var collection = planExerciseCollection
        .where((element) => DateUtils.isSameDay(element.date, date))
        .toList();

    if (collection.isNotEmpty) {
      return collection.map((col) {
        List<PlanExercise> exerciseList =
            planExercise.where((p0) => p0.listID == col.id).toList();
        int index = collection.indexOf(col);

        return WorkoutCollection(col.id ?? '',
            title: 'Bài tập thứ ${index + 1}',
            description: '',
            asset: '',
            generatorIDs: exerciseList.map((e) => e.exerciseID).toList(),
            categoryIDs: []);
      }).toList();
    }

    return <WorkoutCollection>[];
  }

  Future<CollectionSetting?> getCollectionSetting(
      String workoutCollectionID) async {
    print(
        '🔍 getCollectionSetting: Tìm collection setting cho workoutCollectionID = $workoutCollectionID');

    PlanExerciseCollection? selected = planExerciseCollection
        .firstWhereOrNull((p0) => p0.id == workoutCollectionID);

    if (selected == null) {
      print(
          '❌ getCollectionSetting: Không tìm thấy PlanExerciseCollection với ID = $workoutCollectionID');
      print(
          '📋 getCollectionSetting: planExerciseCollection có ${planExerciseCollection.length} items');
      return null;
    }

    print(
        '✅ getCollectionSetting: Tìm thấy PlanExerciseCollection, collectionSettingID = ${selected.collectionSettingID}');

    // Tìm trong list hiện tại
    PlanExerciseCollectionSetting? setting = collectionSetting.firstWhereOrNull(
        (element) => element.id == selected.collectionSettingID);

    if (setting != null) {
      print('✅ getCollectionSetting: Tìm thấy setting trong list');
      return setting;
    }

    // Nếu không tìm thấy, thử load lại từ Firestore
    print(
        '⚠️ getCollectionSetting: Không tìm thấy setting trong list, đang load từ Firestore...');
    try {
      await loadCollectionSetting(selected.collectionSettingID);
      setting = collectionSetting.firstWhereOrNull(
          (element) => element.id == selected.collectionSettingID);

      if (setting != null) {
        print(
            '✅ getCollectionSetting: Đã load setting từ Firestore thành công');
        return setting;
      } else {
        print(
            '❌ getCollectionSetting: Vẫn không tìm thấy setting sau khi load từ Firestore');
        print(
            '📋 getCollectionSetting: collectionSetting có ${collectionSetting.length} items');
        print(
            '📋 getCollectionSetting: Các ID trong collectionSetting: ${collectionSetting.map((e) => e.id).toList()}');
      }
    } catch (e) {
      print('❌ getCollectionSetting: Lỗi khi load setting từ Firestore: $e');
    }

    return null;
  }

  Future<void> loadWorkoutPlanMealList(int planID) async {
    // Nếu planID = 0, chỉ load default collections
    if (planID == 0) {
      List<PlanMealCollection> defaultCollections =
          await _wkMealCollectionProvider.fetchByPlanID(0);

      if (defaultCollections.isNotEmpty) {
        defaultCollections.sort((a, b) => a.date.compareTo(b.date));
        planMealCollection.assignAll(defaultCollections);

        planMeal.clear();

        for (int i = 0; i < defaultCollections.length; i++) {
          if (defaultCollections[i].id != null &&
              defaultCollections[i].id!.isNotEmpty) {
            await loadPlanMealList(defaultCollections[i].id!);
          }
        }

        update();
      }
    } else {
      // Nếu có user plan, chỉ load user collections
      List<PlanMealCollection> userCollections =
          await _wkMealCollectionProvider.fetchByPlanID(planID);

      if (userCollections.isNotEmpty) {
        // Sắp xếp theo ngày
        userCollections.sort((a, b) => a.date.compareTo(b.date));
        planMealCollection.assignAll(userCollections);

        planMeal.clear();

        for (int i = 0; i < userCollections.length; i++) {
          if (userCollections[i].id != null &&
              userCollections[i].id!.isNotEmpty) {
            await loadPlanMealList(userCollections[i].id!);
          }
        }

        update();
      } else {
        // Nếu user plan không có collections, fallback về default
        List<PlanMealCollection> defaultCollections =
            await _wkMealCollectionProvider.fetchByPlanID(0);

        if (defaultCollections.isNotEmpty) {
          defaultCollections.sort((a, b) => a.date.compareTo(b.date));
          planMealCollection.assignAll(defaultCollections);

          planMeal.clear();

          for (int i = 0; i < defaultCollections.length; i++) {
            if (defaultCollections[i].id != null &&
                defaultCollections[i].id!.isNotEmpty) {
              await loadPlanMealList(defaultCollections[i].id!);
            }
          }

          update();
        }
      }
    }
  }

  Future<void> loadPlanMealList(String listID) async {
    List<PlanMeal> _list = await _wkMealProvider.fetchByListID(listID);
    if (_list.isNotEmpty) {
      planMeal.addAll(_list);
    }
  }

  Future<List<MealNutrition>> loadMealListToShow(DateTime date) async {
    isTodayMealListLoading.value = true;
    final firebaseMealProvider = MealProvider();
    var collection = planMealCollection
        .where((element) => DateUtils.isSameDay(element.date, date));
    if (collection.isEmpty) {
      isTodayMealListLoading.value = false;
      return [];
    } else {
      List<PlanMeal> _list = planMeal
          .where((element) => element.listID == (collection.first.id ?? ''))
          .toList();
      List<MealNutrition> mealList = [];
      for (var element in _list) {
        var m = await firebaseMealProvider.fetch(element.mealID);
        MealNutrition mn = MealNutrition(meal: m);
        await mn.getIngredients();
        mealList.add(mn);
      }

      isTodayMealListLoading.value = false;
      return mealList;
    }
  }

  Future<List<MealNutrition>> loadAllMealList() async {
    try {
      isAllMealListLoading.value = true;
      final firebaseMealProvider = MealProvider();

      if (planMealCollection.isEmpty && currentWorkoutPlan.value != null) {
        await loadWorkoutPlanMealList(currentWorkoutPlan.value!.id ?? 0);
      }

      var collection = planMealCollection.toList();

      if (collection.isEmpty) {
        isAllMealListLoading.value = false;
        return [];
      } else {
        List<MealNutrition> mealList = [];

        for (var mealCollection in collection) {
          List<PlanMeal> _list = planMeal
              .where((element) => element.listID == (mealCollection.id ?? ''))
              .toList();

          List<Future<MealNutrition?>> mealFutures = _list.map((element) async {
            try {
              var m = await firebaseMealProvider.fetch(element.mealID);
              MealNutrition mn = MealNutrition(meal: m);
              await mn.getIngredients();
              return mn;
            } catch (e) {
              if (e.toString().contains('permission-denied')) {
                return null;
              }
              return null;
            }
          }).toList();

          try {
            List<MealNutrition?> collectionMeals =
                await Future.wait(mealFutures);
            mealList.addAll(collectionMeals.whereType<MealNutrition>());
          } catch (e) {}
        }

        isAllMealListLoading.value = false;
        return mealList;
      }
    } catch (e) {
      isAllMealListLoading.value = false;
      return [];
    }
  }

  // --------------- STREAK --------------------------------
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  List<bool> planStreak = [];
  RxInt currentStreakDay = 0.obs;
  static const String planStatus = 'planStatus';

  final _routeProvider = ExerciseNutritionRouteProvider();

  Future<void> loadPlanStreak() async {
    planStreak.clear();

    if (currentWorkoutPlan.value == null) {
      return;
    }

    Map<int, List<bool>> list = await _routeProvider.loadStreakList();
    if (list.isNotEmpty) {
      currentStreakDay.value = list.keys.first;
      planStreak.addAll(list.values.first);
    } else {
      return;
    }
    if (DateTime.now().isAfter(currentWorkoutPlan.value!.endDate)) {
      hasFinishedPlan.value = true;
      final _prefs = await prefs;
      _prefs.setBool(planStatus, true);

      await loadDataForFinishScreen();
      await Get.toNamed(Routes.finishPlanScreen);
    }
  }

  Future<void> loadPlanStatus() async {
    final _prefs = await prefs;
    hasFinishedPlan.value = _prefs.getBool(planStatus) ?? false;
  }

  Future<void> showNotFoundStreakDataDialog() async {
    await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return CustomConfirmationDialog(
          icon: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child:
                Icon(Icons.error_rounded, color: AppColor.errorColor, size: 48),
          ),
          label: 'Đã xảy ra lỗi',
          content: 'Không tìm thấy danh sách streak',
          showOkButton: false,
          labelCancel: 'Đóng',
          onCancel: () {
            Navigator.of(context).pop();
          },
          buttonsAlignment: MainAxisAlignment.center,
          buttonFactorOnMaxWidth: double.infinity,
        );
      },
    );
  }

  Future<void> resetStreakList() async {
    isLoading.value = true;
    await _routeProvider.resetRoute();
    isLoading.value = false;
  }

  // --------------- FINISH WORKOUT PLAN--------------------------------
  static final DateTimeRange defaultWeightDateRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  Rx<DateTimeRange> weightDateRange = defaultWeightDateRange.obs;
  RxList<WeightTracker> allWeightTracks = <WeightTracker>[].obs;
  final _weightProvider = WeightTrackerProvider();

  RxBool hasFinishedPlan = false.obs;

  Map<DateTime, double> get weightTrackList {
    allWeightTracks.sort((x, y) {
      return x.date.compareTo(y.date);
    });

    return allWeightTracks.length == 1 ? fakeMap() : convertToMap();
  }

  Map<DateTime, double> convertToMap() {
    return {for (var e in allWeightTracks) e.date: e.weight.toDouble()};
  }

  Map<DateTime, double> fakeMap() {
    var map = convertToMap();

    map.addAll(
        {allWeightTracks.first.date.subtract(const Duration(days: 1)): 0});

    return map;
  }

  Future<void> loadWeightTracks() async {
    if (currentWorkoutPlan.value == null) {
      return;
    }

    weightDateRange.value = DateTimeRange(
        start: currentWorkoutPlan.value!.startDate,
        end: currentWorkoutPlan.value!.endDate);
    allWeightTracks.clear();
    int duration = weightDateRange.value.duration.inDays + 1;
    for (int i = 0; i < duration; i++) {
      DateTime fetchDate = weightDateRange.value.start.add(Duration(days: i));
      var weighTracks = await _weightProvider.fetchByDate(fetchDate);
      weighTracks.sort((x, y) => x.weight - y.weight);
      if (weighTracks.isNotEmpty) {
        allWeightTracks.add(weighTracks.last);
      }
    }
  }

  Future<void> changeWeighDateRange(
      DateTime startDate, DateTime endDate) async {
    if (startDate.day == endDate.day &&
        startDate.month == endDate.month &&
        startDate.year == endDate.year) {
      startDate = startDate.subtract(const Duration(days: 1));
    }
    weightDateRange.value = DateTimeRange(start: startDate, end: endDate);
    await loadWeightTracks();
  }

  Future<void> loadDataForFinishScreen() async {
    await loadWeightTracks();
  }

  @override
  void onInit() async {
    super.onInit();
    isLoading.value = true;
    await loadPlanStatus();
    await loadWeightValues();
    await loadDailyGoalCalories();

    if (currentWorkoutPlan.value != null) {
      await loadDailyCalories();
      await loadPlanExerciseCollectionList(currentWorkoutPlan.value!.id ?? 0);
      await loadWorkoutPlanMealList(currentWorkoutPlan.value!.id ?? 0);
      await loadPlanStreak();
    } else {
      await loadDailyCalories();
      // Load default collections ngay cả khi không có user plan
      await loadPlanExerciseCollectionList(0);
      await loadWorkoutPlanMealList(0);
    }

    isLoading.value = false;

    // Bắt đầu lắng nghe real-time changes từ Firestore
    _setupRealtimeListeners();
  }

  /// Thiết lập listeners để lắng nghe thay đổi real-time từ Firestore
  void _setupRealtimeListeners() {
    // Cancel old subscriptions nếu có
    _exerciseCollectionSubscription?.cancel();
    _mealCollectionSubscription?.cancel();

    int planID = currentWorkoutPlan.value?.id ?? 0;

    // Lắng nghe thay đổi plan exercise collections
    _exerciseCollectionSubscription =
        _wkExerciseCollectionProvider.streamByPlanID(planID).listen(
      (collections) {
        // Reload khi có thay đổi từ admin
        _reloadExerciseCollections();
      },
      onError: (error) {
        // Ignore errors, continue listening
      },
    );

    // Lắng nghe thay đổi plan meal collections
    _mealCollectionSubscription =
        _wkMealCollectionProvider.streamByPlanID(planID).listen(
      (collections) {
        // Reload khi có thay đổi từ admin
        _reloadMealCollections();
      },
      onError: (error) {
        // Ignore errors, continue listening
      },
    );

    // Cũng lắng nghe default plan (planID = 0) để cập nhật khi admin thay đổi
    if (planID != 0) {
      _wkExerciseCollectionProvider.streamByPlanID(0).listen(
        (collections) {
          // Nếu user plan không có collections, reload default
          if (planExerciseCollection.isEmpty) {
            _reloadExerciseCollections();
          }
        },
        onError: (error) {},
      );

      _wkMealCollectionProvider.streamByPlanID(0).listen(
        (collections) {
          // Nếu user plan không có collections, reload default
          if (planMealCollection.isEmpty) {
            _reloadMealCollections();
          }
        },
        onError: (error) {},
      );
    }
  }

  /// Reload exercise collections khi có thay đổi từ Firestore
  Future<void> _reloadExerciseCollections() async {
    int planID = currentWorkoutPlan.value?.id ?? 0;
    await loadPlanExerciseCollectionList(planID);
    // Trigger UI update
    update();
  }

  /// Reload meal collections khi có thay đổi từ Firestore
  Future<void> _reloadMealCollections() async {
    int planID = currentWorkoutPlan.value?.id ?? 0;
    await loadWorkoutPlanMealList(planID);
    // Trigger UI update
    update();
  }

  @override
  void onClose() {
    // Cancel tất cả subscriptions khi controller bị dispose
    _exerciseCollectionSubscription?.cancel();
    _mealCollectionSubscription?.cancel();
    super.onClose();
  }

  void _markRelevantTabToUpdate() {
    if (!RefeshTabController.instance.isProfileTabNeedToUpdate) {
      RefeshTabController.instance.toggleProfileTabUpdate();
    }
  }
}
