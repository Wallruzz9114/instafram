import 'package:cloud_firestore/cloud_firestore.dart';

final Firestore _firestoreInstance = Firestore.instance;
final CollectionReference usersReference =
    _firestoreInstance.collection('users');
