import 'package:flutter/material.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  @override
  Scaffold build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text('New Post'),
        ),
      );
}
