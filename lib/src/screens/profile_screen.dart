import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Scaffold build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text('Profile'),
        ),
      );
}
