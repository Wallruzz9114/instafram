import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/shared/custom_screen_loader.dart';

class CustomLoader {
  factory CustomLoader() {
    if (_customLoader != null) {
      return _customLoader;
    } else {
      _customLoader = CustomLoader._createObject();
      return _customLoader;
    }
  }

  CustomLoader._createObject();

  static CustomLoader _customLoader;

  //static OverlayEntry _overlayEntry;
  OverlayState _overlayState; //= new OverlayState();
  OverlayEntry _overlayEntry;

  void _buildLoader() {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Container(
          height: fullHeight(context),
          width: fullWidth(context),
          child: buildLoader(context),
        );
      },
    );
  }

  void showLoader(BuildContext context) {
    _overlayState = Overlay.of(context);
    _buildLoader();
    _overlayState.insert(_overlayEntry);
  }

  void hideLoader() {
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (e) {
      print('Exception:: $e');
    }
  }

  CustomScreenLoader buildLoader(BuildContext context,
      {Color backgroundColor}) {
    backgroundColor ??= const Color(0xffa8a8a8).withOpacity(.5);
    const double height = 150.0;
    return CustomScreenLoader(
      height: height,
      width: height,
      backgroundColor: backgroundColor,
    );
  }
}
