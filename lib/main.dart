import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:streaming_demo_app/AppData/local/constant.dart';
import 'package:streaming_demo_app/AppData/local/shared_pref_helper.dart';
import 'package:streaming_demo_app/AppFunctions/getDeviceDetails.dart';
import 'package:streaming_demo_app/AppServices/firebaseServices.dart';
import 'package:streaming_demo_app/View/splashScreen.dart';
import 'package:streaming_demo_app/AppFunctions/app_color.dart';
import 'package:streaming_demo_app/AppFunctions/app_strings.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.light, statusBarColor: Colors.transparent));
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      await SharedPreferencesHelper.init();
      SharedPreferencesHelper.setUserRole(role: AppStrings.playerText);

      // Initialize default Firebase app (needed for Crashlytics & FCM)
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      // Now that Firebase is initialized, we can fetch device details without error
      await getDeviceDetailsForEvents();

      // Crashlytics — record all Flutter fatal errors
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      // FCM — Request permission (iOS)
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // FCM — Get and store token
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        constant.currentFcmToken = fcmToken;
        debugPrint("FCM Token: $fcmToken");
      }

      // Run the app AIzaSyCce4gPZqXnN8GzTZsefeayLnJQye8DaFY
      runApp(MyApp());
    },
    (error, stack) {
      debugPrint('========== ERROR ==========');
      debugPrint(error.toString());
      debugPrint('========== STACK ==========');
      debugPrint(stack.toString());
      debugPrint('==========================');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    bool isTablet = size.shortestSide >= 600; // common tablet check

    return ScreenUtilInit(
      // designSize: const Size.fromWidth(430),
      designSize: isTablet
          ? const Size.fromWidth(834) // iPad Air logical size
          : const Size.fromWidth(430), // iPhone 14
      builder: (context, child) {
        return SafeArea(
          top: false,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Full Toss",
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: AppColors.white),
              useMaterial3: false,
              fontFamily: AppStrings.fontFamilyInter,
              primaryColor: AppColors.white,
              progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.white),
              textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.white),
            ),
            scrollBehavior: CustomScrollBehavior(),
            home: SplashScreen(),
          ),
        );
      },
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return GlowingOverscrollIndicator(color: AppColors.white, axisDirection: details.direction, child: child);
  }
}
