import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/shared/custom_loader.dart';
import 'package:instafram/src/components/shared/title_text.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/services/authentication_service.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key key, this.loginCallback}) : super(key: key);

  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController _emailController;
  TextEditingController _passwordController;
  CustomLoader loader;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    loader = CustomLoader();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  SingleChildScrollView _body(BuildContext context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 150),
              _entryFeild('Enter email', controller: _emailController),
              _entryFeild('Enter password',
                  controller: _passwordController, isPassword: true),
              _emailLoginButton(context),
              const SizedBox(height: 20),
              _labelButton(
                'Forget password?',
                onPressed: () =>
                    Navigator.of(context).pushNamed('/ForgetPasswordPage'),
              ),
              const Divider(height: 30),
              const SizedBox(height: 150),
            ],
          ),
        ),
      );

  Container _entryFeild(String hint,
          {TextEditingController controller, bool isPassword = false}) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.normal,
          ),
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                borderSide: BorderSide(color: Colors.blue)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
      );

  FlatButton _labelButton(String title, {Function onPressed}) => FlatButton(
        onPressed: () {
          if (onPressed != null) {
            onPressed();
          }
        },
        splashColor: Colors.grey.shade200,
        child: Text(
          title,
          style: TextStyle(
              color: InstaframColor.dodgetBlue, fontWeight: FontWeight.bold),
        ),
      );

  Container _emailLoginButton(BuildContext context) => Container(
        width: fullWidth(context),
        margin: const EdgeInsets.symmetric(vertical: 35),
        child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: InstaframColor.dodgetBlue,
          onPressed: _emailLogin,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: const TitleText('Submit', color: Colors.white),
        ),
      );

  void _emailLogin() {
    final AuthenticationService state =
        Provider.of<AuthenticationService>(context, listen: false);
    if (state.isbusy) {
      return;
    }
    loader.showLoader(context);
    final bool isValid = validateCredentials(
        _scaffoldKey, _emailController.text, _passwordController.text);
    if (isValid) {
      state
          .signIn(_emailController.text, _passwordController.text,
              scaffoldKey: _scaffoldKey)
          .then((String status) {
        if (state.user != null) {
          loader.hideLoader();
          Navigator.pop(context);
          widget.loginCallback();
        } else {
          cprint('Unable to login', errorIn: '_emailLoginButton');
          loader.hideLoader();
        }
      });
    } else {
      loader.hideLoader();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: customText('Sign in',
              context: context, style: const TextStyle(fontSize: 20)),
          centerTitle: true,
        ),
        body: _body(context),
      );
}
