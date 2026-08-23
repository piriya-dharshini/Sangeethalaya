import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/user_model.dart';

class UserService {
  final DatabaseReference _database =
      FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://sangeethalaya-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref();

  Future<void> createUser({
    required String uid,
    required String email,
    required String name,
  }) async {
    final userRef = _database.child('users').child(uid);

    final snapshot = await userRef.get();

    if (!snapshot.exists) {
      await userRef.set({
        'email': email,
        'name': name,
        'role': 'user',
        'createdAt': ServerValue.timestamp,
      });
    }
  }

  Future<UserModel?> getUser(String uid) async {
    final snapshot =
        await _database.child('users').child(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    final data = Map<String, dynamic>.from(
      snapshot.value as Map,
    );

    return UserModel.fromMap(
      uid,
      data,
    );
  }
}