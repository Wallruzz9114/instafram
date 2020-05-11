import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instafram/src/components/user_tile.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/services/database_service.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  Future<QuerySnapshot> _users;

  void _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      _users = null;
    });
  }

  @override
  Scaffold build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
              border: InputBorder.none,
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search, size: 30.0),
              suffixIcon:
                  IconButton(icon: Icon(Icons.clear), onPressed: _clearSearch),
              filled: true,
            ),
            onSubmitted: (String input) {
              if (input.isNotEmpty) {
                setState(() {
                  _users = DatabaseService.searchUsers(input);
                });
              }
            },
          ),
        ),
        body: _users == null
            ? const Center(child: Text('Search for a user'))
            : FutureBuilder<QuerySnapshot>(
                future: _users,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.data.documents.isEmpty) {
                    return const Center(
                      child: Text('No users found! Please try again'),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      final User user =
                          User.fromDoc(snapshot.data.documents[index]);
                      return UserTile(user: user);
                    },
                  );
                },
              ),
      );
}
