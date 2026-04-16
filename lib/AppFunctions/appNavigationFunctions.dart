import 'package:flutter/cupertino.dart';

class NavigationFunction {
  PageRoute<T> _createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.linear;
        var tween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
        var fadeAnimation = animation.drive(tween);
        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }

  Future<dynamic> pushNavigation(BuildContext context, Widget page) {
    if (context.mounted) {
      return Navigator.push(context, _createRoute(page));
    } else {
      debugPrint("Navigation skipped: Context is not mounted");
      return Future.value();
    }
  }

  Future<dynamic> pushReplacementNavigation(BuildContext context, Widget page) {
    if (context.mounted) {
      return Navigator.pushReplacement(context, _createRoute(page));
    } else {
      debugPrint("Navigation skipped: Context is not mounted");
      return Future.value();
    }
  }

  Future<dynamic> pushAndRemoveUntilNavigation(BuildContext context, Widget page) {
    if (context.mounted) {
      return Navigator.pushAndRemoveUntil(context, _createRoute(page), (route) => false);
    } else {
      debugPrint("Navigation skipped: Context is not mounted");
      return Future.value();
    }
  }

  void goBack(BuildContext context) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void goBackWithResult<T>(BuildContext context, [T? result]) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }
}

NavigationFunction appNavigationMethods = NavigationFunction();
