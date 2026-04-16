import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:streaming_demo_app/AppData/local/constant.dart';
import 'package:streaming_demo_app/AppFunctions/appNavigationFunctions.dart';
import 'package:streaming_demo_app/AppFunctions/appTextFunctions.dart';
import 'package:streaming_demo_app/AppServices/streamingFirebaseService.dart';
import 'package:streaming_demo_app/View/addNameScreen.dart';
import 'package:streaming_demo_app/View/playerLiveScreen.dart';

class PlayerWaitingScreen extends StatefulWidget {
  const PlayerWaitingScreen({super.key});

  @override
  State<PlayerWaitingScreen> createState() => _PlayerWaitingScreenState();
}

class _PlayerWaitingScreenState extends State<PlayerWaitingScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<DatabaseEvent>? _isLiveSubscription;
  bool _navigatingToLive = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    streamingFirebaseService.initialize();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _listenToPresenterStatus();
  }

  @override
  void dispose() {
    _isLiveSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _listenToPresenterStatus() {
    _isLiveSubscription = streamingFirebaseService.isLiveStream.listen(
      (event) async {
        if (!mounted) return;
        final bool isLive = event.snapshot.value == true;
        debugPrint('PlayerWaitingScreen: isLive = $isLive');

        if (isLive && !_navigatingToLive) {
          _navigatingToLive = true;
          // Navigate to live screen and wait for it to return
          await appNavigationMethods.pushNavigation(
            context,
            const PlayerLiveScreen(),
          );
          // When PlayerLiveScreen pops (stream ended), reset flag
          if (mounted) {
            setState(() => _navigatingToLive = false);
          }
        }
      },
      onError: (e) {
        debugPrint('PlayerWaitingScreen Firebase listener error: $e');
      },
    );
  }

  void _signOut() {
    appNavigationMethods.pushAndRemoveUntilNavigation(context, const AddNameScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(child: _buildWaitingBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: AppText.medium12('WAITING', color: Colors.white54),
          ),
          const Spacer(),
          AppText.semiBold16(
            constant.userName.isNotEmpty ? constant.userName : 'Player',
            color: Colors.white,
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _signOut,
            child: Icon(Icons.logout_rounded, color: Colors.white54, size: 22.w),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingBody() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated pulse ring
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 130.w,
                height: 130.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF7C3AED).withOpacity(0.12),
                  border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.35), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.18),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(Icons.live_tv_rounded, size: 56.w, color: const Color(0xFF7C3AED)),
              ),
            ),
            SizedBox(height: 36.w),

            // Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
              ).createShader(bounds),
              child: Text(
                'Wait for the Show',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.w,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 14.w),

            AppText.regular14(
              'The stream will automatically begin\nwhen the presenter goes live.',
              color: Colors.white38,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.w),

            // Status card
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _PulsingDot(),
                  SizedBox(width: 10.w),
                  AppText.regular13('Waiting for presenter to go live...', color: Colors.white54),
                ],
              ),
            ),

            SizedBox(height: 32.w),
            const _PulsingDots(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Small single pulsing dot (status indicator)
// ─────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: const BoxDecoration(
          color: Color(0xFF7C3AED),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Animated pulsing dots
// ─────────────────────────────────────────────
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final delay = i * 0.2;
        return AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final t = (((_controller.value - delay) % 1.0 + 1.0) % 1.0);
            final opacity = t < 0.5 ? t * 2 : 2 - t * 2;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Opacity(
                opacity: opacity.clamp(0.2, 1.0),
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
