import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_metrics.dart';
import 'package:real_estate_crm/core/theme/app_platform.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/app_bottom_sheet.dart';
import 'package:real_estate_crm/core/widgets/app_buttons.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

const double _wheelHeight = 216;

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  String? helpText,
}) async {
  if (!AppPlatform.cupertinoOf(context)) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: initialDatePickerMode,
      helpText: helpText,
    );
  }
  final first = DateUtils.dateOnly(firstDate);
  final last = DateUtils.dateOnly(lastDate);
  final wanted = DateUtils.dateOnly(initialDate ?? AppClock.now());
  final initial =
      wanted.isBefore(first) ? first : (wanted.isAfter(last) ? last : wanted);
  final picked = await _showWheelSheet(
    context,
    title: helpText ?? MaterialLocalizations.of(context).datePickerHelpText,
    initial: initial,
    wheel: (onChanged) => CupertinoDatePicker(
      mode: CupertinoDatePickerMode.date,
      initialDateTime: initial,
      minimumDate: first,
      maximumDate: last,
      onDateTimeChanged: onChanged,
    ),
  );
  return picked == null ? null : DateUtils.dateOnly(picked);
}

Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? helpText,
}) async {
  if (!AppPlatform.cupertinoOf(context)) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: helpText,
    );
  }
  final localizations = MaterialLocalizations.of(context);
  final format = localizations.timeOfDayFormat(
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context));
  final initial = DateTime(2000, 1, 1, initialTime.hour, initialTime.minute);
  final picked = await _showWheelSheet(
    context,
    title: helpText ?? localizations.timePickerDialHelpText,
    initial: initial,
    wheel: (onChanged) => CupertinoDatePicker(
      mode: CupertinoDatePickerMode.time,
      initialDateTime: initial,
      use24hFormat: hourFormat(of: format) != HourFormat.h,
      onDateTimeChanged: onChanged,
    ),
  );
  return picked == null ? null : TimeOfDay.fromDateTime(picked);
}

Future<DateTime?> _showWheelSheet(
  BuildContext context, {
  required String title,
  required DateTime initial,
  required Widget Function(ValueChanged<DateTime> onChanged) wheel,
}) =>
    showAppBottomSheet<DateTime>(
      context,
      title: title,
      useRootNavigator: true,
      builder: (_) => _WheelSheet(initial: initial, wheel: wheel),
    );

class _WheelSheet extends StatefulWidget {
  final DateTime initial;
  final Widget Function(ValueChanged<DateTime> onChanged) wheel;

  const _WheelSheet({required this.initial, required this.wheel});

  @override
  State<_WheelSheet> createState() => _WheelSheetState();
}

class _WheelSheetState extends State<_WheelSheet> {
  late DateTime _value = widget.initial;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _wheelHeight,
            child: widget.wheel((value) => _value = value),
          ),
          SizedBox(height: AppMetrics.blockGap(context)),
          AppFilledButton(
            key: const Key('app-picker-done'),
            label: AppLocalizations.of(context).coreDone,
            onPressed: () => Navigator.pop(context, _value),
          ),
        ],
      );
}
