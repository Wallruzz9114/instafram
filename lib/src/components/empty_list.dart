import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/notify_text.dart';
import 'package:instafram/src/helpers/main_theme.dart';

class EmptyList extends StatelessWidget {
  const EmptyList(this.title, {this.subTitle});

  final String subTitle;
  final String title;

  @override
  Container build(BuildContext context) => Container(
        height: fullHeight(context) - 135,
        color: InstaframColor.mystic,
        child: NotifyText(
          title: title,
          subTitle: subTitle,
        ),
      );
}
