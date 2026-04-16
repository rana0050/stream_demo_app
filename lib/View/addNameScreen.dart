import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:streaming_demo_app/AppData/local/constant.dart';
import 'package:streaming_demo_app/AppData/local/shared_pref_helper.dart';
import 'package:streaming_demo_app/AppFunctions/appNavigationFunctions.dart';
import 'package:streaming_demo_app/AppFunctions/appTextFunctions.dart';
import 'package:streaming_demo_app/AppFunctions/app_strings.dart';
import 'package:streaming_demo_app/AppFunctions/showToastFunction.dart';
import 'package:streaming_demo_app/AppServices/streamingFirebaseService.dart';
import 'package:streaming_demo_app/View/presenterScreen.dart';
import 'package:streaming_demo_app/View/playerWaitingScreen.dart';
import 'package:uuid/uuid.dart';

class AddNameScreen extends StatefulWidget {
  const AddNameScreen({super.key});

  @override
  State<AddNameScreen> createState() => _AddNameScreenState();
}

class _AddNameScreenState extends State<AddNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showToast('Please enter your name');
      return;
    }
    if (name.length < 2) {
      showToast('Name must be at least 2 characters');
      return;
    }

    setState(() => _isLoading = true);

    // Persist name + role
    SharedPreferencesHelper.setUserName(name: name);
    constant.userName = name;

    // If player, ensure persistent UUID is generated
    if (constant.userRole == AppStrings.playerText) {
      String existingId = SharedPreferencesHelper.getPlayerId();
      if (existingId.isEmpty) {
        existingId = const Uuid().v4();
        SharedPreferencesHelper.setPlayerId(id: existingId);
      }
      constant.playerId = existingId;
      // Register player in Firebase
      streamingFirebaseService.initialize();
      await streamingFirebaseService.savePlayerName(existingId, name);
    } else {
      // Presenter — save name to Firebase
      streamingFirebaseService.initialize();
      await streamingFirebaseService.savePresenterName(name);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (constant.userRole == AppStrings.presenterText) {
      appNavigationMethods.pushAndRemoveUntilNavigation(context, const PresenterScreen());
    } else {
      appNavigationMethods.pushAndRemoveUntilNavigation(context, const PlayerWaitingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 48.w),

                // Logo / Icon
                Center(
                  child: Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.w),
                    ),
                    child: Icon(Icons.live_tv_rounded, color: Colors.white, size: 36.w),
                  ),
                ),
                SizedBox(height: 32.w),

                // Heading
                Center(
                  child: AppText.bold26(
                    'Welcome! ${constant.userRole} 👋',
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8.w),
                Center(
                  child: AppText.regular14(
                    'Enter your name and choose your role to get started.',
                    color: Colors.white60,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 40.w),

                // Name Label
                AppText.medium14('Your Name', color: Colors.white70),
                SizedBox(height: 10.w),

                // Name TextField
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 16.w, color: Colors.white, fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(fontSize: 14.w, color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.07),
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20.w, color: Colors.white54),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white12, width: 1.w),
                      borderRadius: BorderRadius.circular(14.w),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white12, width: 1.w),
                      borderRadius: BorderRadius.circular(14.w),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFF7C3AED), width: 1.5.w),
                      borderRadius: BorderRadius.circular(14.w),
                    ),
                  ),
                  onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                  onFieldSubmitted: (_) => _saveName(),
                ),

                SizedBox(height: 28.w),

                // Continue button
                InkWell(
                  onTap: _isLoading ? null : _saveName,
                  borderRadius: BorderRadius.circular(16.w),
                  child: Container(
                    height: 58.w,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.w),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : AppText.bold16('Continue', color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 48.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
