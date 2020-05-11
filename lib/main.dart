import 'package:flutter/material.dart';
import 'package:instafram/src/instafram.dart';
import 'package:instafram/src/models/user_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      ChangeNotifierProvider<UserProvider>(
        create: (BuildContext context) => UserProvider(),
        child: Instafram(),
      ),
    );
