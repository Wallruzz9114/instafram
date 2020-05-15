import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/shared/custom_url_text.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:instafram/src/states/notification_state.dart';
import 'package:provider/provider.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  Widget _menuHeader() {
    final AuthenticationState state = Provider.of<AuthenticationState>(context);
    if (state.userModel == null) {
      return customInkWell(
        context: context,
        onPressed: () {
          //  Navigator.of(context).pushNamed('/signIn');
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, minHeight: 100),
          child: Center(
            child: Text(
              'Login to continue',
              style: onPrimaryTitleText,
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 56,
              width: 56,
              margin: const EdgeInsets.only(left: 17, top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(28),
                image: DecorationImage(
                  image: customAdvanceNetworkImage(
                    state.userModel.profilePic ?? dummyProfilePic,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                _navigateTo('ProfilePage');
              },
              title: Row(
                children: <Widget>[
                  CustomUrlText(
                    text: state.userModel.displayName ?? '',
                    style: onPrimaryTitleText.copyWith(
                        color: Colors.black, fontSize: 20),
                  ),
                  const SizedBox(width: 3),
                  if (state.userModel.isVerified ?? false)
                    customIcon(context,
                        icon: AppIcon.blueTick,
                        istwitterIcon: true,
                        iconColor: AppColor.primary,
                        size: 18,
                        paddingIcon: 3)
                  else
                    const SizedBox(width: 0),
                ],
              ),
              subtitle: customText(
                state.userModel.userName,
                style: onPrimarySubTitleText.copyWith(
                    color: Colors.black54, fontSize: 15),
              ),
              trailing: customIcon(context,
                  icon: AppIcon.arrowDown,
                  iconColor: AppColor.primary,
                  paddingIcon: 20),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 17),
                  _tappbleText(
                    context,
                    state.userModel.getFollower(),
                    ' Followers',
                    'FollowerListPage',
                  ),
                  const SizedBox(width: 10),
                  _tappbleText(
                    context,
                    state.userModel.getFollowing(),
                    ' Following',
                    'FollowingListPage',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  InkWell _tappbleText(
          BuildContext context, String count, String text, String navigateTo) =>
      InkWell(
        onTap: () {
          final AuthenticationState authstate =
              Provider.of<AuthenticationState>(context, listen: false);
          // authstate.profileFollowingList = [];
          authstate.getProfileUser();
          _navigateTo(navigateTo);
        },
        child: Row(
          children: <Widget>[
            customText(
              '$count ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            customText(
              text,
              style: TextStyle(color: AppColor.darkGrey, fontSize: 17),
            ),
          ],
        ),
      );

  ListTile _menuListRowButton(String title,
          {Function onPressed, int icon, bool isEnable = false}) =>
      ListTile(
        onTap: () {
          if (onPressed != null) {
            onPressed();
          }
        },
        leading: icon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 5),
                child: customIcon(
                  context,
                  icon: icon,
                  size: 25,
                  iconColor: isEnable ? AppColor.darkGrey : AppColor.lightGrey,
                ),
              ),
        title: customText(
          title,
          style: TextStyle(
            fontSize: 20,
            color: isEnable ? AppColor.secondary : AppColor.lightGrey,
          ),
        ),
      );

  Positioned _footer() => Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Column(
          children: <Widget>[
            const Divider(height: 0),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 10,
                  height: 45,
                ),
                customIcon(context,
                    icon: AppIcon.bulbOn,
                    istwitterIcon: true,
                    size: 25,
                    iconColor: InstaframColor.dodgetBlue),
                const Spacer(),
                Image.asset(
                  'assets/images/qr.png',
                  height: 25,
                ),
                const SizedBox(
                  width: 10,
                  height: 45,
                ),
              ],
            ),
          ],
        ),
      );

  void _logOut() {
    final AuthenticationState state =
        Provider.of<AuthenticationState>(context, listen: false);
    final NotificationState notificationDtate =
        Provider.of<NotificationState>(context, listen: false);
    notificationDtate.unsubscribeNotifications(state.userModel.userId);
    Navigator.pop(context);
    state.logoutCallback();
  }

  void _navigateTo(String path) {
    Navigator.pop(context);
    Navigator.of(context).pushNamed('/$path');
  }

  @override
  Drawer build(BuildContext context) => Drawer(
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 45),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    Container(
                      child: _menuHeader(),
                    ),
                    const Divider(),
                    _menuListRowButton('Profile',
                        icon: AppIcon.profile, isEnable: true, onPressed: () {
                      _navigateTo('ProfilePage');
                    }),
                    _menuListRowButton('Lists', icon: AppIcon.lists),
                    _menuListRowButton('Bookamrks', icon: AppIcon.bookmark),
                    _menuListRowButton('Moments', icon: AppIcon.moments),
                    _menuListRowButton('Fwitter ads', icon: AppIcon.twitterAds),
                    const Divider(),
                    _menuListRowButton('Settings and privacy', isEnable: true,
                        onPressed: () {
                      _navigateTo('SettingsAndPrivacyPage');
                    }),
                    _menuListRowButton('Help Center'),
                    const Divider(),
                    _menuListRowButton('Logout',
                        icon: null, onPressed: _logOut, isEnable: true),
                  ],
                ),
              ),
              _footer()
            ],
          ),
        ),
      );
}
