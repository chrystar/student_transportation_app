import 'package:flutter/material.dart';
import '../config/constants.dart';

class SlidePageTransition extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;

  SlidePageTransition({
    required this.page,
    required this.settings,
  }) : super(
          settings: settings,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(
            milliseconds: AppConstants.pageTransitionDuration,
          ),
          reverseTransitionDuration: const Duration(
            milliseconds: AppConstants.pageTransitionDuration,
          ),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

class FadePageTransition extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;

  FadePageTransition({
    required this.page,
    required this.settings,
  }) : super(
          settings: settings,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(
            milliseconds: AppConstants.pageTransitionDuration,
          ),
          reverseTransitionDuration: const Duration(
            milliseconds: AppConstants.pageTransitionDuration,
          ),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

class ScalePageTransition extends PageRouteBuilder {
  final Widget page;
  final RouteSettings settings;

  ScalePageTransition({
    required this.page,
    required this.settings,
  }) : super(
          settings: settings,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(
            milliseconds: AppConstants.pageTransitionDuration,
          ),
          reverseTransitionDuration: const Duration(
            milliseconds: AppConstants.pageTransitionDuration,
          ),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = 0.0;
            const end = 1.0;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var scaleAnimation = animation.drive(tween);

            return ScaleTransition(
              scale: scaleAnimation,
              child: child,
            );
          },
        );
}
