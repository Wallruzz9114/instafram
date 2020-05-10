import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({this.id, this.username, this.profileImage, this.email, this.bio});

  factory User.fromDoc(DocumentSnapshot document) => User(
        id: document.documentID,
        username: document['username'] as String,
        profileImage: document['profileImage'] as String,
        email: document['email'] as String,
        bio: document['bio'] as String ?? '',
      );

  final String id;
  final String username;
  final String profileImage;
  final String email;
  final String bio;
}
