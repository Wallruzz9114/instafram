import 'package:flutter/material.dart';
import 'package:instafram/src/services/authentication_service.dart';

class FeedScreen extends StatefulWidget {
  static const String id = 'feed_screen';

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final AuthenticationService _authenticationService = AuthenticationService();

  @override
  Scaffold build(BuildContext context) => Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: FlatButton(
            onPressed: () => _authenticationService.signOut(),
            child: const Text('Sign Out'),
          ),
        ),
      );
}
