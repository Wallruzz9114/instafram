import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instafram/src/states/application_state.dart';
import 'package:path/path.dart' as path;

import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/models/user.dart';

class AuthenticationState extends ApplicationState {
  AuthenticationStatus authenticationStatus =
      AuthenticationStatus.NOT_DETERMINED;
  bool isSignInWithGoogle = false;
  FirebaseUser user;
  String userId;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<User> _profileUserModelList;
  User _userModel;

  User get userModel => _userModel;

  User get profileUserModel {
    if (_profileUserModelList != null && _profileUserModelList.isNotEmpty) {
      return _profileUserModelList.last;
    } else {
      return null;
    }
  }

  static final CollectionReference _userCollection =
      kfirestore.collection(USERS_COLLECTION);

  void removeLastUser() {
    _profileUserModelList.removeLast();
  }

  /// Logout from device
  void logoutCallback() {
    authenticationStatus = AuthenticationStatus.NOT_LOGGED_IN;
    userId = '';
    _userModel = null;
    user = null;
    _profileUserModelList = null;
    _firebaseAuth.signOut();
    notifyListeners();
  }

  /// Alter select auth method, login and sign up page
  void openSignUpPage() {
    authenticationStatus = AuthenticationStatus.NOT_LOGGED_IN;
    userId = '';
    notifyListeners();
  }

  Stream<DocumentSnapshot> callStream({String uid}) =>
      _userCollection.document(uid).snapshots();

  void databaseInit() {
    try {
      _userCollection.document(user.uid).snapshots().listen(_onProfileChanged);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
    }
  }

  /// Verify user's credentials for login
  Future<String> signIn(String email, String password,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      loading = true;
      final AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      userId = user.uid;
      return user.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signIn');
      kAnalytics.logLogin(loginMethod: 'email_login');
      customSnackBar(scaffoldKey, error.message as String);
      // logoutCallback();
      return null;
    }
  }

  /// Create new user's profile in db
  Future<String> signUp(User userModel,
      {GlobalKey<ScaffoldState> scaffoldKey, String password}) async {
    try {
      loading = true;
      final AuthResult result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: userModel.email,
        password: password,
      );
      user = result.user;
      authenticationStatus = AuthenticationStatus.LOGGED_IN;
      kAnalytics.logSignUp(signUpMethod: 'register');
      final UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = userModel.displayName;
      updateInfo.photoUrl = userModel.profilePic;
      await result.user.updateProfile(updateInfo);
      _userModel = userModel;
      _userModel.key = user.uid;
      _userModel.userId = user.uid;
      createUser(_userModel, newUser: true);
      return user.uid;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'signUp');
      customSnackBar(scaffoldKey, error.message as String);
      return null;
    }
  }

  /// `Create` and `Update` user
  /// IF `newUser` is true new user is created
  /// Else existing user will update with new values
  void createUser(User user, {bool newUser = false}) {
    if (newUser) {
      // Create username by the combination of name and id
      user.userName = getUserName(id: user.userId, name: user.displayName);
      kAnalytics.logEvent(name: 'create_newUser');

      // Time at which user is created
      user.createdAt = DateTime.now().toUtc().toString();
    }
    kfirestore
        .collection(USERS_COLLECTION)
        .document(user.userId)
        .setData(user.toJson());
    _userModel = user;
    if (_profileUserModelList != null) {
      _profileUserModelList.last = _userModel;
    }
    loading = false;
  }

  /// Fetch current user profile
  Future<FirebaseUser> getCurrentUser() async {
    try {
      loading = true;
      logEvent('get_currentUSer');
      user = await _firebaseAuth.currentUser();
      if (user != null) {
        authenticationStatus = AuthenticationStatus.LOGGED_IN;
        userId = user.uid;
        getProfileUser();
      } else {
        authenticationStatus = AuthenticationStatus.NOT_LOGGED_IN;
      }
      loading = false;
      return user;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getCurrentUser');
      authenticationStatus = AuthenticationStatus.NOT_LOGGED_IN;
      return null;
    }
  }

  /// Reload user to get refresh user data
  Future<void> reloadUser() async {
    await user.reload();
    user = await _firebaseAuth.currentUser();
    if (user.isEmailVerified) {
      userModel.isVerified = true;
      // If user verifed his email
      // Update user in firebase realtime database
      createUser(userModel);
      cprint('User email verification complete');
      logEvent(
        'email_verification_complete',
        parameter: <String, dynamic>{userModel.userName: user.email},
      );
    }
  }

  /// Send email verification link to email2
  Future<void> sendEmailVerification(
      GlobalKey<ScaffoldState> scaffoldKey) async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification().then((_) {
      logEvent(
        'email_verifcation_sent',
        parameter: <String, dynamic>{userModel.displayName: user.email},
      );
      customSnackBar(
        scaffoldKey,
        'An email verification link is send to your email.',
      );
    }).catchError((dynamic error) {
      cprint(error.message, errorIn: 'sendEmailVerification');
      logEvent(
        'email_verifcation_block',
        parameter: <String, dynamic>{userModel.displayName: user.email},
      );
      customSnackBar(
        scaffoldKey,
        error.message as String,
      );
    });
  }

  /// Check if user's email is verified
  Future<bool> isEmailVerified() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  /// Send password reset link to email
  Future<void> forgetPassword(String email,
      {GlobalKey<ScaffoldState> scaffoldKey}) async {
    try {
      await _firebaseAuth
          .sendPasswordResetEmail(email: email)
          .then((void value) {
        customSnackBar(scaffoldKey,
            'A reset password link is sent yo your mail.You can reset your password from there');
        logEvent('forgot+password');
      }).catchError((dynamic error) {
        cprint(error.message);
        return false;
      });
    } catch (error) {
      customSnackBar(scaffoldKey, error.message as String);
      return Future<bool>.value(false);
    }
  }

  /// `Update user` profile
  Future<void> updateUserProfile(User userModel, {File image}) async {
    try {
      if (image == null) {
        createUser(userModel);
      } else {
        final StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('user/profile/${path.basename(image.path)}');
        final StorageUploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.onComplete.then((StorageTaskSnapshot value) {
          storageReference.getDownloadURL().then<void>((dynamic fileURL) async {
            print(fileURL);
            final UserUpdateInfo updateInfo = UserUpdateInfo();
            updateInfo.displayName = userModel?.displayName ?? user.displayName;
            updateInfo.photoUrl = fileURL as String;
            await user.updateProfile(updateInfo);
            if (userModel != null) {
              userModel.profilePic = fileURL as String;
              createUser(userModel);
            } else {
              _userModel.profilePic = fileURL as String;
              createUser(_userModel);
            }
          });
        });
      }
      logEvent('update_user');
    } catch (error) {
      cprint(error, errorIn: 'updateUserProfile');
    }
  }

  /// Fetch user profile `detail` whoose userId is passed
  /// If `userProfileId` is null then logged in user's profile will fetched
  Future<void> getProfileUser({String userProfileId}) async {
    try {
      loading = true;
      _profileUserModelList ??= <User>[];
      userProfileId = userProfileId ?? user.uid;
      final DocumentSnapshot documentSnapshot =
          await _userCollection.document(userProfileId).get();

      if (documentSnapshot.data != null) {
        _profileUserModelList.add(User.fromJson(documentSnapshot.data));

        /// Get follower list
        final List<String> followers = await getfollowersList(userProfileId);
        _profileUserModelList.last.followersList = followers;
        _profileUserModelList.last.followers = followers.length;

        /// Get following list
        final List<String> followingUsers =
            await getfollowingList(userProfileId);
        _profileUserModelList.last.followingList = followingUsers;
        _profileUserModelList.last.following = followingUsers.length;
        if (userProfileId == user.uid) {
          _userModel = _profileUserModelList.last;
          _userModel.isVerified = user.isEmailVerified;

          if (!user.isEmailVerified) {
            // Check if logged in user verified his email address or not
            reloadUser();
          }
          if (_userModel.fcmToken == null) {
            updateFCMToken();
          }
        }

        logEvent('get_profile');
      }

      loading = false;
    } catch (error) {
      loading = false;
      cprint(error, errorIn: 'getProfileUser');
    }
  }

  /// if firebase token not available in profile
  /// Then get token from firebase and save it to profile
  /// When someone sends you a message FCM token is used
  void updateFCMToken() {
    if (_userModel == null) {
      return;
    }
    getProfileUser();
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      _userModel.fcmToken = token;
      createUser(_userModel);
    });
  }

  Future<List<String>> getfollowersList(String userId) async {
    final List<String> followers = <String>[];
    final QuerySnapshot querySnapshot = await _userCollection
        .document(userId)
        .collection(FOLLOWER_COLLECTION)
        .getDocuments();
    if (querySnapshot != null && querySnapshot.documents.isNotEmpty) {
      querySnapshot.documents.first.data['data'].forEach((String x) {
        followers.add(x);
      });
    }
    return followers;
  }

  Future<List<String>> getfollowingList(String userId) async {
    final List<String> follower = <String>[];
    final QuerySnapshot querySnapshot = await _userCollection
        .document(userId)
        .collection(FOLLOWING_COLLECTION)
        .getDocuments();
    if (querySnapshot != null && querySnapshot.documents.isNotEmpty) {
      querySnapshot.documents.first.data['data'].forEach((String x) {
        follower.add(x);
      });
    }
    return follower;
  }

  /// Follow / Unfollow user
  ///
  /// If `removeFollower` is true then remove user from follower list
  ///
  /// If `removeFollower` is false then add user to follower list
  void followUser({bool removeFollower = false}) {
    /// `userModel` is user who is looged-in app.
    /// `profileUserModel` is user whoose profile is open in app.
    try {
      if (removeFollower) {
        /// If logged-in user `alredy follow `profile user then
        /// 1.Remove logged-in user from profile user's `follower` list
        /// 2.Remove profile user from logged-in user's `following` list
        profileUserModel.followersList.remove(userModel.userId);

        /// Remove profile user from logged-in user's following list
        userModel.followingList.remove(profileUserModel.userId);
        cprint('user removed from following list', event: 'remove_follow');
      } else {
        /// if logged in user is `not following` profile user then
        /// 1.Add logged in user to profile user's `follower` list
        /// 2. Add profile user to logged in user's `following` list
        profileUserModel.followersList ??= <String>[];
        profileUserModel.followersList.add(userModel.userId);
        // Adding profile user to logged-in user's following list
        userModel.followingList ??= <String>[];
        userModel.followingList.add(profileUserModel.userId);
      }
      // update profile user's user follower count
      profileUserModel.followers = profileUserModel.followersList.length;
      // update logged-in user's following count
      userModel.following = userModel.followingList.length;

      try {
        final Map<String, dynamic> updateWithTimestamp = <String, dynamic>{
          'data': FieldValue.arrayUnion(profileUserModel.followersList)
        };
        _userCollection
            .document(profileUserModel.userId)
            .collection(FOLLOWER_COLLECTION)
            .document(FOLLOWER_COLLECTION)
            .setData(updateWithTimestamp);

        _userCollection
            .document(userModel.userId)
            .collection(FOLLOWING_COLLECTION)
            .document(FOLLOWING_COLLECTION)
            .setData(<String, dynamic>{
          'data': FieldValue.arrayUnion(userModel.followingList)
        });
      } on PlatformException catch (error) {
        cprint(error.message, errorIn: 'Updateing Follow');
      } on MissingPluginException catch (error) {
        cprint(error.message, errorIn: 'Missing plugin Follow');
      }
      cprint('user added to following list', event: 'add_follow');
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: 'followUser');
    }
  }

  /// Trigger when logged-in user's profile change or updated
  /// Firebase event callback for profile update
  void _onProfileChanged(DocumentSnapshot event) {
    if (event.data != null) {
      final User updatedUser = User.fromJson(event.data);
      if (updatedUser.userId == user.uid) {
        _userModel = updatedUser;
      }
      cprint('User Updated');
      notifyListeners();
    }
  }
}
