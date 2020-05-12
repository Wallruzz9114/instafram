import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instafram/src/models/post.dart';
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

  static void createPost(Post post) {
    postsReference
        .document(post.authorId)
        .collection('all_posts')
        .add(<String, dynamic>{
      'imageURL': post.imageURL,
      'caption': post.caption,
      'likes': post.likes,
      'authorId': post.authorId,
      'timestamp': post.timestamp,
    });
  }
}
