import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_app_bar.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/settings/settings_row.dart';
import 'package:instafram/src/components/shared/custom_url_text.dart';
import 'package:instafram/src/components/shared/header.dart';
import 'package:instafram/src/components/shared/ripple_button.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/states/user_message_state.dart';
import 'package:provider/provider.dart';

class ConversationInformation extends StatelessWidget {
  const ConversationInformation({Key key}) : super(key: key);

  Widget _header(BuildContext context, User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: SizedBox(
                height: 80,
                width: 80,
                child: RippleButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed('/ProfilePage/' + user?.userId);
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: customImage(context, user.profilePic, height: 80),
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomUrlText(
                text: user.displayName,
                style: onPrimaryTitleText.copyWith(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(width: 3),
              if (user.isVerified)
                customIcon(
                  context,
                  icon: AppIcon.blueTick,
                  istwitterIcon: true,
                  iconColor: AppColor.primary,
                  size: 18,
                  paddingIcon: 3,
                )
              else
                const SizedBox(width: 0),
            ],
          ),
          customText(
            user.userName,
            style: onPrimarySubTitleText.copyWith(
              color: Colors.black54,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Scaffold build(BuildContext context) {
    final User user = Provider.of<UserMessageState>(context).chatUser ?? User();

    return Scaffold(
      backgroundColor: InstaframColor.white,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Conversation information',
        ),
      ),
      body: ListView(
        children: <Widget>[
          _header(context, user),
          const Header('Notifications'),
          const SettingsRow(
            'Mute conversation',
            visibleSwitch: true,
          ),
          Container(
            height: 15,
            color: InstaframColor.mystic,
          ),
          SettingsRow(
            'Block ${user.userName}',
            textColor: InstaframColor.dodgetBlue,
            showDivider: false,
          ),
          SettingsRow('Report ${user.userName}',
              textColor: InstaframColor.dodgetBlue, showDivider: false),
          SettingsRow('Delete conversation',
              textColor: InstaframColor.ceriseRed, showDivider: false),
        ],
      ),
    );
  }
}
