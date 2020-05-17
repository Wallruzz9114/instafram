import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/shared/custom_url_text.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/models/message.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:instafram/src/states/message_state.dart';
import 'package:instafram/src/states/user_message_state.dart';
import 'package:provider/provider.dart';

class UserMessagesScreen extends StatefulWidget {
  const UserMessagesScreen({Key key, this.userProfileId}) : super(key: key);

  final String userProfileId;

  @override
  _UserMessagesScreenState createState() => _UserMessagesScreenState();
}

class _UserMessagesScreenState extends State<UserMessagesScreen> {
  final TextEditingController messageController = TextEditingController();
  String senderId;
  String userImage;
  MessageState state;
  ScrollController _controller;
  GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _controller = ScrollController();
    final UserMessageState chatUserState =
        Provider.of<UserMessageState>(context, listen: false);
    final MessageState chatState =
        Provider.of<MessageState>(context, listen: false);
    final AuthenticationState state =
        Provider.of<AuthenticationState>(context, listen: false);
    chatState.setChatUser = chatUserState.chatUser;
    senderId = state.userId;
    chatState.databaseInit(chatState.chatUser.userId, state.userId);
    chatState.getchatDetailAsync();
    super.initState();
  }

  Widget _chatScreenBody() {
    final MessageState state = Provider.of<MessageState>(context);
    if (state.messageList == null || state.messageList.isEmpty) {
      return Center(
        child: Text(
          'No message found',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.builder(
      controller: _controller,
      shrinkWrap: true,
      reverse: true,
      physics: const BouncingScrollPhysics(),
      itemCount: state.messageList.length,
      itemBuilder: (BuildContext context, int index) =>
          chatMessage(state.messageList[index]),
    );
  }

  Widget chatMessage(Message message) {
    if (senderId == null) {
      return Container();
    }
    if (message.senderId == senderId)
      return _message(message, true);
    else
      return _message(message, false);
  }

  Column _message(Message chat, bool myMessage) => Column(
        crossAxisAlignment:
            myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment:
            myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const SizedBox(width: 15),
              if (myMessage)
                const SizedBox()
              else
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: customAdvanceNetworkImage(userImage),
                ),
              Expanded(
                child: Container(
                  alignment:
                      myMessage ? Alignment.centerRight : Alignment.centerLeft,
                  margin: EdgeInsets.only(
                    right: myMessage ? 10 : (fullWidth(context) / 4),
                    top: 20,
                    left: myMessage ? (fullWidth(context) / 4) : 10,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: getBorder(myMessage),
                          color: myMessage
                              ? InstaframColor.dodgetBlue
                              : InstaframColor.mystic,
                        ),
                        child: CustomUrlText(
                          text: chat.message,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                myMessage ? InstaframColor.white : Colors.black,
                          ),
                          urlStyle: TextStyle(
                            fontSize: 16,
                            color: myMessage
                                ? InstaframColor.white
                                : InstaframColor.dodgetBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: InkWell(
                          borderRadius: getBorder(myMessage),
                          onLongPress: () {
                            final ClipboardData text =
                                ClipboardData(text: chat.message);
                            Clipboard.setData(text);
                            _scaffoldKey.currentState.hideCurrentSnackBar();
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                backgroundColor: InstaframColor.white,
                                content: Text(
                                  'Message copied',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                          },
                          child: const SizedBox(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: Text(
              getChatTime(chat.createdAt),
              style: Theme.of(context).textTheme.caption.copyWith(fontSize: 12),
            ),
          )
        ],
      );

  BorderRadius getBorder(bool myMessage) {
    return BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomRight:
          myMessage ? const Radius.circular(0) : const Radius.circular(20),
      bottomLeft:
          myMessage ? const Radius.circular(20) : const Radius.circular(0),
    );
  }

  Align _bottomEntryField() => Align(
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const Divider(
              thickness: 0,
              height: 1,
            ),
            TextField(
              onSubmitted: (String val) async {
                submitMessage();
              },
              controller: messageController,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
                alignLabelWithHint: true,
                hintText: 'Start with a message...',
                suffixIcon: IconButton(
                    icon: Icon(Icons.send), onPressed: submitMessage),
                // fillColor: Colors.black12, filled: true
              ),
            ),
          ],
        ),
      );

  void submitMessage() {
    // var state = Provider.of<ChatUserState>(context, listen: false);
    final AuthenticationState authstate =
        Provider.of<AuthenticationState>(context, listen: false);
    Message message;
    message = Message(
      message: messageController.text,
      createdAt: DateTime.now().toUtc().toString(),
      senderId: authstate.userModel.userId,
      receiverId: state.chatUser.userId,
      seen: false,
      timeStamp: DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
      senderName: authstate.user.displayName,
    );
    if (messageController.text == null || messageController.text.isEmpty) {
      return;
    }
    final User myUser = User(
        displayName: authstate.userModel.displayName,
        userId: authstate.userModel.userId,
        userName: authstate.userModel.userName,
        profilePic: authstate.userModel.profilePic);
    final User secondUser = User(
      displayName: state.chatUser.displayName,
      userId: state.chatUser.userId,
      userName: state.chatUser.userName,
      profilePic: state.chatUser.profilePic,
    );
    state.onMessageSubmitted(message, myUser: myUser, secondUser: secondUser);
    Future<dynamic>.delayed(const Duration(milliseconds: 50)).then((dynamic _) {
      messageController.clear();
    });
    try {
      // final state = Provider.of<ChatUserState>(context,listen: false);
      if (state.messageList != null &&
          state.messageList.length > 1 &&
          _controller.offset > 0) {
        _controller.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
    } catch (e) {
      print('[Error] $e');
    }
  }

  @override
  Scaffold build(BuildContext context) {
    state = Provider.of<MessageState>(context, listen: false);
    userImage = state.chatUser.profilePic;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomUrlText(
              text: state.chatUser.displayName,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              state.chatUser.userName,
              style: TextStyle(color: AppColor.darkGrey, fontSize: 15),
            )
          ],
        ),
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.info, color: AppColor.primary),
              onPressed: () {
                Navigator.pushNamed(context, '/ConversationInformation');
              })
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: _chatScreenBody(),
              ),
            ),
            _bottomEntryField()
          ],
        ),
      ),
    );
  }
}
