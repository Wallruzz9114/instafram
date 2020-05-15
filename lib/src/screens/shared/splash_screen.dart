import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/screens/home_screen.dart';
import 'package:instafram/src/screens/shared/welcome_screen.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      timer();
    });
    super.initState();
  }

  Future<void> timer() async {
    Future<FirebaseUser>.delayed(const Duration(seconds: 1)).then((dynamic _) {
      final AuthenticationState state =
          Provider.of<AuthenticationState>(context, listen: false);
      // state.authStatus = AuthStatus.NOT_DETERMINED;
      state.getCurrentUser();
    });
  }

  Container _body() => Container(
        height: fullHeight(context),
        width: fullWidth(context),
        child: Container(
          height: 150.0,
          width: 150.0,
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(50),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                if (Platform.isIOS)
                  const CupertinoActivityIndicator(radius: 35)
                else
                  const CircularProgressIndicator(strokeWidth: 2),
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

  @override
  Widget build(BuildContext context) {
    final AuthenticationState state = Provider.of<AuthenticationState>(context);
    return Scaffold(
      backgroundColor: InstaframColor.white,
      body: state.authenticationStatus == AuthenticationStatus.NOT_DETERMINED
          ? _body()
          : state.authenticationStatus == AuthenticationStatus.NOT_LOGGED_IN
              ? const WelcomeScreen()
              : const HomeScreen(),
    );
  }
}
