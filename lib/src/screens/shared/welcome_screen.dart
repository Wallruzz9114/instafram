import 'package:flutter/material.dart';
import 'package:instafram/src/components/shared/title_text.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/screens/authentication/sign_in_screen.dart';
import 'package:instafram/src/screens/authentication/sign_up_screen.dart';
import 'package:instafram/src/screens/home_screen.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Container _submitButton() => Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: InstaframColor.dodgetBlue,
          onPressed: () {
            final AuthenticationState state =
                Provider.of<AuthenticationState>(context, listen: false);
            Navigator.push(
              context,
              MaterialPageRoute<SignUpScreen>(
                builder: (BuildContext context) =>
                    SignUpScreen(loginCallback: state.getCurrentUser),
              ),
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: const TitleText('Create account', color: Colors.white),
        ),
      );

  SafeArea _body() => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width - 80,
                height: 40,
                child: Image.asset('assets/images/icon-480.png'),
              ),
              const Spacer(),
              const TitleText(
                'See what\'s happening in the world right now.',
                fontSize: 25,
              ),
              const SizedBox(height: 20),
              _submitButton(),
              const Spacer(),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  TitleText(
                    'Have an account already?',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                  InkWell(
                    onTap: () {
                      final AuthenticationState state =
                          Provider.of<AuthenticationState>(context,
                              listen: false);
                      Navigator.push(
                        context,
                        MaterialPageRoute<SignInScreen>(
                          builder: (BuildContext context) =>
                              SignInScreen(loginCallback: state.getCurrentUser),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 10),
                      child: TitleText(
                        ' Log in',
                        fontSize: 14,
                        color: InstaframColor.dodgetBlue,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final AuthenticationState state =
        Provider.of<AuthenticationState>(context, listen: false);
    return Scaffold(
      body: state.authenticationStatus == AuthenticationStatus.NOT_LOGGED_IN ||
              state.authenticationStatus == AuthenticationStatus.NOT_DETERMINED
          ? _body()
          : const HomeScreen(),
    );
  }
}
