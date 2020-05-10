import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final Firestore _firestoreInstance = Firestore.instance;
final StorageReference storageReference = FirebaseStorage.instance.ref();
final CollectionReference usersReference =
    _firestoreInstance.collection('users');
