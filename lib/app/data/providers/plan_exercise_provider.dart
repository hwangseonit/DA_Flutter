import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vipt/app/core/values/values.dart';
import 'package:vipt/app/data/models/plan_exercise.dart';
import 'package:vipt/app/data/providers/firestoration.dart';

class PlanExerciseProvider implements Firestoration<String, PlanExercise> {
  final _firestore = FirebaseFirestore.instance;

  @override
  String get collectionPath => AppValue.planExercisesPath;

  @override
  Future<PlanExercise> add(PlanExercise obj) async {
    await _firestore
        .collection(collectionPath)
        .add(obj.toMap())
        .then((value) => obj.id = value.id);
    return obj;
  }

  @override
  Future<String> delete(String id) async {
    await _firestore.collection(collectionPath).doc(id).delete();
    return id;
  }

  @override
  Future<PlanExercise> fetch(String id) async {
    final raw = await _firestore.collection(collectionPath).doc(id).get();
    return PlanExercise.fromMap(raw.id, raw.data() ?? {});
  }

  @override
  Future<List<PlanExercise>> fetchAll() async {
    QuerySnapshot<Map<String, dynamic>> raw =
        await _firestore.collection(collectionPath).get();

    List<PlanExercise> list = [];
    for (var element in raw.docs) {
      list.add(PlanExercise.fromMap(element.id, element.data()));
    }

    return list;
  }

  Future<List<PlanExercise>> fetchByListID(String listID) async {
    QuerySnapshot<Map<String, dynamic>> raw = await _firestore
        .collection(collectionPath)
        .where('listID', isEqualTo: listID)
        .get();

    List<PlanExercise> list = [];
    for (var element in raw.docs) {
      list.add(PlanExercise.fromMap(element.id, element.data()));
    }

    return list;
  }

  @override
  Future<PlanExercise> update(String id, PlanExercise obj) async {
    await _firestore.collection(collectionPath).doc(id).update(obj.toMap());
    return obj;
  }

  Future<void> deleteAll() async {
    final snapshot = await _firestore.collection(collectionPath).get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
