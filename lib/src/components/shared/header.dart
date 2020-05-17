import 'package:flutter/material.dart';
import 'package:instafram/src/components/shared/custom_url_text.dart';
import 'package:instafram/src/helpers/main_theme.dart';

class Header extends StatelessWidget {
  const Header(this.title, {Key key, this.secondHeader = false})
      : super(key: key);

  final String title;
  final bool secondHeader;

  @override
  Container build(BuildContext context) => Container(
        padding: secondHeader
            ? const EdgeInsets.only(left: 18, right: 18, bottom: 10, top: 35)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        color: InstaframColor.mystic,
        alignment: Alignment.centerLeft,
        child: CustomUrlText(
          text: title ?? '',
          style: TextStyle(
              fontSize: 20,
              color: AppColor.darkGrey,
              fontWeight: FontWeight.w700),
        ),
      );
}
