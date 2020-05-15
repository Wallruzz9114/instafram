import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/models/feed.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/states/application_state.dart';
import 'package:path/path.dart' as path;

class FeedState extends ApplicationState {
  bool isBusy = false;
  Map<String, List<Feed>> tweetReplyMap = <String, List<Feed>>{};
  Feed _tweetToReplyModel;

  Feed get tweetToReplyModel => _tweetToReplyModel;
  set setTweetToReply(Feed model) {
    _tweetToReplyModel = model;
  }

  List<Feed> _commentlist;

  List<Feed> _feedlist;
  List<Feed> _tweetDetailModelList;
  List<String> _userfollowingList;
  List<String> get followingList => _userfollowingList;

  List<Feed> get tweetDetailModel => _tweetDetailModelList;

  static final CollectionReference _tweetCollection =
      kfirestore.collection(TWEET_COLLECTION);

  /// `feedlist` always [contain all tweets] fetched from firebase database
  List<Feed> get feedlist =>
      _feedlist == null ? null : List<Feed>.from(_feedlist.reversed);

  /// contain tweet list for home page
  List<Feed> getTweetList(User userModel) {
    if (userModel == null) {
      return null;
    }

    List<Feed> list;

    if (!isBusy && feedlist != null && feedlist.isNotEmpty) {
      list = feedlist.where((Feed x) {
        /// If Tweet is a comment then no need to add it in tweet list
        if (x.parentkey != null &&
            x.childRetwetkey == null &&
            x.user.userId != userModel.userId) {
          return false;
        }

        /// Only include Tweets of logged-in user's and his following user's
        if (x.user.userId == userModel.userId ||
            (userModel?.followingList != null &&
                userModel.followingList.contains(x.user.userId))) {
          return true;
        } else {
          return false;
        }
      }).toList();
      if (list.isEmpty) {
        list = null;
      }
    }
    return list;
  }

  /// set tweet for detail tweet page
  /// Setter call when tweet is tapped to view detail
  /// Add Tweet detail is added in _tweetDetailModelList
  /// It makes `Fwitter` to view nested Tweets
  set setFeed(Feed model) {
    _tweetDetailModelList ??= <Feed>[];

    /// [Skip if any duplicate tweet already present]
    _tweetDetailModelList.add(model);
    cprint('Detail Tweet added. Total Tweet: ${_tweetDetailModelList.length}');
    // notifyListeners();
  }

  /// `remove` last Tweet from tweet detail page stack
  /// Function called when navigating back from a Tweet detail
  /// `_tweetDetailModelList` is map which contain lists of commment Tweet list
  /// After removing Tweet from Tweet detail Page stack its commnets tweet is also removed from `_tweetDetailModelList`
  void removeLastTweetDetail(String tweetKey) {
    if (_tweetDetailModelList != null && _tweetDetailModelList.isNotEmpty) {
      // var index = _tweetDetailModelList.in
      final Feed removeTweet =
          _tweetDetailModelList.lastWhere((Feed x) => x.key == tweetKey);
      _tweetDetailModelList.remove(removeTweet);
      tweetReplyMap
          .removeWhere((String key, List<Feed> value) => key == tweetKey);
      cprint(
          'Last Tweet removed from stack. Remaining Tweet: ${_tweetDetailModelList.length}');
      if (_tweetDetailModelList.isNotEmpty) {
        print('Last id available: ' + _tweetDetailModelList.last.key);
      }
      notifyListeners();
    }
  }

  /// [clear all tweets] if any tweet present in tweet detail page or comment tweet
  void clearAllDetailAndReplyTweetStack() {
    if (_tweetDetailModelList != null) {
      _tweetDetailModelList.clear();
    }
    if (tweetReplyMap != null) {
      tweetReplyMap.clear();
    }
    cprint('Empty tweets from stack');
  }

  /// [Subscribe Tweets] firebase Database
  Future<bool> databaseInit() {
    try {
      _tweetCollection.snapshots().listen((QuerySnapshot snapshot) {
        if (snapshot.documentChanges.first.type == DocumentChangeType.added) {
          _onTweetAdded(snapshot.documentChanges.first.document);
        } else if (snapshot.documentChanges.first.type ==
            DocumentChangeType.removed) {
          _onTweetRemoved(snapshot.documentChanges.first.document);
        } else if (snapshot.documentChanges.first.type ==
            DocumentChangeType.modified) {
          _onTweetChanged(snapshot.documentChanges.first.document);
        }
      });

      return Future<bool>.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future<bool>.value(false);
    }
  }

  /// get [Tweet list] from firebase realtime database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      _feedlist = null;
      notifyListeners();

      _tweetCollection.getDocuments().then((QuerySnapshot querySnapshot) {
        _feedlist = <Feed>[];
        if (querySnapshot != null && querySnapshot.documents.isNotEmpty) {
          for (int i = 0; i < querySnapshot.documents.length; i++) {
            final Feed model = Feed.fromJson(querySnapshot.documents[i].data);
            model.key = querySnapshot.documents[i].documentID;
            _feedlist.add(model);
          }

          /// Sort Tweet by time
          /// It helps to display newest Tweet first.
          _feedlist.sort((Feed x, Feed y) => DateTime.parse(x.createdAt)
              .compareTo(DateTime.parse(y.createdAt)));
          notifyListeners();
        } else {
          _feedlist = null;
        }
      });
      isBusy = false;
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// get [Tweet Detail] from firebase realtime kDatabase
  /// If model is null then fetch tweet from firebase
  /// [getpostDetailFromDatabase] is used to set prepare Tweetr to display Tweet detail
  /// After getting tweet detail fetch tweet coments from firebase
  Future<void> getpostDetailFromDatabase(String postID, {Feed model}) async {
    try {
      Feed _tweetDetail;
      if (model != null) {
        // set tweet data from tweet list data.
        // No need to fetch tweet from firebase db if data already present in tweet list
        _tweetDetail = model;
        setFeed = _tweetDetail;
        postID = model.key;
      } else {
        // Fetch tweet data from firebase
        _tweetCollection
            .document(postID)
            .get()
            .then((DocumentSnapshot snapshot) {
          final Map<String, dynamic> map = snapshot.data;
          _tweetDetail = Feed.fromJson(map);
          _tweetDetail.key = snapshot.documentID;
          setFeed = _tweetDetail;
        });
      }

      if (_tweetDetail != null) {
        // Fetch comment tweets
        _commentlist = <Feed>[];
        // Check if parent tweet has reply tweets or not
        if (_tweetDetail.replyTweetKeyList != null &&
            _tweetDetail.replyTweetKeyList.isNotEmpty) {
          for (final String tweetKey in _tweetDetail.replyTweetKeyList) {
            if (tweetKey == null) {
              return;
            }
            _tweetCollection
                .document(tweetKey)
                .get()
                .then((DocumentSnapshot snapshot) {
              if (snapshot.data != null) {
                final Map<String, dynamic> map = snapshot.data;
                final Feed commentmodel = Feed.fromJson(map);
                commentmodel.key = snapshot.documentID;
                commentmodel.key = snapshot.documentID;
                // setFeedModel = _tweetDetail;

                /// add comment tweet to list if tweet is not present in [comment tweet ]list
                /// To reduce duplicacy
                if (!_commentlist.any((Feed x) => x.key == commentmodel.key)) {
                  _commentlist.add(commentmodel);
                }
              }
              if (tweetKey == _tweetDetail.replyTweetKeyList.last) {
                /// Sort comment by time
                /// It helps to display newest Tweet first.
                _commentlist.sort((Feed x, Feed y) =>
                    DateTime.parse(y.createdAt)
                        .compareTo(DateTime.parse(x.createdAt)));
                tweetReplyMap.putIfAbsent(postID, () => _commentlist);
              }
            }).whenComplete(() {
              if (tweetKey == _tweetDetail.replyTweetKeyList.last) {
                notifyListeners();
              }
            });
          }
        } else {
          tweetReplyMap.putIfAbsent(postID, () => _commentlist);
          notifyListeners();
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'getpostDetailFromDatabase');
    }
  }

  /// Fetch `Retweet` model from firebase realtime kDatabase.
  /// Retweet itself  is a type of `Tweet`
  Future<Feed> fetchTweet(String postID) async {
    Feed _tweetDetail;

    /// If tweet is availabe in feedlist then no need to fetch it from firebase
    if (feedlist.any((Feed x) => x.key == postID)) {
      _tweetDetail = feedlist.firstWhere((Feed x) => x.key == postID);
    }

    /// If tweet is not available in feedlist then need to fetch it from firebase
    else {
      cprint('Fetched null value from  DB');
    }
    return _tweetDetail;
  }

  /// create [New Tweet]
  Future<void> createTweet(Feed model) async {
    ///  Create tweet in [Firebase kDatabase]
    isBusy = true;
    notifyListeners();
    try {
      await _tweetCollection.document().setData(model.toJson());
      // kDatabase.child('tweet').push().set(model.toJson());
    } catch (error) {
      cprint(error, errorIn: 'createTweet');
    }
    isBusy = false;
    notifyListeners();
  }

  ///  It will create tweet in [Firebase kDatabase] just like other normal tweet.
  ///  update retweet count for retweet model
  void createReTweet(Feed model) {
    try {
      createTweet(model);
      _tweetToReplyModel.retweetCount += 1;
      updateTweet(_tweetToReplyModel);
    } catch (error) {
      cprint(error, errorIn: 'createReTweet');
    }
  }

  /// [Delete tweet] in Firebase kDatabase
  /// Remove Tweet if present in home page Tweet list
  /// Remove Tweet if present in Tweet detail page or in comment
  void deleteTweet(String tweetId, TweetType type, {String parentkey}) {
    try {
      /// Delete tweet if it is in nested tweet detail page
      ///  kfirestore

      _tweetCollection.document(tweetId).delete().then((_) {
        if (type == TweetType.Detail &&
            _tweetDetailModelList != null &&
            _tweetDetailModelList.isNotEmpty) {
          final Feed deletedTweet =
              _tweetDetailModelList.firstWhere((Feed x) => x.key == tweetId);
          _tweetDetailModelList.remove(deletedTweet);

          if (_tweetDetailModelList.isEmpty) {
            _tweetDetailModelList = null;
          }

          cprint('Tweet deleted from nested tweet detail page tweet');
        }
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteTweet');
    }
  }

  /// upload [file] to firebase storage and return its  path url
  Future<dynamic> uploadFile(File file) async {
    try {
      isBusy = true;
      notifyListeners();

      final StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('tweetImage${path.basename(file.path)}');
      final StorageUploadTask uploadTask = storageReference.putFile(file);
      final StorageTaskSnapshot snapshot = await uploadTask.onComplete;

      if (snapshot != null) {
        final dynamic url = await storageReference.getDownloadURL();
        if (url != null) {
          return url;
        }
      }
    } catch (error) {
      cprint(error, errorIn: 'uploadFile');
      return null;
    }
  }

  /// [Delete file] from firebase storage
  Future<void> deleteFile(String url, String baseUrl) async {
    try {
      String filePath = url.replaceAll(
          RegExp(
              r'https://firebasestorage.googleapis.com/v0/b/twitter-clone-4fce9.appspot.com/o/'),
          '');
      filePath = filePath.replaceAll(RegExp(r'%2F'), '/');
      filePath = filePath.replaceAll(RegExp(r'(\?alt).*'), '');
      //  filePath = filePath.replaceAll('tweetImage/', '');
      //  cprint('[Path]'+filePath);
      final StorageReference storageReference = FirebaseStorage.instance.ref();
      await storageReference.child(filePath).delete().catchError((dynamic val) {
        cprint('[Error]' + (val as String));
      }).then((_) {
        cprint('[Sucess] Image deleted');
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteFile');
    }
  }

  /// [update] tweet
  Future<void> updateTweet(Feed model) async {
    await _tweetCollection.document(model.key).updateData(model.toJson());
    // await kDatabase.child('tweet').child(model.key).set(model.toJson());
  }

  /// Add/Remove like on a Tweet
  /// [postId] is tweet id, [userId] is user's id who like/unlike Tweet
  void addLikeToTweet(Feed tweet, String userId) {
    try {
      if (tweet.likeList != null &&
          tweet.likeList.isNotEmpty &&
          tweet.likeList.any((String id) => id == userId)) {
        // If user wants to undo/remove his like on tweet
        tweet.likeList.removeWhere((String id) => id == userId);
        tweet.likeCount -= 1;
      } else {
        // If user like Tweet
        tweet.likeList ??= <String>[];
        tweet.likeList.add(userId);
        tweet.likeCount += 1;
      }
      // update likelist of a tweet
      _tweetCollection.document(tweet.key).updateData(<String, dynamic>{
        'likeCount': tweet.likeCount,
        'likeList': tweet.likeList
      });
      // _tweetCollection
      //     .document(tweet.key)
      //     .collection(TWEET_LIKE_COLLECTION)
      //     .document(TWEET_LIKE_COLLECTION)
      //     .setData({"data": FieldValue.arrayUnion(tweet.likeList)});

      // Sends notification to user who created tweet
      // User owner can see notification on notification page
      if (tweet.likeList.isEmpty) {
        kfirestore
            .collection(USERS_COLLECTION)
            .document(tweet.userId)
            .collection(NOTIFICATION_COLLECTION)
            .document(tweet.key)
            .delete();
      } else {
        kfirestore
            .collection(USERS_COLLECTION)
            .document(tweet.userId)
            .collection(NOTIFICATION_COLLECTION)
            .document(tweet.key)
            .setData(<String, dynamic>{
          'type': NotificationType.Like.toString(),
          'updatedAt': DateTime.now().toUtc().toString(),
        });
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'addLikeToTweet');
    }
  }

  /// Add [new comment tweet] to any tweet
  /// Comment is a Tweet itself
  void addcommentToPost(Feed replyTweet) {
    try {
      isBusy = true;
      notifyListeners();
      if (_tweetToReplyModel != null) {
        final Feed tweet =
            _feedlist.firstWhere((Feed x) => x.key == _tweetToReplyModel.key);
        createTweet(replyTweet).then((void value) {
          tweet.replyTweetKeyList.add(_feedlist.last.key);
          updateTweet(tweet);
        });
      }
    } catch (error) {
      cprint(error, errorIn: 'addcommentToPost');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when any tweet changes or update
  /// When any tweet changes it update it in UI
  /// No matter if Tweet is in home page or in detail page or in comment section.
  void _onTweetChanged(DocumentSnapshot event) {
    if (event.data == null) {
      return;
    }
    final Feed model = Feed.fromJson(event.data);

    model.key = event.documentID;

    if (_feedlist.any((Feed x) => x.key == model.key)) {
      final Feed oldEntry = _feedlist.lastWhere((Feed entry) {
        return entry.key == event.documentID;
      });
      _feedlist[_feedlist.indexOf(oldEntry)] = model;
    }

    if (_tweetDetailModelList != null && _tweetDetailModelList.isNotEmpty) {
      if (_tweetDetailModelList.any((Feed x) => x.key == model.key)) {
        final Feed oldEntry = _tweetDetailModelList.lastWhere((Feed entry) {
          return entry.key == event.documentID;
        });
        _tweetDetailModelList[_tweetDetailModelList.indexOf(oldEntry)] = model;
      }
      if (tweetReplyMap != null && tweetReplyMap.isNotEmpty) {
        if (true) {
          List<Feed> list = tweetReplyMap[model.parentkey];
          //  var list = tweetReplyMap.values.firstWhere((x) => x.any((y) => y.key == model.key));
          if (list != null && list.isNotEmpty) {
            final int index =
                list.indexOf(list.firstWhere((Feed x) => x.key == model.key));
            list[index] = model;
          } else {
            list = <Feed>[];
            list.add(model);
          }
        }
      }
    }
    if (event.data != null) {
      cprint('Tweet updated');
      isBusy = false;
      notifyListeners();
    }
  }

  /// Trigger when new tweet added
  /// It will add new Tweet in home page list.
  /// IF Tweet is comment it will be added in comment section too.
  void _onTweetAdded(DocumentSnapshot event) {
    final Feed tweet = Feed.fromJson(event.data);
    tweet.key = event.documentID;

    /// Check if Tweet is a comment
    _onCommentAdded(tweet);
    _feedlist ??= <Feed>[];
    if ((_feedlist.isEmpty || _feedlist.any((Feed x) => x.key != tweet.key)) &&
        tweet.isValidTweet) {
      _feedlist.add(tweet);
      cprint('Tweet Added');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when comment tweet added
  /// Check if Tweet is a comment
  /// If Yes it will add tweet in comment list.
  /// add [new tweet] comment to comment list
  void _onCommentAdded(Feed tweet) {
    if (tweet.childRetwetkey != null) {
      /// if Tweet is a type of retweet then it can not be a comment.
      return;
    }
    if (tweetReplyMap != null && tweetReplyMap.isNotEmpty) {
      if (tweetReplyMap[tweet.parentkey] != null) {
        tweetReplyMap[tweet.parentkey].add(tweet);
      } else {
        tweetReplyMap[tweet.parentkey] = <Feed>[tweet];
      }
      cprint('Comment Added');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when Tweet `Deleted`
  /// It removed Tweet from home page list, Tweet detail page list and from comment section if present
  Future<void> _onTweetRemoved(DocumentSnapshot event) async {
    final Feed tweet = Feed.fromJson(event.data);
    tweet.key = event.documentID;
    final String tweetId = tweet.key;
    final String parentkey = tweet.parentkey;

    ///  Delete tweet in [Home Page]
    try {
      Feed deletedTweet;
      if (_feedlist.any((Feed x) => x.key == tweetId)) {
        /// Delete tweet if it is in home page tweet.
        deletedTweet = _feedlist.firstWhere((Feed x) => x.key == tweetId);
        _feedlist.remove(deletedTweet);

        if (deletedTweet.parentkey != null &&
            _feedlist.isNotEmpty &&
            _feedlist.any((Feed x) => x.key == deletedTweet.parentkey)) {
          // Decrease parent Tweet comment count and update
          final Feed parentModel =
              _feedlist.firstWhere((Feed x) => x.key == deletedTweet.parentkey);
          parentModel.replyTweetKeyList.remove(deletedTweet.key);
          parentModel.commentCount = parentModel.replyTweetKeyList.length;
          updateTweet(parentModel);
        }
        if (_feedlist.isEmpty) {
          _feedlist = null;
        }
        cprint('Tweet deleted from home page tweet list');
      }

      /// [Delete tweet] if it is in nested tweet detail comment section page
      if (parentkey != null &&
          parentkey.isNotEmpty &&
          tweetReplyMap != null &&
          tweetReplyMap.isNotEmpty &&
          tweetReplyMap.keys.any((String x) => x == parentkey)) {
        // (type == TweetType.Reply || tweetReplyMap.length > 1) &&
        deletedTweet =
            tweetReplyMap[parentkey].firstWhere((Feed x) => x.key == tweetId);
        tweetReplyMap[parentkey].remove(deletedTweet);
        if (tweetReplyMap[parentkey].isEmpty) {
          tweetReplyMap[parentkey] = null;
        }

        if (_tweetDetailModelList != null &&
            _tweetDetailModelList.isNotEmpty &&
            _tweetDetailModelList.any((Feed x) => x.key == parentkey)) {
          final Feed parentModel =
              _tweetDetailModelList.firstWhere((Feed x) => x.key == parentkey);
          parentModel.replyTweetKeyList.remove(deletedTweet.key);
          parentModel.commentCount = parentModel.replyTweetKeyList.length;
          cprint('Parent tweet comment count updated on child tweet removal');
          updateTweet(parentModel);
        }

        cprint('Tweet deleted from nested tweet detail comment section');
      }

      /// Delete tweet image from firebase storage if exist.
      if (deletedTweet.imagePath != null && deletedTweet.imagePath.isNotEmpty) {
        deleteFile(deletedTweet.imagePath, 'tweetImage');
      }

      /// If a retweet is deleted then retweetCount of original tweet should be decrease by 1.
      if (deletedTweet.childRetwetkey != null) {
        await fetchTweet(deletedTweet.childRetwetkey).then((Feed retweetModel) {
          if (retweetModel == null) {
            return;
          }
          if (retweetModel.retweetCount > 0) {
            retweetModel.retweetCount -= 1;
          }
          updateTweet(retweetModel);
        });
      }

      /// Delete notification related to deleted Tweet.
      if (deletedTweet.likeCount > 0) {
        kfirestore
            .collection(USERS_COLLECTION)
            .document(tweet.userId)
            .collection(NOTIFICATION_COLLECTION)
            .document(tweet.key)
            .delete();
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onTweetRemoved');
    }
  }
}
