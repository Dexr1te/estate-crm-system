import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/star_models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/stars/presentation/bloc/stars_bloc.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Where a starred record opens.
String starredRecordRoute(StarKey key) => switch (key.type) {
      StarType.client => '/clients/${key.id}',
      StarType.property => '/properties/${key.id}',
      StarType.deal => '/deals/${key.id}',
    };

IconData starTypeIcon(StarType type) => switch (type) {
      StarType.client => Icons.person_outline_rounded,
      StarType.property => Icons.home_work_outlined,
      StarType.deal => Icons.handshake_outlined,
    };

/// The heading a type's stars sit under on the Starred screen.
String starSectionLabel(AppLocalizations l10n, StarType type) => switch (type) {
      StarType.client => l10n.starsSectionClients,
      StarType.property => l10n.starsSectionListings,
      StarType.deal => l10n.starsSectionDeals,
    };

/// The record's title, or what it is when the server sent none.
String starredTitle(AppLocalizations l10n, StarredItem item) {
  if (item.title.trim().isNotEmpty) return item.title;
  return switch (item.type) {
    StarType.client => l10n.clientsClientFallback,
    StarType.property => l10n.propertiesProperty,
    StarType.deal => l10n.dealsFallbackTitle,
  };
}

String starFailureLabel(AppLocalizations l10n, StarsWriteFailure failure) {
  if (failure.failure.kind == ApiFailureKind.notFound) {
    return l10n.starsRecordGone;
  }
  return failure.starring ? l10n.starsStarFailed : l10n.starsUnstarFailed;
}

/// Says a star was put back — on the screen in front, only, so a screen
/// underneath does not say it a second time.
void showStarFailure(BuildContext context, StarsWriteFailure failure) {
  if (!context.mounted) return;
  if (ModalRoute.of(context)?.isCurrent == false) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(
        starFailureLabel(AppLocalizations.of(context), failure),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: context.tokens.dangerSolid,
    ));
}

/// Whether [curr] carries a write failure [prev] did not.
bool isNewStarFailure(StarsState prev, StarsState curr) =>
    curr.writeFailure != null &&
    !identical(prev.writeFailure, curr.writeFailure);
