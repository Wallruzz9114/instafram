import 'package:flutter/material.dart';
import 'package:instafram/src/utils/constants.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  @override
  Scaffold build(BuildContext context) => Scaffold(
        appBar: customAppBar,
        body: Center(
          child: Text('New Post'),
        ),
      );
}
