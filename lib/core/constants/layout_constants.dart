import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class LayoutConstants {
  // ************* Sized ************* //
  static var noneSize = 0.0.h;
  static var tinySize = 2.0.h;
  static var lowSize = 4.0.h;
  static var defaultSize = 8.0.h;
  static var centralSize = 12.0.h;
  static var midSize = 16.0.h;
  static var highSize = 24.0.h;
  static var largeSize = 32.0.h;
  static var maxSize = 48.0.h;
  static var ultraSize = 64.0.h;
  static var maxUltraSize = 96.0.h;
  static var ultraMaxUltraSize = 128.0.h;

  // ************* All Padding ************* //
  static var tinyAllPadding = EdgeInsets.all(tinySize);
  static var lowAllPadding = EdgeInsets.all(lowSize);
  static var defaultAllPadding = EdgeInsets.all(defaultSize);
  static var centralAllPadding = EdgeInsets.all(centralSize);
  static var midAllPadding = EdgeInsets.all(midSize);
  static var highAllPadding = EdgeInsets.all(highSize);
  static var largeAllPadding = EdgeInsets.all(largeSize);
  static var maxAllPadding = EdgeInsets.all(maxSize);
  static var ultraAllPadding = EdgeInsets.all(ultraSize);

  // ************* Vertical Padding ************* //
  static var tinyVerticalPadding = EdgeInsets.symmetric(vertical: tinySize);
  static var lowVerticalPadding = EdgeInsets.symmetric(vertical: lowSize);
  static var defaultVerticalPadding =
      EdgeInsets.symmetric(vertical: defaultSize);
  static var centralVerticalPadding =
      EdgeInsets.symmetric(vertical: centralSize);
  static var midVerticalPadding = EdgeInsets.symmetric(vertical: midSize);
  static var highVerticalPadding = EdgeInsets.symmetric(vertical: highSize);
  static var largeVerticalPadding = EdgeInsets.symmetric(vertical: largeSize);
  static var maxVerticalPadding = EdgeInsets.symmetric(vertical: maxSize);
  static var ultraVerticalPadding = EdgeInsets.symmetric(vertical: ultraSize);

  // ************* Horizontal Padding ************* //
  static var tinyHorizontalPadding = EdgeInsets.symmetric(horizontal: tinySize);
  static var lowHorizontalPadding = EdgeInsets.symmetric(horizontal: lowSize);
  static var defaultHorizontalPadding =
      EdgeInsets.symmetric(horizontal: defaultSize);
  static var centralHorizontalPadding =
      EdgeInsets.symmetric(horizontal: centralSize);
  static var midHorizontalPadding = EdgeInsets.symmetric(horizontal: midSize);
  static var highHorizontalPadding = EdgeInsets.symmetric(horizontal: highSize);
  static var largeHorizontalPadding =
      EdgeInsets.symmetric(horizontal: largeSize);
  static var maxHorizontalPadding = EdgeInsets.symmetric(horizontal: maxSize);
  static var ultraHorizontalPadding =
      EdgeInsets.symmetric(horizontal: ultraSize);

  // ************* Horizontal Padding ************* //
  static var buttonPadding =
      EdgeInsets.symmetric(horizontal: midSize, vertical: midSize);

  // ************* left-right Padding ************* //
  static var buttonPaddingLeftRight =
      EdgeInsets.only(left: centralSize, right: centralSize);

  // ************* Empty Height ************* //
  static var tinyEmptyHeight = SizedBox(height: tinySize);
  static var lowEmptyHeight = SizedBox(height: lowSize);
  static var defaultEmptyHeight = SizedBox(height: defaultSize);
  static var centralEmptyHeight = SizedBox(height: centralSize);
  static var midEmptyHeight = SizedBox(height: midSize);
  static var highEmptyHeight = SizedBox(height: highSize);
  static var largeEmptyHeight = SizedBox(height: largeSize);
  static var maxEmptyHeight = SizedBox(height: maxSize);
  static var ultraEmptyHeight = SizedBox(height: ultraSize);

  // ************* Empty Width ************* //
  static var tinyEmptyWidth = SizedBox(width: tinySize);
  static var lowEmptyWidth = SizedBox(width: lowSize);
  static var defaultEmptyWidth = SizedBox(width: defaultSize);
  static var centralEmptyWidth = SizedBox(width: centralSize);
  static var midEmptyWidth = SizedBox(width: midSize);
  static var highEmptyWidth = SizedBox(width: highSize);
  static var largeEmptyWidth = SizedBox(width: largeSize);
  static var maxEmptyWidth = SizedBox(width: maxSize);
  static var ultraEmptyWidth = SizedBox(width: ultraSize);

  // ************* Radius ************* //
  static var lowRadius = 5.0;
  static var defaultRadius = 10.0;
  static var highRadius = 15.0;
  static var maxRadius = 30.0;

  // ************* Circular Radius ************* //
  static var defaultButtonBorder =
      BorderRadius.all(Radius.circular(defaultRadius));
  static var highButtonBorder = BorderRadius.all(Radius.circular(highRadius));
  static var maxButtonBorder = BorderRadius.all(Radius.circular(maxRadius));

  // ************* Elevations ************* //
  static var noneElevation = 0.0;
  static var lowElevation = 2.0;
  static var midElevation = 4.0;
  static var highElevation = 6.0;
  static var maxElevation = 8.0;

  // ************* Ratio's ************* //
  static var widescreenRatio = 5 / 4;
  static var fullScreenRatio = 9 / 16;
}
