import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_calculator.dart';
import 'package:real_estate_crm/features/mortgage/domain/mortgage_presets.dart';
import 'package:real_estate_crm/features/mortgage/presentation/mortgage_copy.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

const _number = TextInputType.numberWithOptions(decimal: true);

class MortgageInputsCard extends StatelessWidget {
  final MortgageSettings settings;
  final TextEditingController price;
  final TextEditingController down;
  final TextEditingController downPercent;
  final TextEditingController rate;
  final TextEditingController fees;
  final ValueChanged<String> onPrice;
  final ValueChanged<String> onDownAmount;
  final ValueChanged<String> onDownPercent;
  final ValueChanged<double> onDownSlider;
  final ValueChanged<String> onRate;
  final ValueChanged<MortgagePreset> onPreset;
  final ValueChanged<int> onTerm;
  final ValueChanged<MortgagePaymentType> onType;
  final ValueChanged<String> onFees;

  const MortgageInputsCard({
    super.key,
    required this.settings,
    required this.price,
    required this.down,
    required this.downPercent,
    required this.rate,
    required this.fees,
    required this.onPrice,
    required this.onDownAmount,
    required this.onDownPercent,
    required this.onDownSlider,
    required this.onRate,
    required this.onPreset,
    required this.onTerm,
    required this.onType,
    required this.onFees,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final note = TextStyle(
        fontFamily: AppFonts.sans,
        fontSize: 11,
        height: 1.4,
        color: t.textSecondary);

    return FormSectionCard(
      gap: 14,
      children: [
        LabelledField(
          label: l10n.mortgagePrice,
          child: AppTextField(
            key: const ValueKey('mortgage-price'),
            controller: price,
            keyboardType: _number,
            onChanged: onPrice,
          ),
        ),
        LabelledField(
          label: l10n.mortgageDownPayment,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      key: const ValueKey('mortgage-down-amount'),
                      controller: down,
                      keyboardType: _number,
                      onChanged: onDownAmount,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      key: const ValueKey('mortgage-down-percent'),
                      controller: downPercent,
                      keyboardType: _number,
                      onChanged: onDownPercent,
                      suffix: const _Suffix('%'),
                    ),
                  ),
                ],
              ),
              _TokenSlider(
                key: const ValueKey('mortgage-down-slider'),
                value:
                    settings.downPercent.clamp(0, kMaxDownPercent).toDouble(),
                max: kMaxDownPercent,
                divisions: kMaxDownPercent.round(),
                onChanged: onDownSlider,
              ),
            ],
          ),
        ),
        LabelledField(
          label: l10n.mortgageRate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                key: const ValueKey('mortgage-rate'),
                controller: rate,
                keyboardType: _number,
                onChanged: onRate,
                suffix: const _Suffix('%'),
              ),
              const SizedBox(height: 10),
              FilterPillWrap(pills: [
                for (final p in kMortgagePresets)
                  FilterPill(
                    key: ValueKey('mortgage-preset-${p.kind.name}'),
                    label: mortgagePresetLabel(l10n, p),
                    selected: settings.ratePercent == p.ratePercent,
                    onCard: true,
                    fontSize: 11.5,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    onTap: () => onPreset(p),
                  ),
              ]),
              const SizedBox(height: 8),
              Text(l10n.mortgagePresetsNote,
                  maxLines: 3, overflow: TextOverflow.ellipsis, style: note),
            ],
          ),
        ),
        LabelledField(
          label: l10n.mortgageTerm,
          child: Row(
            children: [
              Expanded(
                child: _TokenSlider(
                  key: const ValueKey('mortgage-term-slider'),
                  value: settings.termYears.toDouble(),
                  min: kMinTermYears.toDouble(),
                  max: kMaxTermYears.toDouble(),
                  divisions: kMaxTermYears - kMinTermYears,
                  onChanged: (v) => onTerm(v.round()),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.mortgageTermYears(settings.termYears),
                  key: const ValueKey('mortgage-term-label'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFonts.sans,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.textPrimary),
                ),
              ),
            ],
          ),
        ),
        LabelledField(
          label: l10n.mortgageType,
          child: SegmentedTabs(
            labels: [
              for (final type in MortgagePaymentType.values)
                mortgageTypeLabel(l10n, type),
            ],
            selectedIndex: settings.type.index,
            onSelected: (i) => onType(MortgagePaymentType.values[i]),
          ),
        ),
        LabelledField(
          label: l10n.mortgageFees,
          child: AppTextField(
            key: const ValueKey('mortgage-fees'),
            controller: fees,
            hint: l10n.mortgageFeesHint,
            keyboardType: _number,
            onChanged: onFees,
          ),
        ),
      ],
    );
  }
}

class _Suffix extends StatelessWidget {
  final String text;
  const _Suffix(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Align(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 13,
                  color: context.tokens.textSecondary)),
        ),
      );
}

class _TokenSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _TokenSlider({
    super.key,
    required this.value,
    this.min = 0,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        activeTrackColor: t.primary,
        inactiveTrackColor: t.border,
        thumbColor: t.primary,
        overlayColor: t.primary.withValues(alpha: 0.12),
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
      ),
      child: Slider(
        value: value.clamp(min, max).toDouble(),
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}
