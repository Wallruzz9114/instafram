import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomScreenLoader extends StatelessWidget {
  const CustomScreenLoader({
    Key key,
    this.backgroundColor = const Color(0xfff8f8f8),
    this.height = 30,
    this.width = 30,
  }) : super(key: key);

  final Color backgroundColor;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Container(
        height: height,
        width: height,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (Platform.isIOS)
                const CupertinoActivityIndicator(
                  radius: 35,
                )
              else
                const CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              Image.asset(
                'assets/images/icon-480.png',
                height: 30,
                width: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
