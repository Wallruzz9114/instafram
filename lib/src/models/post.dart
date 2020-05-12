import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  Post({
    this.id,
    this.imageURL,
    this.caption,
    this.likes,
    this.authorId,
    this.timestamp,
  });

  factory Post.fromDoc(DocumentSnapshot document) => Post(
        id: document.documentID,
        imageURL: document['imageURL'] as String,
        caption: document['caption'] as String,
        likes: document['likes'] as Map<String, dynamic>,
        authorId: document['authorId'] as String,
        timestamp: document['timestamp'] as Timestamp,
      );

  final String id;
  final String imageURL;
  final String caption;
  final Map<String, dynamic> likes;
  final String authorId;
  final Timestamp timestamp;
}
