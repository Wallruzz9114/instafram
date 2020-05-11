import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/screens/profile_screen.dart';

class UserTile extends StatelessWidget {
  const UserTile({this.user});

  final User user;

  @override
  ListTile build(BuildContext context) => ListTile(
        leading: CircleAvatar(
          radius: 20.0,
          backgroundImage: (user.profileImage.isEmpty
                  ? const AssetImage('assets/images/user_placeholder.jpg')
                  : CachedNetworkImageProvider(user.profileImage))
              as ImageProvider<dynamic>,
        ),
        title: Text(user.username),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<ProfileScreen>(
            builder: (_) => ProfileScreen(userId: user.id),
          ),
        ),
      );
}
