import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:streaming_demo_app/AppFunctions/app_color.dart';

showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: AppColors.black,
    textColor: AppColors.white,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    fontSize: 16.w,
  );
}

showErrorToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: AppColors.textRedColor,
    textColor: AppColors.white,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    fontSize: 16.w,
  );
}

showSuccessToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: AppColors.textGreenColor,
    textColor: AppColors.white,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    fontSize: 16.w,
  );
}
