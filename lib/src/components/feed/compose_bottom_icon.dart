import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/main_theme.dart';

class ComposeBottomIcon extends StatefulWidget {
  const ComposeBottomIcon(
      {Key key, this.textEditingController, this.onImageIconSelcted})
      : super(key: key);

  final TextEditingController textEditingController;
  final Function(File) onImageIconSelcted;

  @override
  _ComposeBottomIconState createState() => _ComposeBottomIconState();
}

class _ComposeBottomIconState extends State<ComposeBottomIcon> {
  bool reachToWarning = false;
  bool reachToOver = false;
  Color wordCountColor;
  String tweet = '';

  @override
  void initState() {
    wordCountColor = Colors.blue;
    widget.textEditingController.addListener(updateUI);
    super.initState();
  }

  void updateUI() {
    setState(() {
      tweet = widget.textEditingController.text;
      if (widget.textEditingController.text != null &&
          widget.textEditingController.text.isNotEmpty) {
        if (widget.textEditingController.text.length > 259 &&
            widget.textEditingController.text.length < 280) {
          wordCountColor = Colors.orange;
        } else if (widget.textEditingController.text.length >= 280) {
          wordCountColor = Theme.of(context).errorColor;
        } else {
          wordCountColor = Colors.blue;
        }
      }
    });
  }

  Container _bottomIconWidget() => Container(
        width: fullWidth(context),
        height: 50,
        decoration: BoxDecoration(
            border:
                Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            color: Theme.of(context).backgroundColor),
        child: Row(
          children: <Widget>[
            IconButton(
                onPressed: () {
                  setImage(ImageSource.gallery);
                },
                icon: customIcon(context,
                    icon: AppIcon.image,
                    istwitterIcon: true,
                    iconColor: AppColor.primary)),
            IconButton(
                onPressed: () {
                  setImage(ImageSource.camera);
                },
                icon: customIcon(context,
                    icon: AppIcon.camera,
                    istwitterIcon: true,
                    iconColor: AppColor.primary)),
            Expanded(
                child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: tweet != null && tweet.length > 289
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: customText('${280 - tweet.length}',
                              style: TextStyle(
                                  color: Theme.of(context).errorColor)),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                              value: getTweetLimit(),
                              backgroundColor: Colors.grey,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(wordCountColor),
                            ),
                            if (tweet.length > 259)
                              customText('${280 - tweet.length}',
                                  style: TextStyle(color: wordCountColor))
                            else
                              customText('',
                                  style: TextStyle(color: wordCountColor))
                          ],
                        )),
            ))
          ],
        ),
      );

  void setImage(ImageSource source) {
    ImagePicker.pickImage(source: source, imageQuality: 20).then((File file) {
      setState(() {
        // _image = file;
        widget.onImageIconSelcted(file);
      });
    });
  }

  double getTweetLimit() {
    if (tweet == null || tweet.isEmpty) {
      return 0.0;
    }
    if (tweet.length > 280) {
      return 1.0;
    }
    final int length = tweet.length;
    final double val = length * 100 / 28000.0;
    return val;
  }

  @override
  Container build(BuildContext context) => Container(
        child: _bottomIconWidget(),
      );
}
