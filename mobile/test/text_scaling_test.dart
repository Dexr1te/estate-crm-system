import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/theme/app_text_scaling.dart';

/// Stands in for the platform's scaler on a modern phone, which is not linear
/// and so does not collapse a clamp into a plain factor the way
/// `TextScaler.linear` does. That short-circuit is the reason this was
/// invisible to every widget test the app had.
class _PlatformScaler extends TextScaler {
  const _PlatformScaler();

  @override
  double scale(double fontSize) => fontSize;

  @override
  double get textScaleFactor => 1.0;
}

void main() {
  // Clamps intersect. The app's clamp sits above every screen, and Flutter's
  // own widgets add their own below it — BottomNavigationBar caps at 1.0, and
  // the date picker's header caps at whatever the current factor happens to be,
  // which on a default phone is exactly 1.0. Give the app's clamp a floor of
  // 1.0 and that intersection becomes the empty range [1.0, 1.0], which trips
  // an assertion inside TextScaler and paints a red box where the widget was.
  testWidgets('the app clamp survives a widget that caps scaling at 1.0',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: _PlatformScaler()),
        child: AppTextScaling(
          child: Builder(
            builder: (context) => MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.0,
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: Text('anything'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull,
        reason: 'a floor on the app clamp makes this intersection empty — see '
            'AppTextScaling');
  });
}
