// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:streaming_demo_app/AppFunctions/app_color.dart';
import 'package:streaming_demo_app/AppFunctions/app_strings.dart';

class AppText extends StatelessWidget {
  final double size;
  final Color color;
  final FontWeight fontWeight;
  final String? text;
  final TextAlign? textAlign;
  final double? lineHeight;
  final bool underline;
  final Color underlineColor;
  final double underlineSize;
  final bool lineThrough;
  final int maxline;
  final String fontFamily;
  final FontStyle fontStyle;

  const AppText(
    this.text, {
    super.key,
    this.size = 14,
    this.lineHeight = 1.2,
    this.color = AppColors.black,
    this.lineThrough = false,
    this.underline = false,
    this.underlineColor = AppColors.black,
    this.underlineSize = 2,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.center,
    this.maxline = 500,
    this.fontFamily = AppStrings.fontFamilyRoboto,
    this.fontStyle = FontStyle.normal,
  });

  //----------------------------------light----------------------------------//

  // AppText.light10(
  //   String text, {
  //   Color color = AppColors.black,
  //   TextAlign textAlign = TextAlign.center,
  //   double lineHeight = 1.2,
  //   bool underline = false,
  //   bool lineThrough = false,
  //   int maxline = 500,
  //   String fontFamily = AppStrings.fontFamilyRoboto,
  //   double underlineSize = 1,
  //   FontStyle fontStyle = FontStyle.normal,
  // }) : this(
  //         text,
  //         size: 10.w,
  //         fontWeight: FontWeight.normal,
  //         color: color,
  //         textAlign: textAlign,
  //         lineHeight: lineHeight,
  //         underline: underline,
  //         lineThrough: lineThrough,
  //         maxline: maxline,
  //         fontFamily: fontFamily,
  //         underlineColor: color,
  //         underlineSize: underlineSize.w,
  //         fontStyle: fontStyle,
  //       );

  //----------------------------------regular----------------------------------//

  AppText.regular8(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 8.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.regular10(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 10.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.regular12(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 12.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.regular13(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 13.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.regular14(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 14.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.regular16(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 16.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.regular18(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 18.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.regular20(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 20.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.regular22(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 22.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.regular26(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 26.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.regular40(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 40.w,
          fontWeight: FontWeight.w400,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  //----------------------------------medium----------------------------------//

  AppText.medium10(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 10.w,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.medium12(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 12.w,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.medium14(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 14.w,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.medium16(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 16.w,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.medium18(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 18.w,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.medium20(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 20.w,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.medium22(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 22.w,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.medium24(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 24.w,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.medium30(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 30.w,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.medium36(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 36.w,
          fontWeight: FontWeight.w500,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  //----------------------------------------semi bold--------------------------------------//

  AppText.semiBold12(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 12.w,
          fontWeight: FontWeight.w600,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.semiBold14(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 14.w,
          fontWeight: FontWeight.w600,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.semiBold16(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 16.w,
          fontWeight: FontWeight.w600,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.semiBold18(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 18.w,
          fontWeight: FontWeight.w600,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.semiBold20(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 20.w,
          fontWeight: FontWeight.w600,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.semiBold22(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 22.w,
          fontWeight: FontWeight.w600,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.semiBold24(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 24.w,
          fontWeight: FontWeight.w600,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.semiBold26(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 26.w,
          fontWeight: FontWeight.w600,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.semiBold34(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 34.w,
          fontWeight: FontWeight.w600,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  //----------------------------------bold----------------------------------//

  AppText.bold9(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 9.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold10(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 10.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold12(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 12.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold14(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 14.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold16(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 16.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold18(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 18.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold20(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 20.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold22(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 22.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold24(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 24.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold26(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 26.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold30(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 30.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold42(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 42.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  AppText.bold58(
    String text, {
    Color color = AppColors.black,
    TextAlign textAlign = TextAlign.center,
    double lineHeight = 1.2,
    bool underline = false,
    bool lineThrough = false,
    int maxline = 500,
    String fontFamily = AppStrings.fontFamilyRoboto,
    double underlineSize = 1,
    FontStyle fontStyle = FontStyle.normal,
  }) : this(
          text,
          size: 59.w,
          fontWeight: FontWeight.w700,
          color: color,
          textAlign: textAlign,
          lineHeight: lineHeight,
          underline: underline,
          lineThrough: lineThrough,
          maxline: maxline,
          fontFamily: fontFamily,
          underlineColor: color,
          underlineSize: underlineSize.w,
          fontStyle: fontStyle,
        );

  //=============================================================================================//

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      maxLines: maxline,
      style: TextStyle(
        height: lineHeight,
        color: color,
        fontSize: size,
        fontWeight: fontWeight,
        decorationColor: underlineColor,
        decorationThickness: underlineSize,
        decoration: lineThrough
            ? TextDecoration.lineThrough
            : underline
                ? TextDecoration.underline
                : TextDecoration.none,
        fontFamily: fontFamily,
        fontStyle: fontStyle,
      ),
    );
  }
}
