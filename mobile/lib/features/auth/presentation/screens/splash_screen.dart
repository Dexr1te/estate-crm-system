import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/images/splash-white.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
