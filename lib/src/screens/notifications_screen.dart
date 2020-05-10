import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Scaffold build(BuildContext context) => const Scaffold(
        body: Center(
          child: Text('Notifications'),
        ),
      );
}
