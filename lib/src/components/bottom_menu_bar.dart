import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/tab_item.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/states/application_state.dart';
import 'package:provider/provider.dart';

class BottomMenubar extends StatefulWidget {
  const BottomMenubar({this.pageController});
  final PageController pageController;

  @override
  _BottomMenubarState createState() => _BottomMenubarState();
}

class _BottomMenubarState extends State<BottomMenubar> {
  // int _selectedIcon = 0;

  Container _iconRow() {
    final ApplicationState state = Provider.of<ApplicationState>(context);
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarColor,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(0, -.1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _icon(null, 0,
              icon: 0 == state.pageIndex ? AppIcon.homeFill : AppIcon.home,
              isCustomIcon: true),
          _icon(null, 1,
              icon: 1 == state.pageIndex ? AppIcon.searchFill : AppIcon.search,
              isCustomIcon: true),
          _icon(
            null,
            2,
            icon: 2 == state.pageIndex
                ? AppIcon.notificationFill
                : AppIcon.notification,
            isCustomIcon: true,
          ),
          _icon(null, 3,
              icon: 3 == state.pageIndex
                  ? AppIcon.messageFill
                  : AppIcon.messageEmpty,
              isCustomIcon: true),
        ],
      ),
    );
  }

  Expanded _icon(IconData iconData, int index,
      {bool isCustomIcon = false, int icon}) {
    final ApplicationState state = Provider.of<ApplicationState>(context);
    return Expanded(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: ANIM_DURATION),
          curve: Curves.easeIn,
          alignment: const Alignment(0, ICON_ON),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: ANIM_DURATION),
            opacity: ALPHA_ON,
            child: IconButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              padding: const EdgeInsets.all(0),
              alignment: const Alignment(0, 0),
              icon: isCustomIcon
                  ? customIcon(context,
                      icon: icon,
                      size: 22,
                      istwitterIcon: true,
                      isEnable: index == state.pageIndex)
                  : Icon(
                      iconData,
                      color: index == state.pageIndex
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.caption.color,
                    ),
              onPressed: () {
                setState(() {
                  // _selectedIcon = index;
                  state.setpageIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _iconRow();
  }
}
