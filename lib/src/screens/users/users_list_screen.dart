import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_app_bar.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/notify_text.dart';
import 'package:instafram/src/components/users/users_list.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/states/search_state.dart';
import 'package:provider/provider.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({
    Key key,
    this.pageTitle = '',
    this.appBarIcon,
    this.emptyScreenText,
    this.emptyScreenSubTileText,
    this.userIdsList,
  }) : super(key: key);

  final String pageTitle;
  final String emptyScreenText;
  final String emptyScreenSubTileText;
  final int appBarIcon;
  final List<String> userIdsList;

  @override
  Scaffold build(BuildContext context) {
    List<User> userList;
    return Scaffold(
      backgroundColor: InstaframColor.mystic,
      appBar: CustomAppBar(
          isBackButton: true,
          title: customTitleText(pageTitle),
          icon: appBarIcon),
      body: Consumer<SearchState>(
        builder: (BuildContext context, SearchState state, Widget child) {
          if (userIdsList != null) {
            userList = state.getuserDetail(userIdsList);
          }
          if (!(userList != null && userList.isNotEmpty)) {
            return Container(
              width: fullWidth(context),
              padding: const EdgeInsets.only(top: 0, left: 30, right: 30),
              child: NotifyText(
                title: emptyScreenText,
                subTitle: emptyScreenSubTileText,
              ),
            );
          } else {
            return UserList(
              list: userList,
              emptyScreenText: emptyScreenText,
              emptyScreenSubTileText: emptyScreenSubTileText,
            );
          }
        },
      ),
    );
  }
}
