import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instafram/src/screens/feed_screen.dart';
import 'package:instafram/src/screens/log_in_screen.dart';
import 'package:instafram/src/screens/root_screen.dart';
import 'package:instafram/src/screens/sign_up_screen.dart';

class Instafram extends StatelessWidget {
  Widget _getScreen() => StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) =>
            snapshot.hasData
                ? RootScreen(userId: snapshot.data.uid)
                : LogInScreen(),
      );

  @override
  MaterialApp build(BuildContext context) => MaterialApp(
        title: 'Instafram',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryIconTheme:
              Theme.of(context).primaryIconTheme.copyWith(color: Colors.black),
        ),
        home: _getScreen(),
        routes: <String, Widget Function(BuildContext)>{
          LogInScreen.id: (BuildContext context) => LogInScreen(),
          SignUpScreen.id: (BuildContext context) => SignUpScreen(),
          FeedScreen.id: (BuildContext context) => FeedScreen(),
        },
      );
}
