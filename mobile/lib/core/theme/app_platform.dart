import 'package:flutter/material.dart';

class AppPlatform {
  const AppPlatform._();

  static bool isCupertino(TargetPlatform platform) =>
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

  static bool cupertinoOf(BuildContext context) =>
      isCupertino(Theme.of(context).platform);
}
