import 'package:flutter/material.dart';
import 'package:instafram/src/screens/sign_up_screen.dart';

class LogInScreen extends StatefulWidget {
  static const String id = 'log_in_screen';

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email, _password;

  void _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Log in user
    }
  }

  @override
  Scaffold build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Instafram',
                  style: TextStyle(
                    fontFamily: 'Billabong',
                    fontSize: 50.0,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 10.0,
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (String input) => !input.contains('@')
                              ? 'Please enter a valid email'
                              : null,
                          onSaved: (String input) => _email = input,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 10.0,
                        ),
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          validator: (String input) => input.length < 6
                              ? 'Must be at least 6 characters'
                              : null,
                          onSaved: (String input) => _password = input,
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        width: 250.0,
                        child: FlatButton(
                          onPressed: _submit,
                          color: Colors.blue,
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'LogIn',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        width: 250.0,
                        child: FlatButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, SignUpScreen.id),
                          color: Colors.blue,
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            'Go to Signup',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
