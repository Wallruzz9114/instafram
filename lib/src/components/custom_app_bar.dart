import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  @override
  AppBar build(BuildContext context) => AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Instagram',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Billabong',
            fontSize: 35.0,
          ),
        ),
      );
}
