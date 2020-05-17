import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_app_bar.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/empty_list.dart';
import 'package:instafram/src/components/shared/custom_url_text.dart';
import 'package:instafram/src/components/shared/title_text.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/models/feed.dart';
import 'package:instafram/src/models/instafram_notification.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/states/feed_state.dart';
import 'package:instafram/src/states/notification_state.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key key, this.scaffoldKey}) : super(key: key);

  /// scaffoldKey used to open sidebaar drawer
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   var state = Provider.of<NotificationState>(context, listen: false);
    //   var authstate = Provider.of<AuthState>(context, listen: false);
    //   state.getDataFromDatabase(authstate.userId);
    // });
  }

  void onSettingIconPressed(BuildContext context) {
    Navigator.pushNamed(context, '/NotificationsScreen');
  }

  @override
  Scaffold build(BuildContext context) => Scaffold(
        backgroundColor: InstaframColor.mystic,
        appBar: CustomAppBar(
          scaffoldKey: widget.scaffoldKey,
          title: customTitleText('Notifications'),
          icon: AppIcon.settings,
          onActionPressed: onSettingIconPressed,
        ),
        body: const NotificationsScreenBody(),
      );
}

class NotificationsScreenBody extends StatelessWidget {
  const NotificationsScreenBody({Key key}) : super(key: key);

  Widget _notificationRow(BuildContext context, InstaframNotification model,
      bool isFirstNotification) {
    final NotificationState state = Provider.of<NotificationState>(context);
    return FutureBuilder<Feed>(
      future: state.getTweetDetail(model.tweetKey),
      builder: (BuildContext context, AsyncSnapshot<Feed> snapshot) {
        if (snapshot.hasData) {
          return NotificationTile(
            model: snapshot.data,
          );
        } else if (isFirstNotification &&
            (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.active)) {
          return const SizedBox(
            height: 4,
            child: LinearProgressIndicator(),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final NotificationState state = Provider.of<NotificationState>(context);
    final List<InstaframNotification> list = state.notificationList;

    if (list == null || list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'No Notification available yet',
          subTitle: 'When new notifiction found, they\'ll show up here.',
        ),
      );
    }

    return ListView.builder(
      addAutomaticKeepAlives: true,
      itemBuilder: (BuildContext context, int index) =>
          _notificationRow(context, list[index], index == 0),
      itemCount: list.length,
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({Key key, this.model}) : super(key: key);

  final Feed model;

  Column _userList(BuildContext context, List<String> list) {
    // List<String> names = [];
    final int length = list.length;
    List<Widget> avaterList = <Widget>[];
    final int noOfUser = list.length;
    final NotificationState state =
        Provider.of<NotificationState>(context, listen: false);

    if (list != null && list.length > 5) {
      list = list.take(5).toList();
    }

    avaterList = list.map((String userId) {
      return _userAvater(userId, state, (String name) {
        // names.add(name);
      });
    }).toList();

    if (noOfUser > 5) {
      avaterList.add(
        Text(
          ' +${noOfUser - 5}',
          style: subtitleStyle.copyWith(fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const SizedBox(width: 20),
            customIcon(context,
                icon: AppIcon.heartFill,
                iconColor: InstaframColor.ceriseRed,
                istwitterIcon: true,
                size: 25),
            const SizedBox(width: 10),
            Row(children: avaterList),
          ],
        ),
        // names.length > 0 ? Text(names[0]) : SizedBox(),
        Padding(
          padding: const EdgeInsets.only(left: 60, bottom: 5, top: 5),
          child: TitleText(
            '$length people like your Tweet',
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }

  FutureBuilder<User> _userAvater(
          String userId, NotificationState state, ValueChanged<String> name) =>
      FutureBuilder<User>(
        future: state.getuserDetail(userId),
        //  initialData: InitialData,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.hasData) {
            name(snapshot.data.displayName);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/ProfilePage/' + snapshot.data?.userId);
                },
                child:
                    customImage(context, snapshot.data.profilePic, height: 30),
              ),
            );
          } else {
            return Container();
          }
        },
      );

  @override
  Column build(BuildContext context) {
    final String description = model.description.length > 150
        ? model.description.substring(0, 150) + '...'
        : model.description;
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: InstaframColor.white,
          child: ListTile(
            onTap: () {
              final FeedState state =
                  Provider.of<FeedState>(context, listen: false);
              state.getpostDetailFromDatabase(null, model: model);
              Navigator.of(context).pushNamed('/FeedPostDetail/' + model.key);
            },
            title: _userList(context, model.likeList),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 60),
              child: CustomUrlText(
                text: description,
                style: TextStyle(
                  color: AppColor.darkGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 0, thickness: .6)
      ],
    );
  }
}
