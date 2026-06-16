import 'package:flutter/material.dart';

mixin AppStringConstants {
  static const String appName = "6Ball";
  static const String dated = "6Ball";
  static const String version = "0.0.1";
  static const String buildNumber = "23";
  static const String hiveBoxKey = "6ball_global_web_box";
  static const String credentialsBoxKey = "6ball_credentials_data_key";
  static const String whatsappLink = "https://wa.link/6ballcs";
  static const String whatsappLink1 = "https://wa.link/6ball";
  static const String insta = "https://www.instagram.com/6ballofficial";
  static const String email = "mailto:example@example.com";
  static const String telegram = "https://t.me/official6ball";
  static const String apkDownloadLink = "https://downloadapp.6ball.com";
  static const String apkDownloadLinkQr = 'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${AppStringConstants.apkDownloadLink}';
}
double maxPrice = 20;
double soccerAndTennis = 10;
ValueNotifier<String> ip = ValueNotifier("");
ValueNotifier<String> isp = ValueNotifier("");
ValueNotifier<String> agent = ValueNotifier("");
ValueNotifier<String> address = ValueNotifier("");
