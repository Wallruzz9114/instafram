import 'package:flutter/material.dart';
import 'package:instafram/src/components/shared/custom_url_text.dart';
import 'package:instafram/src/helpers/main_theme.dart';

class SettingsRow extends StatelessWidget {
  const SettingsRow(
    this.title, {
    Key key,
    this.navigateTo,
    this.subtitle,
    this.textColor = Colors.black,
    this.onPressed,
    this.vPadding = 0,
    this.showDivider = true,
    this.visibleSwitch = false,
    this.showCheckBox = false,
  }) : super(key: key);

  final bool visibleSwitch, showDivider, showCheckBox;
  final String navigateTo;
  final String subtitle, title;
  final Color textColor;
  final Function onPressed;
  final double vPadding;

  @override
  Column build(BuildContext context) => Column(
        children: <Widget>[
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(vertical: vPadding, horizontal: 18),
            onTap: () {
              if (onPressed != null) {
                onPressed();
                return;
              }
              if (navigateTo == null) {
                return;
              }
              Navigator.pushNamed(context, '/$navigateTo');
            },
            title: title == null
                ? null
                : CustomUrlText(
                    text: title ?? '',
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
            subtitle: subtitle == null
                ? null
                : CustomUrlText(
                    text: subtitle,
                    style: TextStyle(
                        color: InstaframColor.paleSky,
                        fontWeight: FontWeight.w400),
                  ),
            trailing: showCheckBox
                ? !showCheckBox
                    ? const SizedBox()
                    : Checkbox(value: true, onChanged: (val) {})
                : !visibleSwitch
                    ? null
                    : Switch(
                        onChanged: (bool val) {},
                        value: false,
                      ),
          ),
          if (!showDivider) const SizedBox() else const Divider(height: 0)
        ],
      );
}
