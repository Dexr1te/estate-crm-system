import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/utils/clock.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/offers/domain/repositories/offers_repository.dart';
import 'package:real_estate_crm/features/offers/presentation/widgets/offer_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

DateTime _today() {
  final now = AppClock.now();
  return DateTime(now.year, now.month, now.day);
}

/// A typed amount as a number: spaces and thousands commas are dropped, a
/// decimal comma is read as a point. Zero when it is not a number.
double parseOfferAmount(String text) {
  var v = text.trim().replaceAll(RegExp(r'\s'), '');
  if (v.contains(',') && !v.contains('.')) {
    final parts = v.split(',');
    v = parts.length == 2 && parts.last.length <= 2
        ? v.replaceAll(',', '.')
        : v.replaceAll(',', '');
  } else {
    v = v.replaceAll(',', '');
  }
  return double.tryParse(v) ?? 0;
}

/// Records a buyer's offer on [propertyId]. Resolves to what was saved, or
/// null when the sheet was dismissed.
Future<PropertyOffer?> showRecordOfferSheet(BuildContext context,
    {required int propertyId}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<PropertyOffer>(
    context,
    title: l10n.offersRecordTitle,
    builder: (_) => RecordOfferForm(propertyId: propertyId),
  );
}

/// Puts a new figure on the table of [offer]. Resolves to the offer as saved,
/// or null when dismissed.
Future<PropertyOffer?> showCounterOfferSheet(
    BuildContext context, PropertyOffer offer) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<PropertyOffer>(
    context,
    title: l10n.offersCounterTitle,
    builder: (_) => CounterOfferForm(offer: offer),
  );
}

class RecordOfferForm extends StatefulWidget {
  final int propertyId;

  const RecordOfferForm({super.key, required this.propertyId});

  @override
  State<RecordOfferForm> createState() => _RecordOfferFormState();
}

class _RecordOfferFormState extends State<RecordOfferForm> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  PickerItem? _buyer;
  DateTime? _expiresOn;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickBuyer() async {
    final l10n = AppLocalizations.of(context);
    List<ClientResponse> buyers;
    try {
      buyers =
          await Injector.clientsRepository.getClients(type: ClientType.BUYER);
    } catch (err) {
      if (mounted) setState(() => _error = offerFailureLabel(l10n, err));
      return;
    }
    if (!mounted) return;
    final picked = await showEntityPicker(
      context,
      title: l10n.offersPickBuyer,
      items: [
        for (final c in buyers)
          PickerItem(id: c.id, title: c.fullName, subtitle: c.phone),
      ],
      selectedId: _buyer?.id,
      searchHint: l10n.offersSearchBuyers,
      emptyLabel: l10n.offersNoBuyers,
    );
    if (picked != null && mounted) {
      setState(() {
        _buyer = picked;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    final buyer = _buyer;
    final amount = parseOfferAmount(_amount.text);
    if (_saving || buyer == null || amount <= 0) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final saved = await Injector.offersRepository.create(
        widget.propertyId,
        OfferDraft(
          clientId: buyer.id,
          amount: amount,
          expiresOn: _expiresOn,
          note: _note.text,
        ),
      );
      if (mounted) Navigator.pop(context, saved);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = offerFailureLabel(l10n, err);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ready = _buyer != null && parseOfferAmount(_amount.text) > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LabelledField(
          label: l10n.offersBuyer,
          required: true,
          child: PickerField(
            key: const ValueKey('offer-buyer'),
            value: _buyer?.title,
            placeholder: l10n.offersPickBuyer,
            onTap: _pickBuyer,
          ),
        ),
        const SizedBox(height: 14),
        _AmountField(controller: _amount, onChanged: () => setState(() {})),
        const SizedBox(height: 14),
        _ExpiryField(
          value: _expiresOn,
          onChanged: (d) => setState(() => _expiresOn = d),
        ),
        const SizedBox(height: 14),
        _NoteField(controller: _note),
        _ErrorLine(_error),
        const SizedBox(height: 18),
        AppFilledButton(
          key: const ValueKey('offer-save'),
          label: l10n.offersSave,
          loading: _saving,
          onPressed: ready ? _submit : null,
        ),
      ],
    );
  }
}

class CounterOfferForm extends StatefulWidget {
  final PropertyOffer offer;

  const CounterOfferForm({super.key, required this.offer});

  @override
  State<CounterOfferForm> createState() => _CounterOfferFormState();
}

class _CounterOfferFormState extends State<CounterOfferForm> {
  final _amount = TextEditingController();
  final _note = TextEditingController();

  /// Whoever answers is, as a rule, the other side.
  late OfferParty _party = widget.offer.lastParty == OfferParty.buyer
      ? OfferParty.seller
      : OfferParty.buyer;
  late DateTime? _expiresOn = widget.offer.expiresOn;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = parseOfferAmount(_amount.text);
    if (_saving || amount <= 0) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final expires = _expiresOn;
    try {
      final saved = await Injector.offersRepository.counter(
        widget.offer.id,
        CounterDraft(
          amount: amount,
          party: _party,
          expiresOn: expires != null && expires != widget.offer.expiresOn
              ? expires
              : null,
          note: _note.text,
        ),
      );
      if (mounted) Navigator.pop(context, saved);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = offerFailureLabel(l10n, err);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.offersOnTableNow(formatPrice(widget.offer.amount)),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 12.5,
              color: t.textSecondary),
        ),
        const SizedBox(height: 14),
        LabelledField(
          label: l10n.offersCounterFrom,
          child: FilterPillWrap(pills: [
            for (final p in OfferParty.values)
              FilterPill(
                key: ValueKey('offer-party-${p.name}'),
                label: offerPartyLabel(l10n, p),
                selected: _party == p,
                onTap: () => setState(() => _party = p),
              ),
          ]),
        ),
        const SizedBox(height: 14),
        _AmountField(controller: _amount, onChanged: () => setState(() {})),
        const SizedBox(height: 14),
        _ExpiryField(
          value: _expiresOn,
          onChanged: (d) => setState(() => _expiresOn = d),
          clearable: widget.offer.expiresOn == null,
        ),
        const SizedBox(height: 14),
        _NoteField(controller: _note),
        _ErrorLine(_error),
        const SizedBox(height: 18),
        AppFilledButton(
          key: const ValueKey('offer-counter-save'),
          label: l10n.offersSave,
          loading: _saving,
          onPressed: parseOfferAmount(_amount.text) > 0 ? _submit : null,
        ),
      ],
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _AmountField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LabelledField(
      label: l10n.offersAmount,
      required: true,
      child: AppTextField(
        key: const ValueKey('offer-amount'),
        controller: controller,
        hint: l10n.offersAmountHint,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}

class _ExpiryField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  /// A counter can move the deadline but not take it away: the server keeps
  /// the old one when none is sent.
  final bool clearable;

  const _ExpiryField(
      {required this.value, required this.onChanged, this.clearable = true});

  Future<void> _pick(BuildContext context) async {
    final today = _today();
    final current = value;
    final picked = await showDatePicker(
      context: context,
      initialDate: current == null || current.isBefore(today)
          ? today.add(const Duration(days: 3))
          : current,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final v = value;
    return LabelledField(
      label: l10n.offersExpiresOn,
      child: Row(
        children: [
          Expanded(
            child: PickerField(
              key: const ValueKey('offer-expires'),
              value:
                  v == null ? null : offerDateLabel(v, AppClock.now(), locale),
              placeholder: l10n.offersNoDeadline,
              trailingIcon: Icons.calendar_today_outlined,
              onTap: () => _pick(context),
            ),
          ),
          if (v != null && clearable)
            SizedBox(
              width: AppMetrics.minHitTarget,
              height: AppMetrics.minHitTarget,
              child: IconButton(
                key: const ValueKey('offer-expires-clear'),
                padding: EdgeInsets.zero,
                tooltip: l10n.offersNoDeadline,
                onPressed: () => onChanged(null),
                icon: Icon(Icons.close_rounded,
                    size: 18, color: context.tokens.textHint),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LabelledField(
      label: l10n.offersNote,
      child: AppTextField(
        key: const ValueKey('offer-note'),
        controller: controller,
        hint: l10n.offersNoteHint,
        maxLines: 3,
        minLines: 1,
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}

class _ErrorLine extends StatelessWidget {
  final String? error;
  const _ErrorLine(this.error);

  @override
  Widget build(BuildContext context) {
    final e = error;
    if (e == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        e,
        key: const ValueKey('offer-error'),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: AppFonts.sans,
            fontSize: 11.5,
            height: 1.35,
            color: context.tokens.dangerText),
      ),
    );
  }
}
