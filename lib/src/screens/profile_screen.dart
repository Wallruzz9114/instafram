import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/screens/edit_profile_screen.dart';
import 'package:instafram/src/utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({this.userId});

  final String userId;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Scaffold build(BuildContext context) => Scaffold(
        appBar: customAppBar('Account'),
        backgroundColor: Colors.white,
        body: FutureBuilder<DocumentSnapshot>(
          future: usersReference.document(widget.userId).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final User user = User.fromDoc(snapshot.data);

            return ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 50.0,
                        backgroundImage: (user.profileImage.isEmpty
                                ? const AssetImage(
                                    'assets/images/user_placeholder.jpg')
                                : CachedNetworkImageProvider(user.profileImage))
                            as ImageProvider<dynamic>,
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(
                                      '12',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'posts',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      '386',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'following',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      '385',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'followers',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              width: 200.0,
                              child: FlatButton(
                                color: Colors.blue,
                                textColor: Colors.white,
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<EditProfileScreen>(
                                    builder: (_) =>
                                        EditProfileScreen(user: user),
                                  ),
                                ),
                                child: const Text('Edit Profile'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.username,
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5.0),
                      Container(
                        height: 80.0,
                        child: Text(
                          user.bio,
                          style: const TextStyle(fontSize: 15.0),
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
}
