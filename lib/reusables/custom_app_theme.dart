import 'package:flutter/material.dart';

import 'colors.dart';

ThemeData? customAppTheme = ThemeData(
  useMaterial3: false,
  brightness: Brightness.dark,
  fontFamily: 'Tahoma',
  fontFamilyFallback: ['Helvetica', 'sans-serif'],
  scaffoldBackgroundColor: bgColor,
  cardTheme: CardThemeData(
    elevation: 0,
    color: cardColor,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: outlineColor),
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: white),
  textTheme: TextTheme(
    titleSmall: const TextStyle(color: textColor, fontSize: 12),
    headlineSmall: const TextStyle(color: textColor, fontSize: 12),
    labelSmall: const TextStyle(color: textColor, fontSize: 12),
    bodySmall: const TextStyle(color: textColor, fontSize: 12),
    displaySmall: const TextStyle(color: textColor, fontSize: 12),
    titleMedium: TextStyle(color: textMediumColor, fontSize: 13),
    headlineMedium: TextStyle(color: textMediumColor, fontSize: 13),
    labelMedium: TextStyle(color: textMediumColor, fontSize: 13),
    bodyMedium: TextStyle(color: textMediumColor, fontSize: 13),
    displayMedium: TextStyle(color: textMediumColor, fontSize: 13),
    titleLarge: const TextStyle(color: white, fontSize: 14),
    headlineLarge: const TextStyle(color: white, fontSize: 14),
    labelLarge: const TextStyle(color: white, fontSize: 14),
    bodyLarge: const TextStyle(color: white, fontSize: 14),
    displayLarge: const TextStyle(color: white, fontSize: 14),
  ),
  iconTheme: const IconThemeData(color: primaryColor),
  buttonTheme: const ButtonThemeData(buttonColor: primaryColor),
  listTileTheme: const ListTileThemeData(iconColor: primaryColor),
  dialogTheme: const DialogThemeData(backgroundColor: white),
  bottomAppBarTheme: const BottomAppBarThemeData(color: primaryColor),
  textSelectionTheme: const TextSelectionThemeData(cursorColor: primaryColor),
  dividerTheme: DividerThemeData(color: primaryColor.withValues(alpha: 0.15), thickness: 1),
  popupMenuTheme: const PopupMenuThemeData(
    color: white,
    textStyle: TextStyle(color: black),
  ),
  tabBarTheme: const TabBarThemeData(labelStyle: TextStyle(fontSize: 12), unselectedLabelStyle: TextStyle(fontSize: 12), indicatorColor: white),
  tooltipTheme: const TooltipThemeData(
    decoration: BoxDecoration(color: grey, borderRadius: BorderRadius.all(Radius.circular(8))),
    textStyle: TextStyle(color: white),
    padding: EdgeInsets.all(10),
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return bgCktbet;
      }
      return grey;
    }),
  ),
  checkboxTheme: CheckboxThemeData(
    side: BorderSide(color: black),
    checkColor: WidgetStateProperty.all<Color>(white),
    fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
      if (states.contains(WidgetState.selected)) {
        return bgCktbet;
      }
      return none;
    }),
  ),
  scrollbarTheme: ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(grey),
    trackColor: WidgetStateProperty.all(white),
    thumbVisibility: WidgetStateProperty.all(false),
    trackVisibility: WidgetStateProperty.all(true),
    thickness: WidgetStateProperty.all(8),
    radius: const Radius.circular(10),
    minThumbLength: 50,
    crossAxisMargin: 2,
    mainAxisMargin: 2,
    interactive: true,
  ),
);

final ThemeData rangeSelectorTheme = ThemeData(
  datePickerTheme: const DatePickerThemeData(
    shape: BeveledRectangleBorder(),
    surfaceTintColor: white,
    backgroundColor: white,
    rangePickerHeaderForegroundColor: white,
    rangePickerHeaderBackgroundColor: darkGreen,
    headerBackgroundColor: darkGreen,
    headerForegroundColor: white,
  ),
  iconTheme: const IconThemeData(color: white),
);
