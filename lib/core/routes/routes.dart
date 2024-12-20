import 'dart:io';

import 'package:denomination/core/utils_lib/globle_variable.dart';
import 'package:denomination/presentation/screens/home_sceen.dart';
import 'package:denomination/presentation/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class MyRoutes {
  static GoRouter router = GoRouter(
    navigatorKey: GlobalVariable.globalScaffoldKey,
    initialLocation: SPLASH,
    routes: [
      animatedGoRoute(
        path: SPLASH,
        name: SPLASH,
        pageBuilder: (context, state) => const SplashScreen(),
      ),
      animatedGoRoute(
        path: HOME,
        name: HOME,
        pageBuilder: (context, state) =>  HomeScreen(
          isEdit: false,
        ),
      ),
    ],
  );

  static const SPLASH = "/";
  static const HOME = "/home";
}

GoRoute animatedGoRoute({
  required String path,
  required String name,
  ExitCallback? onExitPage,
  required Widget Function(BuildContext, GoRouterState) pageBuilder,
}) {
  return GoRoute(
    path: path,
    name: name,
    onExit: onExitPage,
    pageBuilder: (context, state) => CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 400),
      child: pageBuilder(context, state),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    ),
  );
}
