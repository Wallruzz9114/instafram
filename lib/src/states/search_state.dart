import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instafram/src/helpers/constants.dart';
import 'package:instafram/src/helpers/enums.dart';
import 'package:instafram/src/helpers/utilities.dart';
import 'package:instafram/src/models/user.dart';
import 'package:instafram/src/states/application_state.dart';

class SearchState extends ApplicationState {
  bool isBusy = false;
  SortUser sortBy = SortUser.ByMaxFollower;
  List<User> _userFilterlist;
  List<User> _userlist;

  List<User> get userlist {
    if (_userFilterlist == null) {
      return null;
    } else {
      return List<User>.from(_userFilterlist);
    }
  }

  /// get [User list] from firebase realtime Database
  Future<void> getDataFromDatabase() async {
    try {
      isBusy = true;
      if (_userFilterlist == null) {
        _userFilterlist = <User>[];
      } else {}
      _userlist ??= <User>[];
      _userFilterlist.clear();
      _userlist.clear();

      final QuerySnapshot querySnapshot =
          await kfirestore.collection(USERS_COLLECTION).getDocuments();
      if (querySnapshot != null && querySnapshot.documents.isNotEmpty) {
        for (int i = 0; i < querySnapshot.documents.length; i++) {
          _userFilterlist.add(User.fromJson(querySnapshot.documents[i].data));
        }
        _userlist.addAll(_userFilterlist);
        _userFilterlist
            .sort((User x, User y) => y.followers.compareTo(x.followers));
      } else {
        _userlist = null;
      }

      isBusy = false;
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// It will reset filter list
  /// If user has use search filter and change screen and came back to search screen It will reset user list.
  /// This function call when search page open.
  void resetFilterList() {
    if (_userlist != null && _userlist.length != _userFilterlist.length) {
      _userFilterlist = List<User>.from(_userlist);
      _userFilterlist
          .sort((User x, User y) => y.followers.compareTo(x.followers));
      notifyListeners();
    }
  }

  /// This function call when search fiels text change.
  /// User list on  search field get filter by `name` string
  void filterByUsername(String name) {
    if (name.isEmpty &&
        _userlist != null &&
        _userlist.length != _userFilterlist.length) {
      _userFilterlist = List<User>.from(_userlist);
    }
    // return if userList is empty or null
    if (_userlist == null && _userlist.isEmpty) {
      print('Empty userList');
      return;
    }
    // sortBy userlist on the basis of username
    else if (name != null) {
      _userFilterlist = _userlist
          .where((User x) =>
              x.userName != null &&
              x.userName.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Sort user list on search user page.
  set updateUserSortPrefrence(SortUser val) {
    sortBy = val;
    notifyListeners();
  }

  String get selectedFilter {
    switch (sortBy) {
      case SortUser.ByAlphabetically:
        _userFilterlist
            .sort((User x, User y) => x.displayName.compareTo(y.displayName));
        notifyListeners();
        return 'alphabetically';

      case SortUser.ByMaxFollower:
        _userFilterlist
            .sort((User x, User y) => y.followers.compareTo(x.followers));
        notifyListeners();
        return 'User with max follower';

      case SortUser.ByNewest:
        _userFilterlist.sort((User x, User y) =>
            DateTime.parse(y.createdAt).compareTo(DateTime.parse(x.createdAt)));
        notifyListeners();
        return 'Newest user first';

      case SortUser.ByOldest:
        _userFilterlist.sort((User x, User y) =>
            DateTime.parse(x.createdAt).compareTo(DateTime.parse(y.createdAt)));
        notifyListeners();
        return 'Oldest user first';

      case SortUser.ByVerified:
        _userFilterlist.sort((User x, User y) =>
            y.isVerified.toString().compareTo(x.isVerified.toString()));
        notifyListeners();
        return 'Verified user first';

      default:
        return 'Unknown';
    }
  }

  /// Return user list relative to provided `userIds`
  /// Method is used on
  List<User> userList = <User>[];
  List<User> getuserDetail(List<String> userIds) {
    final List<User> list = _userlist.where((User x) {
      if (userIds.contains(x.key)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    return list;
  }
}
