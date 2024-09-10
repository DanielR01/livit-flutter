import 'package:flutter/material.dart';
import 'package:livit/utilities/background/main_background.dart';

class SlideInRoute extends PageRouteBuilder {
  final Widget page;
  SlideInRoute({required this.page})
      : super(
          opaque: false,
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Stack(
            children: [
              //const MainBackground(),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                  reverseCurve: Curves.easeOut,
                )),
                child: child,
              ),
            ],
          ),
          transitionDuration: const Duration(milliseconds: 500), // Even slower animation
        );
}
