import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final Firestore _firestoreInstance = Firestore.instance;
final StorageReference storageReference = FirebaseStorage.instance.ref();
final CollectionReference usersReference =
    _firestoreInstance.collection('users');
final CollectionReference postsReference =
    _firestoreInstance.collection('posts');

AppBar customAppBar(String title) => AppBar(
      backgroundColor: Colors.white,
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontFamily: title == 'Instagram' ? 'Billabong' : null,
          fontSize: title == 'Instagram' ? 35.0 : null,
        ),
      ),
    );
