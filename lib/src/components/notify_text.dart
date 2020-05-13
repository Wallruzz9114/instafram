import 'package:flutter/material.dart';
import 'package:instafram/src/components/shared/title_text.dart';
import 'package:instafram/src/helpers/main_theme.dart';

class NotifyText extends StatelessWidget {
  const NotifyText({Key key, this.subTitle, this.title}) : super(key: key);

  final String subTitle;
  final String title;

  @override
  Column build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleText(title, fontSize: 20, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          TitleText(
            subTitle,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColor.darkGrey,
            textAlign: TextAlign.center,
          ),
        ],
      );
}
