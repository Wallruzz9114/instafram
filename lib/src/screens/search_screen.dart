import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_app_bar.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/shared/ripple_button.dart';
import 'package:instafram/src/components/shared/title_text.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/states/search_state.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<StatefulWidget> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final SearchState state = Provider.of<SearchState>(context);
      state.resetFilterList();
    });
    super.initState();
  }

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/TrendsPage');
  }

  @override
  Scaffold build(BuildContext context) {
    final SearchState state = Provider.of<SearchState>(context);
    final List<User> list = state.userlist;
    return Scaffold(
      appBar: CustomAppBar(
        scaffoldKey: widget.scaffoldKey,
        icon: AppIcon.settings,
        onActionPressed: onSettingIconPressed,
        onSearchChanged: (text) {
          state.filterByUsername(text);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          state.getDataFromDatabase();
          final Future<bool> future = Future<bool>.value(true);
          return future;
        },
        child: ListView.separated(
          addAutomaticKeepAlives: false,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) =>
              _UserTile(user: list[index]),
          separatorBuilder: (_, int index) => const Divider(height: 0),
          itemCount: list?.length ?? 0,
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({Key key, this.user}) : super(key: key);
  final User user;

  @override
  RippleButton build(BuildContext context) => RippleButton(
        onPressed: () {
          kAnalytics.logViewSearchResults(searchTerm: user.userName);
          Navigator.of(context).pushNamed('/ProfilePage/' + user?.userId);
        },
        child: Container(
          color: InstaframColor.white,
          child: ListTile(
            leading: customImage(context, user.profilePic, height: 40),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: TitleText(user.displayName,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 3),
                if (user.isVerified)
                  customIcon(
                    context,
                    icon: AppIcon.blueTick,
                    istwitterIcon: true,
                    iconColor: AppColor.primary,
                    size: 13,
                    paddingIcon: 3,
                  )
                else
                  const SizedBox(width: 0),
              ],
            ),
            subtitle: Text(user.userName),
          ),
        ),
      );
}
