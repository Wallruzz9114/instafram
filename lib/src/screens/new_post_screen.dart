import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instafram/src/models/post.dart';
import 'package:instafram/src/models/user_provider.dart';
import 'package:instafram/src/services/database_service.dart';
import 'package:instafram/src/services/storage_service.dart';
import 'package:provider/provider.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  File _imageFile;
  final TextEditingController _captionController = TextEditingController();
  String _caption = '';
  bool _isLoading = false;

  void _showSelectImageDialog() =>
      Platform.isIOS ? _iosBottomSheet() : _androidDialog();

  void _iosBottomSheet() {
    showCupertinoModalPopup<CupertinoActionSheet>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Add Photo'),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () => _handleImage(ImageSource.camera),
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => _handleImage(ImageSource.gallery),
            child: const Text('Gallery'),
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _androidDialog() {
    showDialog<SimpleDialog>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: const Text('Add Photo'),
        children: <Widget>[
          SimpleDialogOption(
            child: const Text('Take Photo'),
            onPressed: () => _handleImage(ImageSource.camera),
          ),
          SimpleDialogOption(
            child: const Text('Choose From Gallery'),
            onPressed: () => _handleImage(ImageSource.gallery),
          ),
          SimpleDialogOption(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImage(ImageSource source) async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: source);

    if (imageFile != null) {
      imageFile = await _cropImage(imageFile);
      setState(() {
        _imageFile = imageFile;
      });
    }
  }

  Future<File> _cropImage(File imageFile) async {
    final File croppedImage = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );

    return croppedImage;
  }

  Future<void> _submit() async {
    if (!_isLoading && _imageFile != null && _caption.isNotEmpty) {
      // Add post to database
      setState(() {
        _isLoading = true;
      });

      // Create the post
      final String imageURL = await StorageService.uploadPostMedia(_imageFile);
      final Post post = Post(
        imageURL: imageURL,
        caption: _caption,
        likes: <String, dynamic>{},
        authorId: Provider.of<UserProvider>(context).currentUserId,
        timestamp: Timestamp.fromDate(DateTime.now()),
      );
      DatabaseService.createPost(post);

      // Reset state and clear field
      _captionController.clear();
      setState(() {
        _caption = '';
        _imageFile = null;
        _isLoading = false;
      });
    }
  }

  @override
  Scaffold build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Create Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.add), onPressed: _submit),
        ],
      ),
      body: Container(
        height: height,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.blue[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                GestureDetector(
                  onTap: _showSelectImageDialog,
                  child: Container(
                    width: width,
                    height: width,
                    color: Colors.grey[300],
                    child: _imageFile == null
                        ? Icon(
                            Icons.add_a_photo,
                            color: Colors.white70,
                            size: 150.0,
                          )
                        : Image(
                            image: FileImage(_imageFile),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextField(
                    controller: _captionController,
                    style: const TextStyle(fontSize: 18.0),
                    decoration: const InputDecoration(labelText: 'Caption'),
                    onChanged: (String input) => _caption = input,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
