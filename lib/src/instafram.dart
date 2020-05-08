import 'package:flutter/material.dart';
import 'package:instafram/src/screens/log_in_screen.dart';
import 'package:instafram/src/screens/sign_up_screen.dart';

class Instafram extends StatelessWidget {
  @override
  MaterialApp build(BuildContext context) => MaterialApp(
        title: 'Instafram',
        debugShowCheckedModeBanner: false,
        home: LogInScreen(),
        routes: <String, Widget Function(BuildContext)>{
          LogInScreen.id: (BuildContext context) => LogInScreen(),
          SignUpScreen.id: (BuildContext context) => SignUpScreen(),
        },
      );
}
