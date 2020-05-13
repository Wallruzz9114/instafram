import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/helpers/custom_route.dart';
import 'package:instafram/src/screens/authentication/forgot_password_screen.dart';
import 'package:instafram/src/screens/authentication/sign_in_screen.dart';
import 'package:instafram/src/screens/authentication/sign_up_screen.dart';
import 'package:instafram/src/screens/authentication/verify_email_screen.dart';
import 'package:instafram/src/screens/shared/splash_screen.dart';
import 'package:instafram/src/screens/shared/welcome_screen.dart';

class Routes {
  static Map<String, Widget Function(BuildContext)> route() {
    return <String, Widget Function(BuildContext)>{
      '/': (BuildContext context) => const SplashPage(),
    };
  }

  static void sendNavigationEventToFirebase(String path) {
    if (path != null && path.isNotEmpty) {
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case 'WelcomePage':
        return CustomRoute<bool>(
            builder: (BuildContext context) => const WelcomeScreen());
      case 'SignIn':
        return CustomRoute<bool>(
            builder: (BuildContext context) => const SignInScreen());
      case 'SignUp':
        return CustomRoute<bool>(
            builder: (BuildContext context) => const SignUpScreen());
      case 'ForgetPasswordPage':
        return CustomRoute<bool>(
            builder: (BuildContext context) => const ForgetPasswordScreen());
      case 'VerifyEmailPage':
        return CustomRoute<bool>(
          builder: (BuildContext context) => const VerifyEmailScreen(),
        );
      default:
        return onUnknownRoute(const RouteSettings(name: '/Feature'));
    }
  }

  static Route<Scaffold> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<Scaffold>(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: customTitleText(settings.name.split('/')[1]),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name.split('/')[1]} Comming soon..'),
        ),
      ),
    );
  }
}
