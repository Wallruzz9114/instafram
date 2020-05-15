import 'package:flutter/material.dart';
import 'package:instafram/src/components/tweet/tweet.dart';
import 'package:instafram/src/components/tweet/unavailable_tweet.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/models/feed.dart';
import 'package:instafram/src/states/feed_state.dart';
import 'package:provider/provider.dart';

class ParentTweet extends StatelessWidget {
  const ParentTweet(
      {Key key,
      this.childRetwetkey,
      this.type,
      this.isImageAvailable,
      this.trailing})
      : super(key: key);

  final String childRetwetkey;
  final TweetType type;
  final Widget trailing;
  final bool isImageAvailable;

  void onTweetPressed(BuildContext context, Feed model) {
    final FeedState feedstate = Provider.of<FeedState>(context, listen: false);
    feedstate.getpostDetailFromDatabase(null, model: model);
    Navigator.of(context).pushNamed('/FeedPostDetail/' + model.key);
  }

  @override
  Widget build(BuildContext context) {
    final FeedState feedstate = Provider.of<FeedState>(context, listen: false);
    final FutureBuilder<Feed> futureBuilder = FutureBuilder<Feed>(
      future: feedstate.fetchTweet(childRetwetkey),
      builder: (BuildContext context, AsyncSnapshot<Feed> snapshot) {
        if (snapshot.hasData) {
          return Tweet(
              model: snapshot.data,
              type: TweetType.ParentTweet,
              trailing: trailing);
        }
        if ((snapshot.connectionState == ConnectionState.done ||
                snapshot.connectionState == ConnectionState.waiting) &&
            !snapshot.hasData) {
          return UnavailableTweet(
            snapshot: snapshot,
            type: type,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
    return futureBuilder;
  }
}
