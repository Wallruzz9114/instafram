import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_app_bar.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/empty_list.dart';
import 'package:instafram/src/components/shared/ripple_button.dart';
import 'package:instafram/src/components/shared/title_text.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/models/message.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:instafram/src/states/search_state.dart';
import 'package:instafram/src/states/user_message_state.dart';
import 'package:provider/provider.dart';

class MessagesListScreen extends StatefulWidget {
  const MessagesListScreen({Key key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _MessagesListScreenState createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  @override
  void initState() {
    final UserMessageState chatState =
        Provider.of<UserMessageState>(context, listen: false);
    final AuthenticationState state =
        Provider.of<AuthenticationState>(context, listen: false);
    chatState.setIsChatScreenOpen = true;

    // chatState.databaseInit(state.profileUserModel.userId,state.userId);
    chatState.getUserchatList(state.user.uid);
    super.initState();
  }

  Widget _body() {
    final UserMessageState state = Provider.of<UserMessageState>(context);
    final SearchState searchState =
        Provider.of<SearchState>(context, listen: false);

    if (state.chatUserList == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'No message available ',
          subTitle:
              'When someone sends you message,User list\'ll show up here \n  To send message tap message button.',
        ),
      );
    } else {
      return ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: state.chatUserList.length,
        itemBuilder: (BuildContext context, int index) => _userCard(
            searchState.userlist.firstWhere(
              (User x) => x.userId == state.chatUserList[index].key,
              orElse: () => User(userName: 'Unknown'),
            ),
            state.chatUserList[index]),
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(height: 0);
        },
      );
    }
  }

  Container _userCard(User model, Message lastMessage) => Container(
        color: Colors.white,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          onTap: () {
            final UserMessageState chatState =
                Provider.of<UserMessageState>(context, listen: false);
            final SearchState searchState =
                Provider.of<SearchState>(context, listen: false);
            chatState.setChatUser = model;

            if (searchState.userlist
                .any((User x) => x.userId == model.userId)) {
              chatState.setChatUser = searchState.userlist
                  .where((User x) => x.userId == model.userId)
                  .first;
            }
            Navigator.pushNamed(context, '/ChatScreenPage');
          },
          leading: RippleButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/ProfilePage/${model.userId}');
            },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(28),
                image: DecorationImage(
                    image: customAdvanceNetworkImage(
                        model.profilePic ?? dummyProfilePic),
                    fit: BoxFit.cover),
              ),
            ),
          ),
          title: Row(
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(
                    minWidth: 0, maxWidth: fullWidth(context) * .5),
                child: TitleText(model.displayName,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 3),
              if (model.isVerified)
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
                width: model.isVerified ? 5 : 0,
              ),
              customText(model.userName, style: userNameStyle),
              const Spacer(),
              if (lastMessage == null)
                const SizedBox.shrink()
              else
                TitleText(
                  getChatTime(lastMessage.createdAt).toString(),
                  fontSize: 14,
                  color: AppColor.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
            ],
          ),
          subtitle: TitleText(
            trimMessage(lastMessage.message) ?? '@${model.displayName}',
            color: AppColor.darkGrey,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            // overflow: TextOverflow.ellipsis,
          ),
          // trailing: lastMessage == null
          //     ? SizedBox.shrink()
          //     : TitleText(
          //         getChatTime(lastMessage.createdAt).toString(),
          //         fontSize: 14,
          //         color: AppColor.darkGrey,
          //         fontWeight: FontWeight.w500,
          //       ),
        ),
      );

  FloatingActionButton _newMessageButton() => FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/NewMessagePage'),
        child: customIcon(
          context,
          icon: AppIcon.newMessage,
          istwitterIcon: true,
          iconColor: Theme.of(context).colorScheme.onPrimary,
          size: 25,
        ),
      );

  void onSettingIconPressed() {
    Navigator.pushNamed(context, '/DirectMessagesPage');
  }

  String trimMessage(String message) {
    if (message != null && message.isNotEmpty) {
      if (message.length > 70) {
        message = message.substring(0, 70) + '...';
        return message;
      } else {
        return message;
      }
    }
    return null;
  }

  @override
  Scaffold build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          scaffoldKey: widget.scaffoldKey,
          title: customTitleText(
            'Messages',
          ),
          icon: AppIcon.settings,
          onActionPressed: onSettingIconPressed,
        ),
        floatingActionButton: _newMessageButton(),
        backgroundColor: InstaframColor.mystic,
        body: _body(),
      );
}
