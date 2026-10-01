import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/clients/domain/client_birthday.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// The client's birthday on the form: picked from a calendar, with the year
/// kept or left out, and taken off with a tap.
class ClientBirthdayField extends StatelessWidget {
  final ClientBirthday? value;
  final ValueChanged<ClientBirthday?> onChanged;

  const ClientBirthdayField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// A year to show the calendar in when the birthday has none: a leap year,
  /// so 29 February can still be picked.
  static const _anyLeapYear = 1992;

  /// [withYear] is the "Year unknown" pill turned off: the year picked is
  /// kept even though the birthday had none.
  Future<void> _pick(BuildContext context, {bool withYear = false}) async {
    final now = AppClock.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = value;
    final initial = current == null
        ? DateTime(_anyLeapYear, now.month, 1)
        : DateTime(current.year ?? _anyLeapYear, current.month, current.day);
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(today) ? today : initial,
      firstDate: DateTime(1900),
      lastDate: today,
      initialDatePickerMode:
          current == null ? DatePickerMode.year : DatePickerMode.day,
    );
    if (date == null) return;
    final picked =
        ClientBirthday(month: date.month, day: date.day, year: date.year);
    // Otherwise a birthday already without its year stays so.
    onChanged(!withYear && current != null && current.year == null
        ? picked.withoutYear()
        : picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final current = value;

    return LabelledField(
      label: l10n.clientsBirthday,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: PickerField(
                  key: const ValueKey('client-birthday'),
                  value: current == null
                      ? null
                      : clientBirthdayLabel(current, locale),
                  placeholder: l10n.clientsBirthdayPick,
                  onTap: () => _pick(context),
                  trailingIcon: Icons.cake_outlined,
                ),
              ),
              if (current != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  key: const ValueKey('client-birthday-clear'),
                  tooltip: l10n.clientsBirthdayClear,
                  constraints: const BoxConstraints(
                      minWidth: AppMetrics.minHitTarget,
                      minHeight: AppMetrics.minHitTarget),
                  onPressed: () => onChanged(null),
                  icon: Icon(Icons.close_rounded,
                      size: 18, color: t.textSecondary),
                ),
              ],
            ],
          ),
          if (current != null) ...[
            const SizedBox(height: 8),
            FilterPill(
              key: const ValueKey('client-birthday-no-year'),
              label: l10n.clientsBirthdayNoYear,
              selected: current.year == null,
              onCard: true,
              onTap: () => current.year == null
                  ? _pick(context, withYear: true)
                  : onChanged(current.withoutYear()),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            ),
            if (current.year == null) ...[
              const SizedBox(height: 6),
              Text(
                l10n.clientsBirthdayHint,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFonts.sans,
                    fontSize: 11.5,
                    height: 1.35,
                    color: t.textSecondary),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
