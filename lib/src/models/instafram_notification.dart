class InstaframNotification {
  InstaframNotification({this.tweetKey});

  InstaframNotification.fromJson(Map<String, dynamic> json) {
    // tweetKey = tweetId;
    updatedAt = json['updatedAt'] as String;
    type = json['type'] as String;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'tweetKey': tweetKey,
      };

  String tweetKey;
  String updatedAt;
  String type;
}
