import 'package:flutter/material.dart';

class AppTextScaling extends StatelessWidget {
  static const double maxScaleFactor = 1.5;

  final Widget child;
  const AppTextScaling({super.key, required this.child});

  @override
  Widget build(BuildContext context) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: maxScaleFactor,
        child: child,
      );
}
