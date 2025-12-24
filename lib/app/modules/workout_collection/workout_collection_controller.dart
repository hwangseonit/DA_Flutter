import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vipt/app/core/utilities/utils.dart';
import 'package:vipt/app/core/values/colors.dart';
import 'package:vipt/app/data/models/category.dart';
import 'package:vipt/app/data/models/collection_setting.dart';
import 'package:vipt/app/data/models/workout.dart';
import 'package:vipt/app/data/models/workout_collection.dart';
import 'package:vipt/app/data/models/workout_collection_category.dart';
import 'package:vipt/app/data/providers/workout_collection_provider.dart';
import 'package:vipt/app/data/providers/workout_collection_setting_provider.dart';
import 'package:vipt/app/data/providers/workout_provider.dart';
import 'package:vipt/app/data/services/data_service.dart';
import 'package:vipt/app/global_widgets/custom_confirmation_dialog.dart';
import 'package:vipt/app/routes/pages.dart';

class WorkoutCollectionController extends GetxController {
  // Reactive loading state
  final RxBool isRefreshing = false.obs;

  // property
  // list chứa tất cả các collection - Reactive
  final RxList<WorkoutCollection> collections = <WorkoutCollection>[].obs;
  // list chứa tất cả các category của các collection - Reactive
  final RxList<WorkoutCollectionCategory> collectionCategories =
      <WorkoutCollectionCategory>[].obs;
  // map chứa danh sách các cate và các collection tương ứng
  // late Map<String, int> cateListAndNumCollection;
  // collection setting của collection được chọn
  Rx<CollectionSetting> collectionSetting = CollectionSetting().obs;

  WorkoutCollectionCategory workoutCollectionTree = WorkoutCollectionCategory();

  // Lưu lại category đang được xem để refresh khi data thay đổi
  Category? _currentViewingCategory;

  // giá trị calo và value của collection được chọn
  Rx<double> caloValue = 0.0.obs;
  Rx<double> timeValue = 0.0.obs;

  // list collection của user tự tạo
  List<WorkoutCollection> userCollections = [];

  // collection được chọn
  WorkoutCollection? selectedCollection;

  // biến để phân biệt user collection hay default collection
  bool isDefaultCollection = false;

  // danh sách workout của collection được chọn
  List<Workout> workoutList = [];
  // danh sách workout được tạo ra dựa trên collection setting từ workoutList
  List<Workout> generatedWorkoutList = [];
  // biến ràng buộc dùng trong collectionSetting
  Rx<int> maxWorkout = 100.obs;

  Rx<String> displayTime = ''.obs;

  bool useDefaulColSetting = true;

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    selectedCollection = null;
    super.onInit();
    _initializeData();
    _setupRealtimeListeners();

    ever(collectionSetting, (_) {
      calculateCaloAndTime();
    });
  }

  void _setupRealtimeListeners() {
    ever(DataService.instance.collectionListRx, (_) {
      _rebuildAllData();
    });

    ever(DataService.instance.collectionCateListRx, (_) {
      _rebuildAllData();
    });

    ever(DataService.instance.userCollectionListRx, (_) {
      loadUserCollections();
    });

    ever(DataService.instance.workoutListRx, (_) {
      _rebuildAllData();
    });
  }

  void _rebuildAllData() {
    initWorkoutCollectionTree();
    loadCollectionCategories();

    if (_currentViewingCategory != null) {
      _refreshCurrentCollectionList();
    }
  }

  void _refreshCurrentCollectionList() {
    if (_currentViewingCategory == null) return;

    try {
      final component = workoutCollectionTree.searchComponent(
          _currentViewingCategory!.id ?? '', workoutCollectionTree.components);
      if (component != null) {
        collections
            .assignAll(List<WorkoutCollection>.from(component.getList()));
      }
    } catch (e) {}
  }

  Future<void> _initializeData() async {
    isLoading.value = true;
    try {
      await _ensureDataLoaded();
      initWorkoutCollectionTree();
      loadCollectionCategories();
      loadUserCollections();
      loadCollectionSetting();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _ensureDataLoaded() async {
    await DataService.instance.loadCollectionCategoryList();
    await DataService.instance.loadCollectionList();
    await DataService.instance.loadWorkoutList();
    await DataService.instance.loadUserCollectionList();
  }

  Future<void> refreshCollectionData() async {
    isRefreshing.value = true;
    try {
      await DataService.instance.reloadWorkoutData();
      await DataService.instance.loadUserCollectionList();

      initWorkoutCollectionTree();

      loadCollectionCategories();
      loadUserCollections();
      loadCollectionSetting();
    } catch (e) {
    } finally {
      isRefreshing.value = false;
    }
  }

  void reloadCollectionsForCategory(Category cate) {
    _currentViewingCategory = cate;

    collections.assignAll(List<WorkoutCollection>.from(workoutCollectionTree
        .searchComponent(cate.id ?? '', workoutCollectionTree.components)!
        .getList()));
  }

  void clearCurrentCategory() {
    _currentViewingCategory = null;
  }

  Future<void> onSelectUserCollection(WorkoutCollection collection) async {
    selectedCollection = collection;
    isDefaultCollection = false;
    await loadWorkoutListForUserCollection();

    // Đảm bảo numOfWorkoutPerRound có giá trị hợp lý nếu workoutList không rỗng
    if (workoutList.isNotEmpty &&
        collectionSetting.value.numOfWorkoutPerRound == 0) {
      // Nếu numOfWorkoutPerRound = 0 nhưng có workouts, set bằng số lượng workout
      collectionSetting.value.numOfWorkoutPerRound = workoutList.length;
      print(
          '⚠️ onSelectUserCollection: Đã set numOfWorkoutPerRound = ${workoutList.length} vì giá trị ban đầu = 0');
    }

    generateRandomList();
  }

  void initWorkoutCollectionTree() {
    final cateList = DataService.instance.collectionCateList;
    final collectionListData = DataService.instance.collectionList;

    if (cateList.isEmpty) {
      workoutCollectionTree = WorkoutCollectionCategory();
      return;
    }

    Map map = {
      for (var e in cateList) e.id: WorkoutCollectionCategory.fromCategory(e)
    };

    workoutCollectionTree = WorkoutCollectionCategory();

    for (var item in cateList) {
      if (item.isRootCategory()) {
        workoutCollectionTree.add(map[item.id]);
      } else {
        WorkoutCollectionCategory? parentCate = map[item.parentCategoryID];
        if (parentCate != null) {
          parentCate.add(WorkoutCollectionCategory.fromCategory(item));
        }
      }
    }

    for (var item in collectionListData) {
      for (var cateID in item.categoryIDs) {
        WorkoutCollectionCategory? wkCate = workoutCollectionTree
            .searchComponent(cateID, workoutCollectionTree.components);
        if (wkCate != null) {
          wkCate.add(item);
        }
      }
    }
  }

  void onSelectDefaultCollection(WorkoutCollection collection) {
    selectedCollection = collection;
    loadWorkoutListForDefaultCollection(collection.generatorIDs);
    isDefaultCollection = true;
    generateRandomList();
  }

  generateRandomList() {
    if (workoutList.isEmpty) {
      generatedWorkoutList = [];
      collectionSetting.value.numOfWorkoutPerRound = 0;
      print('⚠️ generateRandomList: workoutList rỗng, không thể generate');
    } else {
      maxWorkout.value = workoutList.length;
      print(
          '✅ generateRandomList: workoutList có ${workoutList.length} workouts, numOfWorkoutPerRound = ${collectionSetting.value.numOfWorkoutPerRound}');

      // Nếu numOfWorkoutPerRound = 0 hoặc lớn hơn số lượng workout có, set lại
      if (collectionSetting.value.numOfWorkoutPerRound == 0 ||
          collectionSetting.value.numOfWorkoutPerRound > maxWorkout.value) {
        collectionSetting.value.numOfWorkoutPerRound = maxWorkout.value;
        print(
            '⚠️ generateRandomList: Đã điều chỉnh numOfWorkoutPerRound thành ${maxWorkout.value}');
      }

      workoutList.shuffle();

      // Đảm bảo không bị lỗi khi sublist
      int count = collectionSetting.value.numOfWorkoutPerRound;
      if (count > 0 && count <= workoutList.length) {
        generatedWorkoutList = workoutList.sublist(0, count);
        print(
            '✅ generateRandomList: Đã generate ${generatedWorkoutList.length} workouts');
      } else {
        generatedWorkoutList = [];
        print(
            '❌ generateRandomList: Không thể generate, count = $count, workoutList.length = ${workoutList.length}');
      }
    }

    calculateCaloAndTime();
    update();
  }

  void addUserCollection(WorkoutCollection wkCollection) async {
    userCollections.add(wkCollection);
    update();
    await WorkoutCollectionProvider().add(wkCollection);
    calculateCaloAndTime();
  }

  editUserCollection(WorkoutCollection editedCollection) async {
    selectedCollection = editedCollection;

    final index = userCollections
        .indexWhere((element) => element.id == selectedCollection!.id);
    userCollections[index] = selectedCollection!;

    loadWorkoutListForUserCollection();
    generateRandomList();
    update();

    await WorkoutCollectionProvider()
        .update(selectedCollection!.id ?? '', selectedCollection!);
  }

  deleteUserCollection() async {
    final result = await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return CustomConfirmationDialog(
          label: 'Xóa bộ luyện tập',
          content:
              'Bạn có chắc chắn muốn xóa bộ luyện tập này? Bạn sẽ không thể hoàn tác lại thao tác này.',
          labelCancel: 'Không',
          labelOk: 'Có',
          onCancel: () {
            Navigator.of(context).pop();
          },
          onOk: () {
            Navigator.of(context).pop(OkCancelResult.ok);
          },
          primaryButtonColor: AppColor.primaryColor,
          buttonFactorOnMaxWidth: 0.32,
          buttonsAlignment: MainAxisAlignment.spaceEvenly,
        );
      },
    );

    if (result == OkCancelResult.ok) {
      if (selectedCollection!.id == null) return;
      userCollections
          .removeWhere((element) => element.id == selectedCollection!.id);
      await WorkoutCollectionProvider().delete(selectedCollection!.id ?? '');

      calculateCaloAndTime();

      update();
      Get.back();
    }
  }

  // hàm load các user collection
  void loadUserCollections() {
    userCollections = DataService.instance.userCollectionList;
  }

  // hàm load workoutList của user collection
  Future<void> loadWorkoutListForUserCollection() async {
    workoutList = [];

    if (selectedCollection == null ||
        selectedCollection!.generatorIDs.isEmpty) {
      print(
          '⚠️ loadWorkoutListForUserCollection: selectedCollection hoặc generatorIDs rỗng');
      return;
    }

    print(
        '📋 loadWorkoutListForUserCollection: Bắt đầu load ${selectedCollection!.generatorIDs.length} workouts');

    // Đảm bảo workout list đã được load
    if (DataService.instance.workoutList.isEmpty) {
      print(
          '📥 loadWorkoutListForUserCollection: Đang load workout list từ DataService...');
      await DataService.instance.loadWorkoutList();
    }

    final workoutProvider = WorkoutProvider();

    for (var id in selectedCollection!.generatorIDs) {
      if (id.isEmpty) {
        print('⚠️ loadWorkoutListForUserCollection: Bỏ qua ID rỗng');
        continue;
      }

      // Tìm trong cache trước
      var workouts =
          DataService.instance.workoutList.where((element) => element.id == id);
      if (workouts.isNotEmpty) {
        workoutList.add(workouts.first);
        print(
            '✅ loadWorkoutListForUserCollection: Tìm thấy workout $id trong cache');
      } else {
        // Nếu không tìm thấy trong cache, fetch từ Firestore
        try {
          print(
              '📥 loadWorkoutListForUserCollection: Fetch workout $id từ Firestore...');
          final workout = await workoutProvider.fetch(id);
          workoutList.add(workout);
          // Thêm vào cache để lần sau không cần fetch lại
          if (!DataService.instance.workoutList.any((w) => w.id == id)) {
            DataService.instance.workoutList.add(workout);
          }
          print(
              '✅ loadWorkoutListForUserCollection: Đã load workout $id từ Firestore');
        } catch (e) {
          // Ignore errors, continue với workout tiếp theo
          print(
              '❌ loadWorkoutListForUserCollection: Không thể load workout với ID: $id - $e');
        }
      }
    }

    print(
        '📊 loadWorkoutListForUserCollection: Đã load ${workoutList.length}/${selectedCollection!.generatorIDs.length} workouts');
  }

  // hàm load workoutList của collection có sẵn
  void loadWorkoutListForDefaultCollection(List<String> cateIDs) {
    List<Workout> list = [];
    for (var id in cateIDs) {
      var workouts = DataService.instance.workoutList
          .where((element) => element.categoryIDs.contains(id));
      list.addAll(workouts);
    }

    workoutList = list;
  }

  // hàm reset calo và time
  void resetCaloAndTime() {
    caloValue.value = 0;
    timeValue.value = 0;
  }

  // hàm tính toán calo và time
  void calculateCaloAndTime() {
    num bodyWeight = DataService.currentUser!.currentWeight;
    resetCaloAndTime();
    caloValue.value = WorkoutCollectionUtils.calculateCalo(
        workoutList: generatedWorkoutList,
        collectionSetting: collectionSetting.value,
        bodyWeight: bodyWeight);

    timeValue.value = WorkoutCollectionUtils.calculateTime(
        collectionSetting: collectionSetting.value,
        workoutListLength: generatedWorkoutList.length);

    displayTime.value = timeValue.value < 1
        ? '${(timeValue.value * 60).toInt()} giây'
        : '${timeValue.value.toInt()} phút';
  }

  // hàm load collection setting
  void loadCollectionSetting() {
    if (useDefaulColSetting) {
      collectionSetting.value = DataService.currentUser!.collectionSetting;
    }
  }

  // hàm update collection setting
  Future<void> updateCollectionSetting() async {
    if (useDefaulColSetting) {
      await WorkoutCollectionSettingProvider()
          .update('id', collectionSetting.value);
    }
  }

  // // hàm load cateListAndNumCollection
  // void loadCateListAndNumCollection() {
  //   cateListAndNumCollection = DataService.instance.cateListAndNumCollection;
  // }

  // hàm load category của các collection
  void loadCollectionCategories() {
    // collectionCategories = DataService.instance.collectionCateList
    //     .where((element) => element.parentCategoryID == null)
    //     .toList();

    collectionCategories.assignAll(
        List<WorkoutCollectionCategory>.from(workoutCollectionTree.getList()));
  }

  // hàm init list collection
  void initCollections() {
    collections.clear();
  }

  // hàm load list collection dựa trên cate
  void loadCollectionListBaseOnCategory(Category cate) {
    // Lưu lại category đang xem
    _currentViewingCategory = cate;

    collections.assignAll(List<WorkoutCollection>.from(workoutCollectionTree
        .searchComponent(cate.id ?? '', workoutCollectionTree.components)!
        .getList()));
    Get.toNamed(Routes.workoutCollectionList, arguments: cate);
  }

  // hàm load list cate con dựa trên cate cha
  void loadChildCategoriesBaseOnParentCategory(String categoryID) {
    // collectionCategories = DataService.instance.collectionCateList
    //     .where((element) => element.parentCategoryID == categoryID)
    //     .toList();

    collectionCategories.assignAll(List<WorkoutCollectionCategory>.from(
        workoutCollectionTree
            .searchComponent(categoryID, workoutCollectionTree.components)!
            .getList()));
    Get.toNamed(Routes.workoutCollectionCategory, preventDuplicates: false);
  }
}
