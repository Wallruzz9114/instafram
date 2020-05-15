import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/models/feed.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:instafram/src/states/feed_state.dart';
import 'package:provider/provider.dart';

class TweetBottomSheet {
  Material tweetOptionIcon(BuildContext context, Feed model, TweetType type) =>
      customInkWell(
        radius: BorderRadius.circular(20),
        context: context,
        onPressed: () {
          _openbottomSheet(context, type, model);
        },
        child: Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: customIcon(
            context,
            icon: AppIcon.arrowDown,
            istwitterIcon: true,
            iconColor: AppColor.lightGrey,
          ),
        ),
      );

  Future<void> _openbottomSheet(
      BuildContext context, TweetType type, Feed model) async {
    final AuthenticationState authState =
        Provider.of<AuthenticationState>(context, listen: false);
    final bool isMyTweet = authState.userId == model.userId;
    final Future<Container> showModalBottomSheet2 =
        showModalBottomSheet<Container>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 5, bottom: 0),
          height: fullHeight(context) *
              (type == TweetType.Tweet
                  ? (isMyTweet ? .25 : .44)
                  : (isMyTweet ? .38 : .52)),
          width: fullWidth(context),
          decoration: BoxDecoration(
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: type == TweetType.Tweet
              ? _tweetOptions(context, isMyTweet, model, type)
              : _tweetDetailOptions(context, isMyTweet, model, type),
        );
      },
    );
    await showModalBottomSheet2;
  }

  Column _tweetDetailOptions(
          BuildContext context, bool isMyTweet, Feed model, TweetType type) =>
      Column(
        children: <Widget>[
          Container(
            width: fullWidth(context) * .1,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          _widgetBottomSheetRow(
            context,
            AppIcon.link,
            text: 'Copy link to tweet',
          ),
          if (isMyTweet)
            _widgetBottomSheetRow(
              context,
              AppIcon.unFollow,
              text: 'Pin to profile',
            )
          else
            _widgetBottomSheetRow(
              context,
              AppIcon.unFollow,
              text: 'Unfollow ${model.user.userName}',
            ),
          if (isMyTweet)
            _widgetBottomSheetRow(
              context,
              AppIcon.delete,
              text: 'Delete Tweet',
              onPressed: () {
                _deleteTweet(
                  context,
                  type,
                  model.key,
                  parentkey: model.parentkey,
                );
              },
              isEnable: true,
            )
          else
            Container(),
          if (isMyTweet)
            Container()
          else
            _widgetBottomSheetRow(
              context,
              AppIcon.mute,
              text: 'Mute ${model.user.userName}',
            ),
          _widgetBottomSheetRow(
            context,
            AppIcon.mute,
            text: 'Mute this convertion',
          ),
          _widgetBottomSheetRow(
            context,
            AppIcon.viewHidden,
            text: 'View hidden replies',
          ),
          if (isMyTweet)
            Container()
          else
            _widgetBottomSheetRow(
              context,
              AppIcon.block,
              text: 'Block ${model.user.userName}',
            ),
          if (isMyTweet)
            Container()
          else
            _widgetBottomSheetRow(
              context,
              AppIcon.report,
              text: 'Report Tweet',
            ),
        ],
      );

  Widget _tweetOptions(
      BuildContext context, bool isMyTweet, Feed model, TweetType type) {
    return Column(
      children: <Widget>[
        Container(
          width: fullWidth(context) * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        _widgetBottomSheetRow(
          context,
          AppIcon.link,
          text: 'Copy link to tweet',
        ),
        if (isMyTweet)
          _widgetBottomSheetRow(
            context,
            AppIcon.thumbpinFill,
            text: 'Pin to profile',
          )
        else
          _widgetBottomSheetRow(
            context,
            AppIcon.sadFace,
            text: 'Not interested in this',
          ),
        if (isMyTweet)
          _widgetBottomSheetRow(
            context,
            AppIcon.delete,
            text: 'Delete Tweet',
            onPressed: () {
              _deleteTweet(
                context,
                type,
                model.key,
                parentkey: model.parentkey,
              );
            },
            isEnable: true,
          )
        else
          Container(),
        if (isMyTweet)
          Container()
        else
          _widgetBottomSheetRow(
            context,
            AppIcon.unFollow,
            text: 'Unfollow ${model.user.userName}',
          ),
        if (isMyTweet)
          Container()
        else
          _widgetBottomSheetRow(
            context,
            AppIcon.mute,
            text: 'Mute ${model.user.userName}',
          ),
        if (isMyTweet)
          Container()
        else
          _widgetBottomSheetRow(
            context,
            AppIcon.block,
            text: 'Block ${model.user.userName}',
          ),
        if (isMyTweet)
          Container()
        else
          _widgetBottomSheetRow(
            context,
            AppIcon.report,
            text: 'Report Tweet',
          ),
      ],
    );
  }

  Expanded _widgetBottomSheetRow(BuildContext context, int icon,
          {String text, Function onPressed, bool isEnable = false}) =>
      Expanded(
        child: customInkWell(
          context: context,
          onPressed: () {
            if (onPressed != null)
              onPressed();
            else {
              Navigator.pop(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                customIcon(
                  context,
                  icon: icon,
                  istwitterIcon: true,
                  size: 25,
                  paddingIcon: 8,
                  iconColor: isEnable ? AppColor.darkGrey : AppColor.lightGrey,
                ),
                const SizedBox(width: 15),
                customText(
                  text,
                  context: context,
                  style: TextStyle(
                    color: isEnable ? AppColor.secondary : AppColor.lightGrey,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
        ),
      );

  void _deleteTweet(BuildContext context, TweetType type, String tweetId,
      {String parentkey}) {
    final FeedState state = Provider.of<FeedState>(context, listen: false);
    state.deleteTweet(tweetId, type, parentkey: parentkey);
    // CLose bottom sheet
    Navigator.of(context).pop();
    if (type == TweetType.Detail) {
      // Close Tweet detail page
      Navigator.of(context).pop();
      // Remove last tweet from tweet detail stack page
      state.removeLastTweetDetail(tweetId);
    }
  }

  Future<void> openRetweetbottomSheet(
      BuildContext context, TweetType type, Feed model) async {
    await showModalBottomSheet<Container>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 5, bottom: 0),
          height: 130,
          width: fullWidth(context),
          decoration: BoxDecoration(
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: _retweet(context, model, type),
        );
      },
    );
  }

  Widget _retweet(BuildContext context, Feed model, TweetType type) => Column(
        children: <Widget>[
          Container(
            width: fullWidth(context) * .1,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          _widgetBottomSheetRow(
            context,
            AppIcon.retweet,
            text: 'Retweet',
          ),
          _widgetBottomSheetRow(
            context,
            AppIcon.edit,
            text: 'Retweet with comment',
            isEnable: true,
            onPressed: () {
              final FeedState state =
                  Provider.of<FeedState>(context, listen: false);
              // Prepare current Tweet model to reply
              state.setTweetToReply = model;
              Navigator.pop(context);

              /// `/ComposeTweetPage/retweet` route is used to identify that tweet is going to be retweet.
              /// To simple reply on any `Tweet` use `ComposeTweetPage` route.
              Navigator.of(context).pushNamed('/ComposeTweetPage/retweet');
            },
          )
        ],
      );
}
