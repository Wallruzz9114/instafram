import 'package:flutter/material.dart';
import 'package:instafram/src/components/bottom_menu_bar.dart';
import 'package:instafram/src/components/side_bar_menu.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/screens/feed/feed_screen.dart';
import 'package:instafram/src/screens/search_screen.dart';
import 'package:instafram/src/states/application_state.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:instafram/src/states/feed_state.dart';
import 'package:instafram/src/states/notification_state.dart';
import 'package:instafram/src/states/search_state.dart';
import 'package:instafram/src/states/user_message_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  int pageIndex = 0;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ApplicationState state =
          Provider.of<ApplicationState>(context, listen: false);
      state.setpageIndex = 0;
      initTweets();
      initProfile();
      initSearch();
      initNotificaiton();
      initChat();
    });

    super.initState();
  }

  void initTweets() {
    final FeedState state = Provider.of<FeedState>(context, listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }

  void initProfile() {
    final AuthenticationState state =
        Provider.of<AuthenticationState>(context, listen: false);
    state.databaseInit();
  }

  void initSearch() {
    final SearchState searchState =
        Provider.of<SearchState>(context, listen: false);
    searchState.getDataFromDatabase();
  }

  void initNotificaiton() {
    final NotificationState state =
        Provider.of<NotificationState>(context, listen: false);
    final AuthenticationState authstate =
        Provider.of<AuthenticationState>(context, listen: false);
    state.databaseInit(authstate.userId);
    state.getDataFromDatabase(authstate.userId);
    state.initfirebaseService();
  }

  void initChat() {
    final UserMessageState chatState =
        Provider.of<UserMessageState>(context, listen: false);
    final AuthenticationState state =
        Provider.of<AuthenticationState>(context, listen: false);
    chatState.databaseInit(state.userId, state.userId);

    /// It will update fcm token in database
    /// fcm token is required to send firebase notification
    state.updateFCMToken();

    /// It get fcm server key
    /// Server key is required to configure firebase notification
    /// Without fcm server notification can not be sent
    chatState.getFCMServerKey();
  }

  /// On app launch it checks if app is launch by tapping on notification from notification tray
  /// If yes, it checks for  which type of notification is recieve
  /// If notification type is `NotificationType.Message` then chat screen will open
  /// If notification type is `NotificationType.Mention` then user profile will open who taged you in a tweet
  ///
  void _checkNotification() {
    final AuthenticationState authstate =
        Provider.of<AuthenticationState>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final NotificationState state = Provider.of<NotificationState>(context);

      /// Check if user recieve chat notification from firebase
      /// Redirect to chat screen
      /// `notificationSenderId` is a user id who sends you a message
      /// `notificationReciverId` is a your user id.
      if (state.notificationType == NotificationType.Message &&
          state.notificationReciverId == authstate.userModel.userId) {
        state.setNotificationType = null;
        state.getuserDetail(state.notificationSenderId).then((User user) {
          cprint('Opening user chat screen');
          final UserMessageState chatState =
              Provider.of<UserMessageState>(context, listen: false);
          chatState.setChatUser = user;
          Navigator.pushNamed(context, '/ChatScreenPage');
        });
      }

      /// Checks for user tag tweet notification
      /// If you are mentioned in tweet then it redirect to user profile who mentioed you in a tweet
      /// You can check that tweet on his profile timeline
      /// `notificationSenderId` is user id who tagged you in a tweet
      else if (state.notificationType == NotificationType.Mention &&
          state.notificationReciverId == authstate.userModel.userId) {
        state.setNotificationType = null;
        Navigator.of(context)
            .pushNamed('/ProfilePage/' + state.notificationSenderId);
      }
    });
  }

  SafeArea _body() {
    _checkNotification();
    return SafeArea(
      child: Container(
        child: _getPage(Provider.of<ApplicationState>(context).pageIndex),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return FeedScreen(
          scaffoldKey: _scaffoldKey,
          refreshIndicatorKey: refreshIndicatorKey,
        );
        break;
      case 1:
        return SearchScreen(scaffoldKey: _scaffoldKey);
        break;
      // case 2:
      //   return NotificationsScreen(scaffoldKey: _scaffoldKey);
      //   break;
      // case 3:
      //   return UserMessageScreen(scaffoldKey: _scaffoldKey);
      //   break;
      default:
        return FeedScreen(scaffoldKey: _scaffoldKey);
        break;
    }
  }

  @override
  Scaffold build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: const BottomMenubar(),
        drawer: const SideBarMenu(),
        body: _body(),
      );
}
