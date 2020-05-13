import 'dart:math';

import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/shared/custom_loader.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/services/authentication_service.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key key, this.loginCallback}) : super(key: key);

  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;
  TextEditingController _confirmController;
  CustomLoader loader;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    loader = CustomLoader();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Container _body(BuildContext context) => Container(
        height: fullHeight(context) - 88,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _entryField('Name', controller: _nameController),
              _entryField('Enter email', controller: _emailController),
              // _entryField('Mobile no',controller: _mobileController),
              _entryField('Enter password',
                  controller: _passwordController, isPassword: true),
              _entryField('Confirm password',
                  controller: _confirmController, isPassword: true),
              _submitButton(context),

              const Divider(height: 30),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );

  Container _entryField(
    String hint, {
    TextEditingController controller,
    bool isPassword = false,
  }) =>
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
              borderRadius: const BorderRadius.all(
                Radius.circular(30.0),
              ),
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
      );

  Container _submitButton(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        width: MediaQuery.of(context).size.width,
        child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          color: InstaframColor.dodgetBlue,
          onPressed: _submitForm,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Text(
            'Sign up',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  void _submitForm() {
    if (_emailController.text.isEmpty) {
      customSnackBar(_scaffoldKey, 'Please enter name');
      return;
    }
    if (_emailController.text.length > 27) {
      customSnackBar(_scaffoldKey, 'Name length cannot exceed 27 character');
      return;
    }
    if (_emailController.text == null ||
        _emailController.text.isEmpty ||
        _passwordController.text == null ||
        _passwordController.text.isEmpty ||
        _confirmController.text == null) {
      customSnackBar(_scaffoldKey, 'Please fill form carefully');
      return;
    } else if (_passwordController.text != _confirmController.text) {
      customSnackBar(
          _scaffoldKey, 'Password and confirm password did not match');
      return;
    }

    loader.showLoader(context);
    final AuthenticationService state =
        Provider.of<AuthenticationService>(context, listen: false);
    final Random random = Random();
    final int randomNumber = random.nextInt(8);

    final User user = User(
      email: _emailController.text.toLowerCase(),
      bio: 'Edit profile to update bio',
      // contact:  _mobileController.text,
      displayName: _nameController.text,
      dob: DateTime(1950, DateTime.now().month, DateTime.now().day + 3)
          .toString(),
      location: 'Somewhere in universe',
      profilePic: dummyProfilePicList[randomNumber],
      isVerified: false,
    );

    state
        .signUp(
      user,
      password: _passwordController.text,
      scaffoldKey: _scaffoldKey,
    )
        .then((String status) {
      print(status);
    }).whenComplete(
      () {
        loader.hideLoader();
        if (state.authenticationStatus == AuthenticationStatus.LOGGED_IN) {
          Navigator.pop(context);
          widget.loginCallback();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: customText(
            'Sign Up',
            context: context,
            style: const TextStyle(fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(child: _body(context)),
      );
}
