import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/models/feed.dart';
import 'package:instafram/src/states/feed_state.dart';
import 'package:provider/provider.dart';

class TweetImage extends StatelessWidget {
  const TweetImage(
      {Key key, this.model, this.type, this.isRetweetImage = false})
      : super(key: key);

  final Feed model;
  final TweetType type;
  final bool isRetweetImage;

  @override
  AnimatedContainer build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        alignment: Alignment.centerRight,
        child: model.imagePath == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.all(
                    Radius.circular(isRetweetImage ? 0 : 20),
                  ),
                  onTap: () {
                    if (type == TweetType.ParentTweet) {
                      return;
                    }
                    final FeedState state =
                        Provider.of<FeedState>(context, listen: false);
                    // state.getpostDetailFromDatabase(model.key, model: model);
                    state.setTweetToReply = model;
                    Navigator.pushNamed(context, '/ImageViewPge');
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(isRetweetImage ? 0 : 20),
                    ),
                    child: Container(
                      width: fullWidth(context) *
                              (type == TweetType.Detail ? .95 : .8) -
                          8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                      ),
                      child: AspectRatio(
                        aspectRatio: 4 / 3,
                        child: customNetworkImage(model.imagePath,
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
      );
}
