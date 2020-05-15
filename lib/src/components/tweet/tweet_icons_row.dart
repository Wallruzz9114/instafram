import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/tweet/tweet_bottom_sheet.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/custom_route.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/models/feed.dart';
import 'package:instafram/src/screens/users/users_list_screen.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:instafram/src/states/feed_state.dart';
import 'package:provider/provider.dart';

class TweetIconsRow extends StatelessWidget {
  const TweetIconsRow({
    Key key,
    this.model,
    this.iconColor,
    this.iconEnableColor,
    this.size,
    this.isTweetDetail = false,
    this.type,
  }) : super(key: key);

  final Feed model;
  final Color iconColor;
  final Color iconEnableColor;
  final double size;
  final bool isTweetDetail;
  final TweetType type;

  Container _likeCommentsIcons(BuildContext context, Feed model) {
    final AuthenticationState authState =
        Provider.of<AuthenticationState>(context, listen: false);
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 0, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(width: 20),
          _iconWidget(
            context,
            text: isTweetDetail ? '' : model.commentCount.toString(),
            icon: AppIcon.reply,
            iconColor: iconColor,
            size: size ?? 20,
            onPressed: () {
              final FeedState state =
                  Provider.of<FeedState>(context, listen: false);
              state.setTweetToReply = model;
              Navigator.of(context).pushNamed('/ComposeTweetPage');
            },
          ),
          _iconWidget(context,
              text: isTweetDetail ? '' : model.retweetCount.toString(),
              icon: AppIcon.retweet,
              iconColor: iconColor,
              size: size ?? 20, onPressed: () {
            TweetBottomSheet().openRetweetbottomSheet(context, type, model);
          }),
          _iconWidget(
            context,
            text: isTweetDetail ? '' : model.likeCount.toString(),
            icon: model.likeList
                    .any((String userId) => userId == authState.userId)
                ? AppIcon.heartFill
                : AppIcon.heartEmpty,
            onPressed: () {
              addLikeToTweet(context);
            },
            iconColor: model.likeList
                    .any((String userId) => userId == authState.userId)
                ? iconEnableColor
                : iconColor,
            size: size ?? 20,
          ),
          _iconWidget(context, text: '', icon: null, sysIcon: Icons.share,
              onPressed: () {
            share(model.description,
                subject: '${model.user.displayName}\'s post');
          }, iconColor: iconColor, size: size ?? 20),
        ],
      ),
    );
  }

  Expanded _iconWidget(BuildContext context,
          {String text,
          int icon,
          Function onPressed,
          IconData sysIcon,
          Color iconColor,
          double size = 20}) =>
      Expanded(
        child: Container(
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  if (onPressed != null) {
                    onPressed();
                  }
                },
                icon: sysIcon != null
                    ? Icon(sysIcon, color: iconColor, size: size)
                    : customIcon(
                        context,
                        size: size,
                        icon: icon,
                        istwitterIcon: true,
                        iconColor: iconColor,
                      ),
              ),
              customText(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  fontSize: size - 5,
                ),
                context: context,
              ),
            ],
          ),
        ),
      );

  Column _timeWidget(BuildContext context) => Column(
        children: <Widget>[
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const SizedBox(width: 5),
              customText(getPostTime2(model.createdAt), style: textStyle14),
              const SizedBox(width: 10),
              customText('Fwitter for Android',
                  style: TextStyle(color: Theme.of(context).primaryColor))
            ],
          ),
          const SizedBox(height: 5),
        ],
      );

  Column _likeCommentWidget(BuildContext context) {
    final bool isLikeAvailable = model.likeCount > 0;
    final bool isRetweetAvailable = model.retweetCount > 0;
    final bool isLikeRetweetAvailable = isRetweetAvailable || isLikeAvailable;
    return Column(
      children: <Widget>[
        const Divider(
          endIndent: 10,
          height: 0,
        ),
        AnimatedContainer(
          padding:
              EdgeInsets.symmetric(vertical: isLikeRetweetAvailable ? 12 : 0),
          duration: const Duration(milliseconds: 500),
          child: !isLikeRetweetAvailable
              ? const SizedBox.shrink()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    if (!isRetweetAvailable)
                      const SizedBox.shrink()
                    else
                      customText(model.retweetCount.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    if (!isRetweetAvailable)
                      const SizedBox.shrink()
                    else
                      const SizedBox(width: 5),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: customText('Retweets', style: subtitleStyle),
                      crossFadeState: !isRetweetAvailable
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 800),
                    ),
                    if (!isRetweetAvailable)
                      const SizedBox.shrink()
                    else
                      const SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        onLikeTextPressed(context);
                      },
                      child: AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Row(
                          children: <Widget>[
                            customSwitcherWidget(
                              duraton: const Duration(milliseconds: 300),
                              child: customText(model.likeCount.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  key: ValueKey<int>(model.likeCount)),
                            ),
                            const SizedBox(width: 5),
                            customText('Likes', style: subtitleStyle)
                          ],
                        ),
                        crossFadeState: !isLikeAvailable
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                      ),
                    )
                  ],
                ),
        ),
        if (!isLikeRetweetAvailable)
          const SizedBox.shrink()
        else
          const Divider(
            endIndent: 10,
            height: 0,
          ),
      ],
    );
  }

  void addLikeToTweet(BuildContext context) {
    final FeedState state = Provider.of<FeedState>(context, listen: false);
    final AuthenticationState authState =
        Provider.of<AuthenticationState>(context, listen: false);
    state.addLikeToTweet(model, authState.userId);
  }

  void onLikeTextPressed(BuildContext context) {
    Navigator.of(context).push(
      CustomRoute<bool>(
        builder: (BuildContext context) => UsersListScreen(
          pageTitle: 'Liked by',
          userIdsList: model.likeList.map((String userId) => userId).toList(),
        ),
      ),
    );
  }

  @override
  Container build(BuildContext context) => Container(
        child: Column(
          children: <Widget>[
            if (isTweetDetail) _timeWidget(context) else const SizedBox(),
            if (isTweetDetail)
              _likeCommentWidget(context)
            else
              const SizedBox(),
            _likeCommentsIcons(context, model)
          ],
        ),
      );
}
