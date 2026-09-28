import 'package:flutter/widgets.dart';
import 'package:real_estate_crm/core/utils/money.dart';

/// Sits at the app root and keeps every price on screen in step with
/// [AppCurrency].
///
/// Prices are formatted by a plain function ([formatPrice]) rather than read
/// from the widget tree, so nothing depends on the currency the way it depends
/// on a theme. When the manager picks another currency, or the language
/// changes, this marks the whole tree for rebuild — every screen keeps its
/// state and scroll position and simply prints the new sign.
class MoneyScope extends StatefulWidget {
  final Widget child;

  const MoneyScope({super.key, required this.child});

  @override
  State<MoneyScope> createState() => _MoneyScopeState();
}

class _MoneyScopeState extends State<MoneyScope> {
  @override
  void initState() {
    super.initState();
    AppCurrency.notifier.addListener(_rebuildAll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.maybeLocaleOf(context)?.languageCode;
    if (language != null && language != AppCurrency.locale) {
      AppCurrency.locale = language;
      // Mid-build here: repaint the rest once this frame is done.
      WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildAll());
    }
  }

  @override
  void dispose() {
    AppCurrency.notifier.removeListener(_rebuildAll);
    super.dispose();
  }

  void _rebuildAll() {
    if (!mounted) return;
    void mark(Element element) {
      element.markNeedsBuild();
      element.visitChildren(mark);
    }

    (context as Element).visitChildren(mark);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
