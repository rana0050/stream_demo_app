import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:streaming_demo_app/AppData/local/constant.dart';
import 'package:streaming_demo_app/AppData/local/shared_pref_helper.dart';
import 'package:streaming_demo_app/AppFunctions/appNavigationFunctions.dart';
import 'package:streaming_demo_app/AppFunctions/app_color.dart';
import 'package:streaming_demo_app/AppFunctions/app_strings.dart';
import 'package:streaming_demo_app/AppFunctions/deleteAppDataFunction.dart';
import 'package:streaming_demo_app/AppServices/streamingFirebaseService.dart';
import 'package:streaming_demo_app/View/addNameScreen.dart';
import 'package:streaming_demo_app/View/presenterScreen.dart';
import 'package:streaming_demo_app/View/playerWaitingScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // deleteAppDataFunction();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    _checkAndNavigate();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final String name = SharedPreferencesHelper.getUserName();
    final String role = SharedPreferencesHelper.getUserRole();
    constant.userRole = role;

    if (name.isEmpty || role.isEmpty) {
      // First launch → choose name + role
      appNavigationMethods.pushAndRemoveUntilNavigation(context, const AddNameScreen());
      return;
    }

    // Restore constants
    constant.userName = name;

    // Initialize streaming Firebase service
    streamingFirebaseService.initialize();

    if (role == AppStrings.presenterText) {
      appNavigationMethods.pushAndRemoveUntilNavigation(context, const PresenterScreen());
    } else {
      // Restore player UUID
      final String playerId = SharedPreferencesHelper.getPlayerId();
      if (playerId.isNotEmpty) {
        constant.playerId = playerId;
        // Re-register player name in Firebase (handles app restarts)
        await streamingFirebaseService.savePlayerName(playerId, name);
      }
      if (mounted) {
        // await streamingFirebaseService.setPresenterLive(constant.userName);

        appNavigationMethods.pushAndRemoveUntilNavigation(context, const PlayerWaitingScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22.w),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(Icons.live_tv_rounded, color: Colors.white, size: 40.w),
              ),
              SizedBox(height: 24.w),
              Text(
                'StreamLive',
                style: TextStyle(
                  fontSize: 28.w,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8.w),
              Text(
                'Real-time live streaming',
                style: TextStyle(fontSize: 14.w, color: Colors.white38),
              ),
              SizedBox(height: 48.w),
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
