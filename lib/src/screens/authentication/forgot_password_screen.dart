import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/services/authentication_service.dart';
import 'package:provider/provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key key, this.loginCallback}) : super(key: key);

  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  FocusNode _focusNode;
  TextEditingController _emailController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _focusNode = FocusNode();
    _emailController = TextEditingController();
    _emailController.text = '';
    _focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Container _body(BuildContext context) => Container(
        height: fullHeight(context),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _label(),
            const SizedBox(height: 50),
            _entryFeild('Enter email', controller: _emailController),
            // SizedBox(height: 10,),
            _submitButton(context),
          ],
        ),
      );

  Container _entryFeild(String hint,
          {TextEditingController controller, bool isPassword = false}) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30)),
        child: TextField(
          focusNode: _focusNode,
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
              fontStyle: FontStyle.normal, fontWeight: FontWeight.normal),
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                borderSide: BorderSide(color: Colors.blue)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
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
          onPressed: _submit,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Text('Submit', style: TextStyle(color: Colors.white)),
        ),
      );

  Container _label() => Container(
        child: Column(
          children: <Widget>[
            customText('Forget Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: customText(
                'Enter your email address below to receive password reset instruction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      );

  void _submit() {
    if (_emailController.text == null || _emailController.text.isEmpty) {
      customSnackBar(_scaffoldKey, 'Email field cannot be empty');
      return;
    }
    final bool isValidEmail = validateEmal(
      _emailController.text,
    );
    if (!isValidEmail) {
      customSnackBar(_scaffoldKey, 'Please enter valid email address');
      return;
    }

    _focusNode.unfocus();
    final AuthenticationService state =
        Provider.of<AuthenticationService>(context, listen: false);
    state.forgetPassword(_emailController.text, scaffoldKey: _scaffoldKey);
  }

  @override
  Scaffold build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: customText('Forget Password',
              context: context, style: const TextStyle(fontSize: 20)),
          centerTitle: true,
        ),
        body: _body(context),
      );
}
