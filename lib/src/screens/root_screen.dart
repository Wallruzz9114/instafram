import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instafram/src/screens/feed_screen.dart';
import 'package:instafram/src/screens/new_post_screen.dart';
import 'package:instafram/src/screens/notifications_screen.dart';
import 'package:instafram/src/screens/profile_screen.dart';
import 'package:instafram/src/screens/search_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({this.userId});

  final String userId;

  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  PageController _pageController;
  int _currentTab = 0;

  List<BottomNavigationBarItem> _bottomNavigationBarItems() =>
      <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          title: Platform.isAndroid ? const Text('Home') : null,
          icon: Icon(
            Icons.home,
            size: 32.0,
          ),
        ),
        BottomNavigationBarItem(
          title: Platform.isAndroid ? const Text('Search') : null,
          icon: Icon(
            Icons.search,
            size: 32.0,
          ),
        ),
        BottomNavigationBarItem(
          title: Platform.isAndroid ? const Text('Add') : null,
          icon: Icon(
            Icons.photo_camera,
            size: 32.0,
          ),
        ),
        BottomNavigationBarItem(
          title: Platform.isAndroid ? const Text('Notifications') : null,
          icon: Icon(
            Icons.notifications,
            size: 32.0,
          ),
        ),
        BottomNavigationBarItem(
          title: Platform.isAndroid ? const Text('Profile') : null,
          icon: Icon(
            Icons.account_circle,
            size: 32.0,
          ),
        ),
      ];

  Widget _customBottomNavigationBar() => Platform.isIOS
      ? CupertinoTabBar(
          currentIndex: _currentTab,
          onTap: (int index) {
            setState(() {
              _currentTab = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeIn,
            );
          },
          activeColor: Colors.black,
          items: _bottomNavigationBarItems(),
        )
      : BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (int index) {
            setState(() {
              _currentTab = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeIn,
            );
          },
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: _bottomNavigationBarItems(),
        );

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Scaffold build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Instagram',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Billabong',
              fontSize: 35.0,
            ),
          ),
        ),
        body: PageView(
          controller: _pageController,
          children: <Widget>[
            FeedScreen(),
            SearchScreen(),
            NewPostScreen(),
            NotificationsScreen(),
            ProfileScreen(userId: widget.userId)
          ],
          onPageChanged: (int index) {
            setState(() {
              _currentTab = index;
            });
          },
        ),
        bottomNavigationBar: _customBottomNavigationBar(),
      );
}
