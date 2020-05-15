import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/helpers/routes.dart';
import 'package:instafram/src/states/application_state.dart';
import 'package:instafram/src/states/authentication_state.dart';
import 'package:instafram/src/states/feed_state.dart';
import 'package:instafram/src/states/notification_state.dart';
import 'package:instafram/src/states/search_state.dart';
import 'package:instafram/src/states/user_message_service.dart';
import 'package:provider/provider.dart';

class Instafram extends StatelessWidget {
  @override
  MultiProvider build(BuildContext context) => MultiProvider(
        providers: <SingleChildCloneableWidget>[
          ChangeNotifierProvider<ApplicationState>(
              create: (_) => ApplicationState()),
          ChangeNotifierProvider<AuthenticationState>(
              create: (_) => AuthenticationState()),
          ChangeNotifierProvider<FeedState>(create: (_) => FeedState()),
          ChangeNotifierProvider<UserMessageState>(
              create: (_) => UserMessageState()),
          ChangeNotifierProvider<SearchState>(create: (_) => SearchState()),
          ChangeNotifierProvider<NotificationState>(
              create: (_) => NotificationState()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Instafram',
          theme: apptheme.copyWith(
            textTheme: GoogleFonts.muliTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          routes: Routes.route(),
          onGenerateRoute: (RouteSettings settings) =>
              Routes.onGenerateRoute(settings),
          onUnknownRoute: (RouteSettings settings) =>
              Routes.onUnknownRoute(settings),
        ),
      );
}
