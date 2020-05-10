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
}
