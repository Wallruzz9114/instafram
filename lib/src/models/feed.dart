import 'package:instafram/src/models/user.dart';

class Feed {
  Feed({
    this.key,
    this.description,
    this.userId,
    this.likeCount,
    this.commentCount,
    this.retweetCount,
    this.createdAt,
    this.imagePath,
    this.likeList,
    this.tags,
    this.user,
    this.replyTweetKeyList,
    this.parentkey,
    this.childRetwetkey,
  });

  Feed.fromJson(Map<String, dynamic> map) {
    key = map['key'] as String;
    description = map['description'] as String;
    userId = map['userId'] as String;
    likeCount = map['likeCount'] as int;
    commentCount = map['commentCount'] as int;
    retweetCount = map['retweetCount'] as int ?? 0;
    imagePath = map['imagePath'] as String;
    createdAt = map['createdAt'] as String;
    user = User.fromJson(map['user'] as Map<String, dynamic>);
    parentkey = map['parentkey'] as String;
    childRetwetkey = map['childRetwetkey'] as String;

    final List<dynamic> tagsList = map['tags'] as List<dynamic>;
    final List<dynamic> likesList = map['likeList'] as List<dynamic>;
    final List<dynamic> replyTweetKeysList =
        map['replyTweetKeyList'] as List<dynamic>;

    if (tagsList.isNotEmpty) {
      tags = <String>[];
      map['tags'].forEach((dynamic value) {
        tags.add(value as String);
      });
    }
    if (likesList.isNotEmpty) {
      likeList = <String>[];

      if (likesList is List) {
        map['likeList'].forEach((dynamic value) {
          likeList.add(value as String);
        });
        likeCount = likeList.length;
      }
    } else {
      likeList = <String>[];
      likeCount = 0;
    }
    if (replyTweetKeysList.isNotEmpty) {
      map['replyTweetKeyList'].forEach((dynamic value) {
        replyTweetKeyList = <String>[];
        map['replyTweetKeyList'].forEach((dynamic value) {
          replyTweetKeyList.add(value as String);
        });
      });
      commentCount = replyTweetKeyList.length;
    } else {
      replyTweetKeyList = <String>[];
      commentCount = 0;
    }
  }

  String key;
  String parentkey;
  String childRetwetkey;
  String description;
  String userId;
  int likeCount;
  List<String> likeList;
  int commentCount;
  int retweetCount;
  String createdAt;
  String imagePath;
  List<String> tags;
  List<String> replyTweetKeyList;
  User user;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userId': userId,
        'description': description,
        'likeCount': likeCount,
        'commentCount': commentCount ?? 0,
        'retweetCount': retweetCount ?? 0,
        'createdAt': createdAt,
        'imagePath': imagePath,
        'likeList': likeList,
        'tags': tags,
        'replyTweetKeyList': replyTweetKeyList,
        'user': user == null ? null : user.toJson(),
        'parentkey': parentkey,
        'childRetwetkey': childRetwetkey
      };

  bool get isValidTweet {
    bool isValid = false;
    if (description != null &&
        description.isNotEmpty &&
        user != null &&
        user.userName != null &&
        user.userName.isNotEmpty) {
      isValid = true;
    } else {
      print('Invalid Tweet found. Id:- $key');
    }
    return isValid;
  }
}
