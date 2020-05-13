import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instafram/src/helpers/main_theme.dart';
import 'package:instafram/src/helpers/routes.dart';
import 'package:instafram/src/services/application_service.dart';
import 'package:instafram/src/services/authentication_service.dart';
import 'package:provider/provider.dart';

class Instafram extends StatelessWidget {
  @override
  MultiProvider build(BuildContext context) => MultiProvider(
        providers: <SingleChildCloneableWidget>[
          ChangeNotifierProvider<ApplicationService>(
              create: (_) => ApplicationService()),
          ChangeNotifierProvider<AuthenticationService>(
              create: (_) => AuthenticationService()),
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
