class User {
  User({
    this.email,
    this.userId,
    this.displayName,
    this.profilePic,
    this.key,
    this.contact,
    this.bio,
    this.dob,
    this.location,
    this.createdAt,
    this.userName,
    this.followers,
    this.following,
    this.webSite,
    this.isVerified,
    this.fcmToken,
    this.followersList,
    this.followingList,
  });

  User.fromJson(Map<String, dynamic> map) {
    if (map == null) {
      return;
    }

    email = map['email'] as String;
    userId = map['userId'] as String;
    displayName = map['displayName'] as String;
    profilePic = map['profilePic'] as String;
    key = map['key'] as String;
    dob = map['dob'] as String;
    bio = map['bio'] as String;
    location = map['location'] as String;
    contact = map['contact'] as String;
    createdAt = map['createdAt'] as String;
    followers = map['followers'] as int;
    following = map['following'] as int;
    userName = map['userName'] as String;
    webSite = map['webSite'] as String;
    fcmToken = map['fcmToken'] as String;
    isVerified = map['isVerified'] as bool ?? false;

    final List<dynamic> followersLookup = map['followersList'] as List<dynamic>;
    final List<dynamic> followingLookup = map['followingList'] as List<dynamic>;

    if (followersLookup.isNotEmpty) {
      followersList = <String>[];
      map['followersList'].forEach((dynamic value) {
        followersList.add(value as String);
      });
    }

    followers = followersList != null ? followersList.length : null;

    if (followingLookup.isNotEmpty) {
      followingList = <String>[];
      map['followingList'].forEach((dynamic value) {
        followingList.add(value as String);
      });
    }

    following = followingList != null ? followingList.length : null;
  }

  String key;
  String email;
  String userId;
  String displayName;
  String userName;
  String webSite;
  String profilePic;
  String contact;
  String bio;
  String location;
  String dob;
  String createdAt;
  bool isVerified;
  int followers;
  int following;
  String fcmToken;
  List<String> followersList;
  List<String> followingList;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'key': key,
        'userId': userId,
        'email': email,
        'displayName': displayName,
        'profilePic': profilePic,
        'contact': contact,
        'dob': dob,
        'bio': bio,
        'location': location,
        'createdAt': createdAt,
        'followers': followersList != null ? followersList.length : null,
        'following': followingList != null ? followingList.length : null,
        'userName': userName,
        'webSite': webSite,
        'isVerified': isVerified ?? false,
        'fcmToken': fcmToken,
        'followersList': followersList,
        'followingList': followingList
      };

  User copyWith({
    String email,
    String userId,
    String displayName,
    String profilePic,
    String key,
    String contact,
    String bio,
    String dob,
    String location,
    String createdAt,
    String userName,
    int followers,
    int following,
    String webSite,
    bool isVerified,
    String fcmToken,
    List<String> followersList,
    List<String> followingList,
  }) =>
      User(
        email: email ?? this.email,
        bio: bio ?? this.bio,
        contact: contact ?? this.contact,
        createdAt: createdAt ?? this.createdAt,
        displayName: displayName ?? this.displayName,
        dob: dob ?? this.dob,
        followers: followersList != null ? followersList.length : null,
        following: following ?? this.following,
        isVerified: isVerified ?? this.isVerified,
        key: key ?? this.key,
        location: location ?? this.location,
        profilePic: profilePic ?? this.profilePic,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        webSite: webSite ?? this.webSite,
        fcmToken: fcmToken ?? this.fcmToken,
        followersList: followersList ?? this.followersList,
        followingList: followingList ?? this.followingList,
      );

  String getFollower() => '${followers ?? 0}';

  String getFollowing() => '${following ?? 0}';
}
