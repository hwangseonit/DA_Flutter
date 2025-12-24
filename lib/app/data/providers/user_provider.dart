import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vipt/app/core/values/values.dart';
import 'package:vipt/app/data/models/vipt_user.dart';
import 'package:vipt/app/data/providers/firestoration.dart';

class UserProvider implements Firestoration<String, ViPTUser> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<ViPTUser> add(ViPTUser obj) async {
    try {
      await _firestore.collection(collectionPath).doc(obj.id).set(obj.toMap());
      return obj;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
            'Permission denied: Cannot create user. Check Firestore security rules.');
      }
      rethrow;
    }
  }

  @override
  Future<String> delete(String id) {
    throw UnimplementedError();
  }

  @override
  Future<ViPTUser> fetch(String id) async {
    try {
      final rawData = await _firestore.collection(collectionPath).doc(id).get();
      return ViPTUser.fromMap(rawData.data() ?? {});
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
            'Permission denied: Cannot access user data. Check Firestore security rules.');
      }
      rethrow;
    }
  }

  @override
  Future<ViPTUser> update(String id, ViPTUser obj) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(id)
          .update(obj.toMap())
          .then((value) => obj.id = id);
      return obj;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
            'Permission denied: Cannot update user. Check Firestore security rules.');
      }
      rethrow;
    }
  }

  @override
  String get collectionPath => AppValue.usersPath;

  Future<bool> checkIfUserExist(String uid) async {
    try {
      var doc = await _firestore.collection(collectionPath).doc(uid).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        // Nếu permission denied, giả sử user chưa tồn tại (trả về false)
        // Điều này cho phép app tiếp tục flow tạo user mới
        return false;
      }
      // Với các lỗi khác, trả về false để tránh crash
      return false;
    } catch (e) {
      // Với bất kỳ lỗi nào khác, trả về false
      return false;
    }
  }

  @override
  Future<List<ViPTUser>> fetchAll() {
    throw UnimplementedError();
  }
}
