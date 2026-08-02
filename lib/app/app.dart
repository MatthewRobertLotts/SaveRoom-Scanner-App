import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'app_theme.dart';

class SaveRoomScannerApp extends StatelessWidget {
  const SaveRoomScannerApp({
    super.key,
    this.forceFixtureMode,
    this.initialRoute,
  });

  final bool? forceFixtureMode;
  final String? initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveRoom Scanner',
      theme: buildAppTheme(),
      initialRoute: initialRoute ?? AppRoutes.home,
      routes: AppRoutes.routes(forceFixtureMode: forceFixtureMode),
    );
  }
}
