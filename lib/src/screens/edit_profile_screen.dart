import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/services/database_service.dart';
import 'package:instafram/src/services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({this.user});

  final User user;

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File _profileImageFile;
  String _username = '';
  String _bio = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _username = widget.user.username;
    _bio = widget.user.bio;
  }

  Future<void> _handle() async {
    final File imagefile =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imagefile != null) {
      setState(() {
        _profileImageFile = imagefile;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      // Update user in the database
      String _profileImage = '';

      _profileImage = _profileImageFile == null
          ? widget.user.profileImage
          : await StorageService.uploadProfileImage(
              widget.user.profileImage, _profileImageFile);

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

  ImageProvider<dynamic> _displayProfileImage() {
    // No new profile image
    if (_profileImageFile == null) {
      // Check if there is an existing profile
      if (widget.user.profileImage.isEmpty) {
        return const AssetImage('assets/images/user_placeholder.jpg');
      } else {
        // User profile image exists
        return CachedNetworkImageProvider(widget.user.profileImage);
      }
    }

    // User selected a profile image
    return FileImage(_profileImageFile);
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
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            children: <Widget>[
              if (_isLoading)
                LinearProgressIndicator(
                  backgroundColor: Colors.blue[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
              else
                const SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 60.0,
                        backgroundColor: Colors.grey,
                        backgroundImage: _displayProfileImage(),
                      ),
                      FlatButton(
                        onPressed: _handle,
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
            ],
          ),
        ),
      );
}
