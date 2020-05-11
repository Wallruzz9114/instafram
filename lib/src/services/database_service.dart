import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/utils/constants.dart';

class DatabaseService {
  static void updateUser(User user) {
    usersReference.document(user.id).updateData(<String, dynamic>{
      'username': user.username,
      'profileImage': user.profileImage,
      'bio': user.bio,
    });
  }

  static Future<QuerySnapshot> searchUsers(String queryString) {
    final Future<QuerySnapshot> searchResult = usersReference
        .where('username', isGreaterThanOrEqualTo: queryString)
        .getDocuments();

    return searchResult;
  }
}
