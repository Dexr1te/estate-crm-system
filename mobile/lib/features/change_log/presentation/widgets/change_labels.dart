import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/change_log/domain/change_entry.dart';
import 'package:real_estate_crm/features/clients/domain/client_birthday.dart';
import 'package:real_estate_crm/features/clients/presentation/widgets/lead_source.dart';
import 'package:real_estate_crm/features/properties/presentation/widgets/mandate_badge.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Fields whose old and new text is too long to read as "from → to"; the log
/// says only that they were edited.
const _editedOnly = {'description', 'notes', 'lostNote', 'location'};

const _money = {
  'price',
  'dealPrice',
  'monthlyRent',
  'budget',
  'budgetMin',
  'budgetMax',
};

const _area = {'areaSqm', 'minAreaSqm'};

/// A field of a listing, deal or client in words; one this app does not know
/// is "Other details".
String changeFieldLabel(AppLocalizations l10n, String? field) =>
    _fieldLabel(l10n, field) ?? l10n.changeLogFieldOther;

String? _fieldLabel(AppLocalizations l10n, String? field) => switch (field) {
      'title' => l10n.changeLogFieldTitle,
      'description' => l10n.changeLogFieldDescription,
      'address' => l10n.changeLogFieldAddress,
      'city' => l10n.changeLogFieldCity,
      'type' => l10n.changeLogFieldType,
      'status' => l10n.changeLogFieldStatus,
      'price' => l10n.changeLogFieldPrice,
      'areaSqm' => l10n.changeLogFieldArea,
      'rooms' => l10n.changeLogFieldRooms,
      'floor' => l10n.changeLogFieldFloor,
      'totalFloors' => l10n.changeLogFieldTotalFloors,
      'location' => l10n.changeLogFieldLocation,
      'mandateType' => l10n.changeLogFieldMandate,
      'mandateEndDate' => l10n.changeLogFieldMandateEnd,
      'agent' => l10n.changeLogFieldAgent,
      'dealPrice' => l10n.changeLogFieldDealPrice,
      'budget' => l10n.changeLogFieldBudget,
      'commissionPercent' => l10n.changeLogFieldCommission,
      'lostReason' => l10n.changeLogFieldLostReason,
      'lostNote' => l10n.changeLogFieldLostNote,
      'notes' => l10n.changeLogFieldNotes,
      'client' => l10n.changeLogFieldClient,
      'property' => l10n.changeLogFieldListing,
      'fullName' => l10n.changeLogFieldName,
      'phone' => l10n.changeLogFieldPhone,
      'email' => l10n.changeLogFieldEmail,
      'leadSource' => l10n.changeLogFieldLeadSource,
      'leadSourceDetail' => l10n.changeLogFieldLeadSourceDetail,
      'wantedType' => l10n.changeLogFieldWantedType,
      'wantedCity' => l10n.changeLogFieldWantedCity,
      'budgetMin' => l10n.changeLogFieldBudgetMin,
      'budgetMax' => l10n.changeLogFieldBudgetMax,
      'minRooms' => l10n.changeLogFieldMinRooms,
      'minAreaSqm' => l10n.changeLogFieldMinArea,
      'birthday' => l10n.changeLogFieldBirthday,
      'tags' => l10n.changeLogFieldTags,
      'kind' => l10n.dealsKind,
      'monthlyRent' => l10n.leasesMonthlyRent,
      'leaseStart' => l10n.leasesStart,
      'leaseEnd' => l10n.leasesEnd,
      'leaseReminderDays' => l10n.leasesReminder,
      'landlord' => l10n.leasesLandlord,
      _ => null,
    };

T? _byName<T extends Enum>(List<T> values, String name) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

/// One value as the server wrote it, in words: a status or a type by its
/// label, money in the agency's currency, a date in the reader's language.
/// Never the server's own enum name: a value this app does not know reads as
/// "another value".
String changeValueLabel(AppLocalizations l10n, ChangeEntityType? type,
    String field, String? value, String locale) {
  if (value == null || value.trim().isEmpty) return l10n.changeLogNoValue;
  final unknown = l10n.changeLogUnknownValue;
  String? label;
  switch (field) {
    case 'status':
      if (type == ChangeEntityType.deal) {
        final s = _byName(DealStatus.values, value);
        label = s == null ? null : dealStatusLabel(l10n, s);
      } else {
        final s = _byName(PropertyStatus.values, value);
        label = s == null ? null : propertyStatusLabel(l10n, s);
      }
    case 'type':
      if (type == ChangeEntityType.client) {
        final c = _byName(ClientType.values, value);
        label = c == null ? null : clientTypeLabel(l10n, c);
      } else {
        final p = _byName(PropertyType.values, value);
        label = p == null ? null : propertyTypeLabel(l10n, p);
      }
    case 'wantedType':
      final p = _byName(PropertyType.values, value);
      label = p == null ? null : propertyTypeLabel(l10n, p);
    case 'mandateType':
      final m = _byName(MandateType.values, value);
      label = m == null ? null : mandateTypeLabel(l10n, m);
    case 'lostReason':
      final r = dealLostReasonFromName(value);
      label = r == null ? null : dealLostReasonLabel(l10n, r);
    case 'leadSource':
      final s = leadSourceFromName(value);
      label = s == null ? null : leadSourceLabel(l10n, s);
    case 'commissionPercent':
      final n = double.tryParse(value);
      label = n == null ? null : l10n.changeLogPercent(formatRate(n));
    case 'kind':
      final k = _byName(DealKind.values, value.toLowerCase());
      label = switch (k) {
        DealKind.sale => l10n.dealsKindSale,
        DealKind.rent => l10n.dealsKindRent,
        null => null,
      };
    case 'leaseReminderDays':
      final n = int.tryParse(value);
      label = n == null ? null : l10n.leasesReminderValue(n);
    case 'mandateEndDate' || 'leaseStart' || 'leaseEnd':
      final d = DateTime.tryParse(value);
      label = d == null ? null : formatFullDate(d, locale);
    case 'birthday':
      final b = ClientBirthday.parse(value);
      label = b == null ? null : clientBirthdayLabel(b, locale);
    default:
      if (_money.contains(field)) {
        final n = double.tryParse(value);
        label = n == null
            ? null
            : formatMoney(n, AppCurrency.current, AppCurrency.locale);
      } else if (_area.contains(field)) {
        final n = double.tryParse(value);
        label = n == null ? null : l10n.propertiesAreaValue(formatRate(n));
      } else {
        label = value;
      }
  }
  return label ?? unknown;
}

/// One line of an entry: "Created", "Deleted", "Price: $45,000,000 →
/// $42,000,000", or "Description edited" for a field too long to quote.
String changeLineLabel(
    AppLocalizations l10n, RecordChange change, String locale) {
  switch (change.action) {
    case ChangeAction.created:
      return l10n.changeLogCreated;
    case ChangeAction.deleted:
      return l10n.changeLogDeleted;
    case ChangeAction.statusChanged:
    case ChangeAction.priceChanged:
    case ChangeAction.agentChanged:
    case ChangeAction.updated:
      break;
  }
  final field = change.field;
  final known = _fieldLabel(l10n, field);
  if (field == null || known == null) {
    return l10n.changeLogEdited(l10n.changeLogFieldOther);
  }
  final name = known;
  if (_editedOnly.contains(field)) return l10n.changeLogEdited(name);
  return l10n.changeLogChange(
    name,
    changeValueLabel(l10n, change.entityType, field, change.oldValue, locale),
    changeValueLabel(l10n, change.entityType, field, change.newValue, locale),
  );
}

/// Who made a change: their name as it was, or "Automatically" for a change
/// nobody made by hand, such as a lead from the agency's website.
String changeActorLabel(AppLocalizations l10n, ChangeEntry entry) {
  final name = entry.actorName?.trim();
  return name == null || name.isEmpty ? l10n.changeLogAutomatic : name;
}

/// What kind of record an entry in the agency's feed is about.
String changeEntityTypeLabel(AppLocalizations l10n, ChangeEntityType? type) =>
    switch (type) {
      ChangeEntityType.property => l10n.changeLogEntityProperty,
      ChangeEntityType.deal => l10n.changeLogEntityDeal,
      ChangeEntityType.client => l10n.changeLogEntityClient,
      null => l10n.changeLogEntityOther,
    };

/// Where a record in the feed opens, or null for a kind the app does not know.
String? changeEntityLocation(ChangeEntityType? type, int id) => switch (type) {
      ChangeEntityType.property => '/properties/$id',
      ChangeEntityType.deal => '/deals/$id',
      ChangeEntityType.client => '/clients/$id',
      null => null,
    };
