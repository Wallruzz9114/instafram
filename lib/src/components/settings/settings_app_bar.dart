import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/helpers/main_theme.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({Key key, this.title, this.subtitle}) : super(key: key);

  final String title, subtitle;

  @override
  AppBar build(BuildContext context) => AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 5),
            customTitleText(
              title,
            ),
            Text(
              subtitle ?? '',
              style: TextStyle(color: AppColor.darkGrey, fontSize: 18),
            )
          ],
        ),
        iconTheme: IconThemeData(color: Colors.blue),
        backgroundColor: Colors.white,
      );

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
