import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final Firestore _firestoreInstance = Firestore.instance;
final StorageReference storageReference = FirebaseStorage.instance.ref();
final CollectionReference usersReference =
    _firestoreInstance.collection('users');

final AppBar customAppBar = AppBar(
  backgroundColor: Colors.white,
  title: Text(
    'Instagram',
    style: TextStyle(
      color: Colors.black,
      fontFamily: 'Billabong',
      fontSize: 35.0,
    ),
  ),
);
