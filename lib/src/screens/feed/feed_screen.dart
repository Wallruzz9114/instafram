import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/empty_list.dart';
import 'package:instafram/src/components/shared/custom_screen_loader.dart';
import 'package:instafram/src/components/tweet/tweet.dart';
import 'package:instafram/src/components/tweet/tweet_bottom_sheet.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/models/feed.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:instafram/src/states/feed_state.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key key, this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  Widget _floatingActionButton(BuildContext context) => FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed('/CreateFeedScreen/tweet'),
        child: customIcon(
          context,
          icon: AppIcon.fabTweet,
          istwitterIcon: true,
          iconColor: Theme.of(context).colorScheme.onPrimary,
          size: 25,
        ),
      );

  @override
  Scaffold build(BuildContext context) => Scaffold(
        floatingActionButton: _floatingActionButton(context),
        backgroundColor: InstaframColor.mystic,
        body: SafeArea(
          child: Container(
            height: fullHeight(context),
            width: fullWidth(context),
            child: RefreshIndicator(
              key: refreshIndicatorKey,
              onRefresh: () async {
                /// refresh home page feed
                final FeedState feedState =
                    Provider.of<FeedState>(context, listen: false);
                feedState.getDataFromDatabase();
                return Future<bool>.value(true);
              },
              child: _FeedScreenBody(
                refreshIndicatorKey: refreshIndicatorKey,
                scaffoldKey: scaffoldKey,
              ),
            ),
          ),
        ),
      );
}

class _FeedScreenBody extends StatelessWidget {
  const _FeedScreenBody({Key key, this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;

  Padding _getUserAvatar(BuildContext context) {
    final AuthenticationState authState =
        Provider.of<AuthenticationState>(context);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: customInkWell(
        context: context,
        onPressed: () {
          /// Open up sidebaar drawer on user avatar tap
          scaffoldKey.currentState.openDrawer();
        },
        child:
            customImage(context, authState.userModel?.profilePic, height: 30),
      ),
    );
  }

  @override
  Consumer<FeedState> build(BuildContext context) {
    final AuthenticationState authstate =
        Provider.of<AuthenticationState>(context, listen: false);
    return Consumer<FeedState>(
      builder: (BuildContext context, FeedState state, Widget child) {
        final List<Feed> list = state.getTweetList(authstate.userModel);
        return CustomScrollView(
          slivers: <Widget>[
            child,
            if (state.isBusy && list == null)
              SliverToBoxAdapter(
                child: Container(
                  height: fullHeight(context) - 135,
                  child: CustomScreenLoader(
                    height: double.infinity,
                    width: fullWidth(context),
                    backgroundColor: Colors.white,
                  ),
                ),
              )
            else
              !state.isBusy && list == null
                  ? const SliverToBoxAdapter(
                      child: EmptyList(
                        'No Tweet added yet',
                        subTitle:
                            'When new Tweet added, they\'ll show up here \n Tap tweet button to add new',
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildListDelegate(
                        list.map(
                          (Feed model) {
                            return Container(
                              color: Colors.white,
                              child: Tweet(
                                model: model,
                                trailing: TweetBottomSheet().tweetOptionIcon(
                                  context,
                                  model,
                                  TweetType.Tweet,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    )
          ],
        );
      },
      child: SliverAppBar(
        floating: true,
        elevation: 0,
        leading: _getUserAvatar(context),
        title: customTitleText('Home'),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).appBarTheme.color,
        bottom: PreferredSize(
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
          preferredSize: const Size.fromHeight(0.0),
        ),
      ),
    );
  }
}
