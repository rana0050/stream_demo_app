import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:streaming_demo_app/AppFunctions/appNavigationFunctions.dart';
import 'package:streaming_demo_app/AppFunctions/appTextFunctions.dart';
import 'package:streaming_demo_app/AppFunctions/app_color.dart';
import 'package:streaming_demo_app/AppFunctions/deleteAppDataFunction.dart';
import 'package:streaming_demo_app/View/splashScreen.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(17, 17, 17, 0.9), // Dark glassmorphism backrgound
            borderRadius: BorderRadius.circular(16.w),
            border: Border.all(color: AppColors.menuTextGreyColor.withValues(alpha: 0.2), width: 1),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with background
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: AppColors.textRedColor.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(Icons.logout_rounded, size: 36.w, color: AppColors.textRedColor),
              ),

              SizedBox(height: 20.w),

              // Title
              AppText.bold20(
                "Logout",
                color: AppColors.white,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.w),

              // Message
              AppText.regular16(
                "Are you sure you want to logout from your account?",
                color: AppColors.menuTextGreyColor,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.w),

              // Action Buttons Row
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(12.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.w),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.w),
                          border: Border.all(color: AppColors.menuTextGreyColor, width: 1.w),
                        ),
                        child: Center(child: AppText.medium16("Cancel", color: AppColors.white)),
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Logout Button
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        deleteAppDataFunction();
                        appNavigationMethods.pushAndRemoveUntilNavigation(ctx, SplashScreen());
                      },
                      borderRadius: BorderRadius.circular(12.w),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.textRedColor.withValues(alpha: 0.9), AppColors.textRedColor]),
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Center(child: AppText.medium16("Logout", color: AppColors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
