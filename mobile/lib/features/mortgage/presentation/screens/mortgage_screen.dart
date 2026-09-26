import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/utils/contact_actions.dart';
import 'package:real_estate_crm/core/utils/share_gateway.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/mortgage/data/mortgage_memory.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_calculator.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_presets.dart';
import 'package:real_estate_crm/features/mortgage/presentation/mortgage_copy.dart';
import 'package:real_estate_crm/features/mortgage/presentation/widgets/mortgage_inputs.dart';
import 'package:real_estate_crm/features/mortgage/presentation/widgets/mortgage_results.dart';
import 'package:real_estate_crm/features/mortgage/presentation/widgets/mortgage_schedule.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

class MortgageScreen extends StatefulWidget {
  final double price;
  final String? title;
  const MortgageScreen({super.key, required this.price, this.title});

  @override
  State<MortgageScreen> createState() => _MortgageScreenState();
}

class _MortgageScreenState extends State<MortgageScreen> {
  final _price = TextEditingController();
  final _down = TextEditingController();
  final _downPct = TextEditingController();
  final _rate = TextEditingController();
  final _fees = TextEditingController();

  late double _priceValue = widget.price < 0 ? 0 : widget.price;
  MortgageSettings _s = const MortgageSettings();
  double _feesValue = 0;
  bool _touched = false;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _price.text = _plain(_priceValue);
    _syncDownFields();
    _rate.text = formatRate(_s.ratePercent);
    _restore();
  }

  Future<void> _restore() async {
    final saved = await MortgageMemory.read(mortgageUserId(context));
    if (saved == null || !mounted || _touched) return;
    setState(() => _s = saved);
    _syncDownFields();
    _rate.text = formatRate(saved.ratePercent);
  }

  @override
  void dispose() {
    for (final c in [_price, _down, _downPct, _rate, _fees]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _plain(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  double get _downAmount => _priceValue * _s.downPercent / 100;

  void _syncDownFields({bool amount = true, bool percent = true}) {
    if (amount) _down.text = _plain(_downAmount.roundToDouble());
    if (percent) _downPct.text = formatPercent(_s.downPercent);
  }

  void _update(MortgageSettings next, {bool remember = true}) {
    _touched = true;
    setState(() => _s = next);
    if (remember) MortgageMemory.write(mortgageUserId(context), next);
  }

  void _onPrice(String raw) {
    _touched = true;
    setState(() => _priceValue = parseAmount(raw) ?? 0);
    _syncDownFields(percent: false);
  }

  void _onDownAmount(String raw) {
    final amount = parseAmount(raw) ?? 0;
    final pct = _priceValue <= 0 ? 0.0 : amount / _priceValue * 100;
    _update(_s.copyWith(downPercent: pct.clamp(0, 100).toDouble()));
    _syncDownFields(amount: false);
  }

  void _onDownPercent(String raw) {
    final pct = (parseAmount(raw) ?? 0).clamp(0, 100).toDouble();
    _update(_s.copyWith(downPercent: pct));
    _syncDownFields(percent: false);
  }

  void _onDownSlider(double pct) {
    _update(_s.copyWith(downPercent: pct.roundToDouble()));
    _syncDownFields();
  }

  void _onRate(String raw) {
    final rate = parseAmount(raw);
    if (rate == null || rate > 100) return;
    _update(_s.copyWith(ratePercent: rate));
  }

  void _onPreset(MortgagePreset p) {
    _update(_s.copyWith(
      ratePercent: p.ratePercent,
      termYears: p.termYears,
      downPercent: p.downPercent,
    ));
    _rate.text = formatRate(p.ratePercent);
    _syncDownFields();
  }

  void _onFees(String raw) =>
      setState(() => _feesValue = parseAmount(raw) ?? 0);

  MortgageInput get _input => MortgageInput(
        price: _priceValue,
        downPayment: _downAmount,
        annualRatePercent: _s.ratePercent,
        termMonths: _s.termYears * 12,
        type: _s.type,
        fees: _feesValue,
      );

  Future<void> _share(MortgageInput input, MortgageResult result) async {
    if (_sharing) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _sharing = true);
    final outcome = await Injector.shareGateway.share(
      text: mortgageShareText(
          l10n: l10n, input: input, result: result, title: widget.title),
      subject: l10n.mortgageShareHeading,
    );
    if (!mounted) return;
    setState(() => _sharing = false);
    if (outcome == ShareOutcome.failed) {
      showActionUnavailable(context, l10n.mortgageShareFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final input = _input;
    final result = calculateMortgage(input);

    return DetailScaffold(
      title: l10n.mortgageTitle,
      bottomAction: AppFilledButton(
        key: const ValueKey('mortgage-send'),
        label: l10n.mortgageSend,
        loading: _sharing,
        onPressed: result.hasLoan ? () => _share(input, result) : null,
      ),
      children: [
        MortgageResultHero(result: result),
        MortgageInputsCard(
          settings: _s,
          price: _price,
          down: _down,
          downPercent: _downPct,
          rate: _rate,
          fees: _fees,
          onPrice: _onPrice,
          onDownAmount: _onDownAmount,
          onDownPercent: _onDownPercent,
          onDownSlider: _onDownSlider,
          onRate: _onRate,
          onPreset: _onPreset,
          onTerm: (years) => _update(_s.copyWith(termYears: years)),
          onType: (type) => _update(_s.copyWith(type: type)),
          onFees: _onFees,
        ),
        if (result.hasLoan) ...[
          MortgageMetrics(result: result),
          MortgageScheduleCard(
              key: ValueKey('schedule-${_s.termYears}'), result: result),
        ],
      ],
    );
  }
}
