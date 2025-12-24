import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vipt/app/core/values/values.dart';
import 'package:vipt/app/data/models/meal.dart';
import 'package:vipt/app/data/providers/firestoration.dart';

class MealProvider implements Firestoration<String, Meal> {
  final _firestore = FirebaseFirestore.instance;

  /// Stream để lắng nghe thay đổi real-time từ Firestore
  Stream<List<Meal>> streamAll() {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Meal.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<Meal> add(Meal obj) async {
    await _firestore
        .collection(collectionPath)
        .add(obj.toMap())
        .then((value) => obj.id = value.id);
    return obj;
  }

  // Deprecated: Use seedMeals() from fake_data.dart instead
  // addFakeDate() async {
  //   for (var meal in mealFakeData) {
  //     await add(meal);
  //   }
  // }

  @override
  String get collectionPath => AppValue.mealsPath;

  @override
  Future<String> delete(String id) async {
    await _firestore.collection(collectionPath).doc(id).delete();
    return id;
  }

  @override
  Future<Meal> fetch(String id) async {
    try {
      final raw = await _firestore.collection(collectionPath).doc(id).get();
      if (!raw.exists) {
        throw Exception('Meal with id $id does not exist');
      }
      return Meal.fromMap(raw.id, raw.data() ?? {});
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        // Log một lần thay vì spam
        rethrow;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Meal>> fetchAll() async {
    QuerySnapshot<Map<String, dynamic>> raw =
        await _firestore.collection(collectionPath).get();

    List<Meal> list = [];
    for (var element in raw.docs) {
      list.add(Meal.fromMap(element.id, element.data()));
    }

    return list;
  }

  Future<String> fetchByName(String name) async {
    String result = "";
    await _firestore
        .collection(collectionPath)
        .where('name', isEqualTo: name)
        .get()
        .then((value) => result = value.docs.first.id);
    return result;
  }

  @override
  Future<Meal> update(String id, Meal obj) async {
    await _firestore.collection(collectionPath).doc(id).update(obj.toMap());
    obj.id = id;
    return obj;
  }
}
