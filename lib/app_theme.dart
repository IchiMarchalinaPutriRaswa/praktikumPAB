import 'package:flutter/material.dart';

const Color kBrand = Color(0xFF176B5B);
const Color kBrandDark = Color(0xFF104D42);
const Color kAccent = Color(0xFFF2B58A);
const Color kPage = Color(0xFFFFFAF5);
const Color kText = Color(0xFF24332F);
const Color kMuted = Color(0xFF74817C);

ThemeData buildPreloTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: kBrand, brightness: Brightness.light),
  scaffoldBackgroundColor: kPage,
  appBarTheme: const AppBarTheme(
    backgroundColor: kPage,
    foregroundColor: kText,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(color: kText, fontWeight: FontWeight.w800),
    titleLarge: TextStyle(color: kText, fontWeight: FontWeight.w800),
    titleMedium: TextStyle(color: kText, fontWeight: FontWeight.w700),
    bodyMedium: TextStyle(color: kText, height: 1.45),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(color: kMuted, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8E5DD))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8E5DD))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBrand, width: 1.5)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kBrand,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
);
