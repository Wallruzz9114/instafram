import 'package:flutter/material.dart';
import 'package:instafram/src/utils/constants.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Scaffold build(BuildContext context) => Scaffold(
        appBar: customAppBar('Notifications'),
        body: const Center(
          child: Text('Notifications'),
        ),
      );
}
