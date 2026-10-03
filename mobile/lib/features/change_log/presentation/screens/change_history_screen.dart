import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/change_log/presentation/widgets/change_timeline.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// One listing's, deal's or client's history of changes: who changed what,
/// and when, newest first.
class ChangeHistoryScreen extends StatelessWidget {
  final ChangeEntityType type;
  final int id;

  const ChangeHistoryScreen({super.key, required this.type, required this.id});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ChangeTimeline(
      title: l10n.changeLogTitle,
      emptySubtitle: l10n.changeLogEmptyBody,
      load: (page) =>
          Injector.changeLogRepository.history(type, id, page: page),
    );
  }
}
