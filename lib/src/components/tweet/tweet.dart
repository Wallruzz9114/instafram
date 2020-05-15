import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/shared/custom_url_text.dart';
import 'package:instafram/src/components/shared/title_text.dart';
import 'package:instafram/src/components/tweet/parent_tweet.dart';
import 'package:instafram/src/components/tweet/retweet.dart';
import 'package:instafram/src/components/tweet/tweet_icons_row.dart';
import 'package:instafram/src/components/tweet/tweet_image.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/models/feed.dart';
import 'package:instafram/src/states/feed_state.dart';
import 'package:provider/provider.dart';

class Tweet extends StatelessWidget {
  const Tweet({
    Key key,
    this.model,
    this.trailing,
    this.type = TweetType.Tweet,
    this.isDisplayOnProfile = false,
  }) : super(key: key);

  final Feed model;
  final Widget trailing;
  final TweetType type;
  final bool isDisplayOnProfile;

  void onLongPressedTweet(BuildContext context) {
    if (type == TweetType.Detail || type == TweetType.ParentTweet) {
      final ClipboardData text = ClipboardData(text: model.description);
      Clipboard.setData(text);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: InstaframColor.black,
          content: const Text('Tweet copied to clipboard'),
        ),
      );
    }
  }

  void onTapTweet(BuildContext context) {
    final FeedState feedstate = Provider.of<FeedState>(context, listen: false);
    if (type == TweetType.Detail || type == TweetType.ParentTweet) {
      return;
    }
    if (type == TweetType.Tweet && !isDisplayOnProfile) {
      feedstate.clearAllDetailAndReplyTweetStack();
    }
    feedstate.getpostDetailFromDatabase(null, model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + model.key);
  }

  @override
  Stack build(BuildContext context) => Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          /// Left vertical bar of a tweet
          if (type != TweetType.ParentTweet)
            const SizedBox.shrink()
          else
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 38,
                  top: 75,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(width: 3.0, color: Colors.grey.shade400),
                  ),
                ),
              ),
            ),
          InkWell(
            onLongPress: () {
              onLongPressedTweet(context);
            },
            onTap: () {
              onTapTweet(context);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: type == TweetType.Tweet || type == TweetType.Reply
                        ? 12
                        : 0,
                  ),
                  child: type == TweetType.Tweet || type == TweetType.Reply
                      ? _TweetBody(
                          isDisplayOnProfile: isDisplayOnProfile,
                          model: model,
                          trailing: trailing,
                          type: type,
                        )
                      : _TweetDetailBody(
                          isDisplayOnProfile: isDisplayOnProfile,
                          model: model,
                          trailing: trailing,
                          type: type,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: TweetImage(
                    model: model,
                    type: type,
                  ),
                ),
                if (model.childRetwetkey == null)
                  const SizedBox.shrink()
                else
                  RetweetWidget(
                    childRetwetkey: model.childRetwetkey,
                    type: type,
                    isImageAvailable:
                        model.imagePath != null && model.imagePath.isNotEmpty,
                  ),
                Padding(
                  padding:
                      EdgeInsets.only(left: type == TweetType.Detail ? 10 : 60),
                  child: TweetIconsRow(
                    type: type,
                    model: model,
                    isTweetDetail: type == TweetType.Detail,
                    iconColor: Theme.of(context).textTheme.caption.color,
                    iconEnableColor: InstaframColor.ceriseRed,
                    size: 20,
                  ),
                ),
                if (type == TweetType.ParentTweet)
                  const SizedBox.shrink()
                else
                  const Divider(height: .5, thickness: .5)
              ],
            ),
          ),
        ],
      );
}

class _TweetBody extends StatelessWidget {
  const _TweetBody(
      {Key key, this.model, this.trailing, this.type, this.isDisplayOnProfile})
      : super(key: key);

  final Feed model;
  final Widget trailing;
  final TweetType type;
  final bool isDisplayOnProfile;

  @override
  Widget build(BuildContext context) {
    final int descriptionFontSize = type == TweetType.Tweet
        ? 15
        : type == TweetType.Detail || type == TweetType.ParentTweet ? 18 : 14;
    final FontWeight descriptionFontWeight =
        type == TweetType.Tweet || type == TweetType.Tweet
            ? FontWeight.w400
            : FontWeight.w400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(width: 10),
        Container(
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              // If tweet is displaying on someone's profile then no need to navigate to same user's profile again.
              if (isDisplayOnProfile) {
                return;
              }
              Navigator.of(context).pushNamed('/ProfilePage/' + model?.userId);
            },
            child: customImage(context, model.user.profilePic),
          ),
        ),
        const SizedBox(width: 20),
        Container(
          width: fullWidth(context) - 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: 0, maxWidth: fullWidth(context) * .5),
                          child: TitleText(model.user.displayName,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 3),
                        if (model.user.isVerified)
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
                        SizedBox(
                          width: model.user.isVerified ? 5 : 0,
                        ),
                        Flexible(
                          child: customText(
                            model.user.userName,
                            style: userNameStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        customText('· ${getChatTime(model.createdAt)}',
                            style: userNameStyle),
                      ],
                    ),
                  ),
                  Container(child: trailing ?? const SizedBox()),
                ],
              ),
              CustomUrlText(
                text: model.description,
                onHashTagPressed: (String tag) {
                  cprint(tag);
                },
                style: TextStyle(
                    color: Colors.black,
                    fontSize: descriptionFontSize.toDouble(),
                    fontWeight: descriptionFontWeight),
                urlStyle: TextStyle(
                    color: Colors.blue,
                    fontSize: descriptionFontSize.toDouble(),
                    fontWeight: descriptionFontWeight),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}

class _TweetDetailBody extends StatelessWidget {
  const _TweetDetailBody(
      {Key key, this.model, this.trailing, this.type, this.isDisplayOnProfile})
      : super(key: key);

  final Feed model;
  final Widget trailing;
  final TweetType type;
  final bool isDisplayOnProfile;

  @override
  Column build(BuildContext context) {
    final double descriptionFontSize = type == TweetType.Tweet
        ? getDimention(context, 15)
        : type == TweetType.Detail
            ? getDimention(context, 18)
            : type == TweetType.ParentTweet ? getDimention(context, 14) : 10;

    final FontWeight descriptionFontWeight =
        type == TweetType.Tweet || type == TweetType.Tweet
            ? FontWeight.w300
            : FontWeight.w400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (model.parentkey != null &&
            model.childRetwetkey == null &&
            type != TweetType.ParentTweet)
          ParentTweet(
              childRetwetkey: model.parentkey,
              isImageAvailable: false,
              trailing: trailing)
        else
          const SizedBox.shrink(),
        Container(
          width: fullWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/ProfilePage/' + model?.userId);
                  },
                  child: customImage(context, model.user.profilePic),
                ),
                title: Row(
                  children: <Widget>[
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: 0, maxWidth: fullWidth(context) * .5),
                      child: TitleText(model.user.displayName,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 3),
                    if (model.user.isVerified)
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
                    SizedBox(
                      width: model.user.isVerified ? 5 : 0,
                    ),
                  ],
                ),
                subtitle: customText(model.user.userName, style: userNameStyle),
                trailing: trailing,
              ),
              Padding(
                padding: type == TweetType.ParentTweet
                    ? const EdgeInsets.only(left: 80, right: 16)
                    : const EdgeInsets.symmetric(horizontal: 16),
                child: CustomUrlText(
                  text: model.description,
                  onHashTagPressed: (String tag) {
                    cprint(tag);
                  },
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: descriptionFontSize,
                    fontWeight: descriptionFontWeight,
                  ),
                  urlStyle: TextStyle(
                    color: Colors.blue,
                    fontSize: descriptionFontSize,
                    fontWeight: descriptionFontWeight,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
