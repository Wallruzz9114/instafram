import 'package:flutter/material.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/services/databese_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({this.user});

  final User user;

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _username = '';
  String _bio = '';

  @override
  void initState() {
    super.initState();
    _username = widget.user.username;
    _bio = widget.user.bio;
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Update user in the database
      const String _profileImage = '';
      final User user = User(
        id: widget.user.id,
        username: _username,
        profileImage: _profileImage,
        bio: _bio,
      );

      // Databse update
      DatabaseService.updateUser(user);

      Navigator.pop(context);
    }
  }

  @override
  Scaffold build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 60.0,
                      backgroundImage:
                          NetworkImage('https://i.redd.it/dmdqlcdpjlwz.jpg'),
                    ),
                    FlatButton(
                      onPressed: () {},
                      child: Text(
                        'Change Image',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    TextFormField(
                      initialValue: _username,
                      style: const TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        icon: Icon(Icons.person, size: 30.0),
                        labelText: 'Username',
                      ),
                      validator: (String input) => input.isEmpty
                          ? 'Please enter a valid username'
                          : null,
                      onSaved: (String input) => _username = input,
                    ),
                    TextFormField(
                      initialValue: _bio,
                      style: const TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(
                        icon: Icon(Icons.book, size: 30.0),
                        labelText: 'Bio',
                      ),
                      validator: (String input) => input.trim().length > 150
                          ? 'Bio must be less than 150 characters'
                          : null,
                      onSaved: (String input) => _bio = input,
                    ),
                    Container(
                      margin: const EdgeInsets.all(40.0),
                      height: 40.0,
                      width: 250.0,
                      child: FlatButton(
                        onPressed: _submit,
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(fontSize: 18.0),
                        ),
                        color: Colors.blue,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
