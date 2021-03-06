import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/models/feed.dart';
import 'package:instafram/src/models/instafram_notification.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/states/application_state.dart';

class NotificationState extends ApplicationState {
  String fcmToken;
  NotificationType _notificationType = NotificationType.NOT_DETERMINED;
  String notificationReciverId, notificationTweetId;
  List<Feed> notificationTweetList;
  NotificationType get notificationType => _notificationType;
  set setNotificationType(NotificationType type) {
    _notificationType = type;
  }

  static final CollectionReference _userCollection =
      kfirestore.collection(USERS_COLLECTION);
  // FcmNotificationModel notification;
  String notificationSenderId;
  List<User> userList = <User>[];
  StreamSubscription<QuerySnapshot> notificationSubscription;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  List<InstaframNotification> _notificationList;

  List<InstaframNotification> get notificationList => _notificationList;

  /// [Intitilise firebase notification kDatabase]
  Future<bool> databaseInit(String userId) {
    try {
      // if (query == null) {
      // query = kDatabase.child("notification").child(userId);

      notificationSubscription = _userCollection
          .document(userId)
          .collection(NOTIFICATION_COLLECTION)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        if (snapshot.documentChanges.isEmpty) {
          return;
        }
        if (snapshot.documentChanges.first.type == DocumentChangeType.added) {
          _onNotificationAdded(snapshot.documentChanges.first.document);
        } else if (snapshot.documentChanges.first.type ==
            DocumentChangeType.removed) {
          _onNotificationRemoved(snapshot.documentChanges.first.document);
        } else if (snapshot.documentChanges.first.type ==
            DocumentChangeType.modified) {
          _onNotificationChanged(snapshot.documentChanges.first.document);
        }
      });

      return Future<bool>.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future<bool>.value(false);
    }
  }

  void unsubscribeNotifications(String userId) {
    notificationSubscription.cancel();
  }

  /// get [Notification list] from firebase realtime database
  void getDataFromDatabase(String userId) {
    try {
      loading = true;
      _notificationList = <InstaframNotification>[];
      _userCollection
          .document(userId)
          .collection(NOTIFICATION_COLLECTION)
          .getDocuments()
          .then((QuerySnapshot querySnapshot) {
        // _feedlist = List<FeedModel>();
        if (querySnapshot != null && querySnapshot.documents.isNotEmpty) {
          for (int i = 0; i < querySnapshot.documents.length; i++) {
            final InstaframNotification model =
                InstaframNotification.fromJson(querySnapshot.documents[i].data);
            model.tweetKey = querySnapshot.documents[i].documentID;
            if (_notificationList.any(
                (InstaframNotification x) => x.tweetKey == model.tweetKey)) {
              continue;
            }
            _notificationList.add(model);
          }
          _notificationList.sort(
              (InstaframNotification x, InstaframNotification y) =>
                  DateTime.parse(y.updatedAt)
                      .compareTo(DateTime.parse(x.updatedAt)));
        }
        loading = false;
        notifyListeners();
      });
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// get `Tweet` present in notification
  Future<Feed> getTweetDetail(String tweetId) async {
    Feed _tweetDetail;
    final DocumentSnapshot snapshot =
        await kfirestore.collection(TWEET_COLLECTION).document(tweetId).get();

    final Map<String, dynamic> map = snapshot.data;
    if (map != null) {
      _tweetDetail = Feed.fromJson(map);
      _tweetDetail.key = snapshot.documentID;
    }
    if (_tweetDetail == null) {
      cprint('Tweet not found ' + tweetId);

      /// remove notification from firebase db if tweet in not available or deleted.
    }
    if (tweetId == 'AOrRB0EHIbFSAev2WX4P') {
      print('dsfsfgg');
    }
    return _tweetDetail;
  }

  /// get user who liked your tweet
  Future<User> getuserDetail(String userId) async {
    User user;

    /// if user already available in userlist then get user data from list
    /// It reduce api load
    if (userList.isNotEmpty && userList.any((User x) => x.userId == userId)) {
      return Future<User>.value(
          userList.firstWhere((User x) => x.userId == userId));
    }

    /// If user sata not available in userlist then fetch user data from firestore
    final DocumentSnapshot snapshot =
        await kfirestore.collection(USERS_COLLECTION).document(userId).get();

    final Map<String, dynamic> map = snapshot.data;
    if (map != null) {
      user = User.fromJson(map);
      user.key = snapshot.documentID;

      /// Add user data to userlist
      /// Next time user data can be get from this list
      userList.add(user);
    }
    return user;
  }

  /// Remove notification if related Tweet is not found or deleted
  Future<void> removeNotification(String userId, String tweetkey) async {
    print('removeNotification ' + tweetkey);
    _userCollection
        .document(userId)
        .collection(NOTIFICATION_COLLECTION)
        .document(tweetkey)
        .delete();
  }

  /// Trigger when somneone like your tweet
  void _onNotificationAdded(DocumentSnapshot event) {
    if (event.data != null) {
      final InstaframNotification model =
          InstaframNotification.fromJson(event.data);
      model.tweetKey = event.documentID;
      // event.data["updatedAt"], event.data["type"]);
      _notificationList ??= <InstaframNotification>[];
      if (_notificationList
          .any((InstaframNotification x) => x.tweetKey == model.tweetKey)) {
        return;
      }
      _notificationList.insert(0, model);
      // _notificationList.add(model);
      // added notification to list
      print('Notification added');
      notifyListeners();
    }
  }

  // /// Trigger when someone changed his like preference
  void _onNotificationChanged(DocumentSnapshot event) {
    if (event.data != null) {
      final InstaframNotification model =
          InstaframNotification.fromJson(event.data);
      model.tweetKey = event.documentID;
      //update notification list
      _notificationList
          .firstWhere((InstaframNotification x) => x.tweetKey == model.tweetKey)
          .tweetKey = model.tweetKey;
      notifyListeners();
      cprint('Notification changed');
    }
  }

  /// Trigger when someone undo his like on tweet
  void _onNotificationRemoved(DocumentSnapshot event) {
    if (event.data != null) {
      final InstaframNotification model =
          InstaframNotification.fromJson(event.data);
      model.tweetKey = event.documentID;
      // remove notification from list
      _notificationList.removeWhere(
          (InstaframNotification x) => x.tweetKey == model.tweetKey);
      if (_notificationList.isEmpty) {
        _notificationList = null;
      }
      notifyListeners();
      cprint('Notification Removed');
    }
  }

  /// Configure notification services
  void initfirebaseService() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // print("onMessage: $message");
        print(message['data']);
        notifyListeners();
      },
      onLaunch: (Map<String, dynamic> message) async {
        cprint('Notification ', event: 'onLaunch');
        final Map<String, dynamic> data =
            message['data'] as Map<String, dynamic>;
        // print(message['data']);
        notificationSenderId = data['senderId'] as String;
        notificationReciverId = data['receiverId'] as String;
        notificationReciverId = data['receiverId'] as String;
        if (data['type'] == 'NotificationType.Mention') {
          setNotificationType = NotificationType.Mention;
        } else if (data['type'] == 'NotificationType.Message') {
          setNotificationType = NotificationType.Message;
        }
        notifyListeners();
      },
      onResume: (Map<String, dynamic> message) async {
        cprint('Notification ', event: 'onResume');
        final Map<String, dynamic> data =
            message['data'] as Map<String, dynamic>;
        // print(message['data']);
        notificationSenderId = data['senderId'] as String;
        notificationReciverId = data['receiverId'] as String;
        if (data['type'] == 'NotificationType.Mention') {
          setNotificationType = NotificationType.Mention;
        } else if (data['type'] == 'NotificationType.Message') {
          setNotificationType = NotificationType.Message;
        }
        notifyListeners();
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('Settings registered: $settings');
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      fcmToken = token;
      print(token);
    });
  }
}
