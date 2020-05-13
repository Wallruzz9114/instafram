import 'package:flutter/material.dart';
import 'package:instafram/src/components/custom_widgets.dart';
import 'package:instafram/src/components/notify_text.dart';
import 'package:instafram/src/components/shared/title_text.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/services/authentication_service.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key key, this.loginCallback}) : super(key: key);

  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _body(BuildContext context) {
    final AuthenticationService state =
        Provider.of<AuthenticationService>(context, listen: false);
    return Container(
      height: fullHeight(context),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: state.user.isEmailVerified
            ? <Widget>[
                const NotifyText(
                  title: 'Your email address is verified',
                  subTitle:
                      'You have got your blue tick on your name. Cheers !!',
                ),
              ]
            : <Widget>[
                NotifyText(
                  title: 'Verify your email address',
                  subTitle:
                      'Send email verification email link to ${state.user.email} to verify address',
                ),
                const SizedBox(height: 30),
                _submitButton(context),
              ],
      ),
    );
  }

  Container _submitButton(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Wrap(
          children: <Widget>[
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.blueAccent,
              onPressed: _submit,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: TitleText(
                'Send Link',
                color: Colors.white,
              ),
            ),
          ],
        ),
      );

  void _submit() {
    final AuthenticationService state =
        Provider.of<AuthenticationService>(context, listen: false);
    state.sendEmailVerification(_scaffoldKey);
  }

  @override
  Scaffold build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: InstaframColor.mystic,
        appBar: AppBar(
          title: customText(
            'Email Verification',
            context: context,
            style: const TextStyle(fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: _body(context),
      );
}
