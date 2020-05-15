import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/shared/ripple_button.dart';
import 'package:instafram/src/components/shared/title_text.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:provider/provider.dart';

class UserList extends StatelessWidget {
  const UserList({
    Key key,
    this.list,
    this.emptyScreenText,
    this.emptyScreenSubTileText,
  }) : super(key: key);

  final List<User> list;
  final String emptyScreenText;
  final String emptyScreenSubTileText;

  @override
  ListView build(BuildContext context) {
    final AuthenticationState state =
        Provider.of<AuthenticationState>(context, listen: false);
    final String myId = state.userModel.key;
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return UserTile(
          user: list[index],
          myId: myId,
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(height: 0);
      },
      itemCount: list.length,
    );
    // : LinearProgressIndicator();
  }
}

class UserTile extends StatelessWidget {
  const UserTile({Key key, this.user, this.myId}) : super(key: key);
  final User user;
  final String myId;

  /// Return empty string for default bio
  /// Max length of bio is 100
  String getBio(String bio) {
    if (bio != null && bio.isNotEmpty && bio != 'Edit profile to update bio') {
      if (bio.length > 100) {
        bio = bio.substring(0, 100) + '...';
        return bio;
      } else {
        return bio;
      }
    }
    return null;
  }

  /// Check if user followerlist contain your or not
  /// If your id exist in follower list it mean you are following him
  bool isFollowing() {
    if (user.followersList != null &&
        user.followersList.any((String x) => x == myId)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Container build(BuildContext context) {
    final bool isFollow = isFollowing();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: InstaframColor.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed('/ProfilePage/' + user?.userId);
            },
            leading: RippleButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/ProfilePage/' + user?.userId);
              },
              borderRadius: const BorderRadius.all(Radius.circular(60)),
              child: customImage(context, user.profilePic, height: 55),
            ),
            title: Row(
              children: <Widget>[
                ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: 0, maxWidth: fullWidth(context) * .4),
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
            trailing: RippleButton(
              onPressed: () {},
              splashColor: InstaframColor.dodgetBlue_50.withAlpha(100),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isFollow ? 15 : 20,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isFollow
                      ? InstaframColor.dodgetBlue
                      : InstaframColor.white,
                  border:
                      Border.all(color: InstaframColor.dodgetBlue, width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  isFollow ? 'Following' : 'Follow',
                  style: TextStyle(
                    color: isFollow ? InstaframColor.white : Colors.blue,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          if (getBio(user.bio) == null)
            const SizedBox.shrink()
          else
            Padding(
              padding: const EdgeInsets.only(left: 90),
              child: Text(
                getBio(user.bio),
              ),
            )
        ],
      ),
    );
  }
}
