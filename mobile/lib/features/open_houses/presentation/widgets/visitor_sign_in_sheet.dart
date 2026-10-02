import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/open_houses/domain/repositories/open_houses_repository.dart';
import 'package:real_estate_crm/features/open_houses/presentation/widgets/open_house_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Fewer digits than this is not a number anybody can be found by; the server
/// draws the same line.
const _minPhoneDigits = 7;

/// The sign-in sheet at the door. It stays open between visitors — "Save and
/// next" clears it and puts the cursor back in the name — so a queue can be
/// signed in without leaving it. Resolves to everyone signed in while it was
/// open, latest first.
Future<List<OpenHouseVisitor>> showVisitorSignInSheet(
  BuildContext context, {
  required int openHouseId,
}) async {
  final l10n = AppLocalizations.of(context);
  final added = <OpenHouseVisitor>[];
  await showAppBottomSheet<void>(
    context,
    title: l10n.openHouseAddVisitor,
    builder: (_) => VisitorSignInForm(
      openHouseId: openHouseId,
      onSignedIn: (v) => added.insert(0, v),
    ),
  );
  return added;
}

class VisitorSignInForm extends StatefulWidget {
  final int openHouseId;
  final ValueChanged<OpenHouseVisitor> onSignedIn;

  const VisitorSignInForm({
    super.key,
    required this.openHouseId,
    required this.onSignedIn,
  });

  @override
  State<VisitorSignInForm> createState() => _VisitorSignInFormState();
}

class _VisitorSignInFormState extends State<VisitorSignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  OpenHouseInterest? _interest;
  bool _saving = false;
  String? _error;

  /// Bumped after each visitor, so the fields are built afresh and the name
  /// takes the cursor again.
  int _round = 0;
  OpenHouseVisitor? _last;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit({required bool next}) async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final note = _noteCtrl.text.trim();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final visitor = await Injector.openHousesRepository.signIn(
        widget.openHouseId,
        VisitorDraft(
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          interest: _interest,
          note: note.isEmpty ? null : note,
        ),
      );
      widget.onSignedIn(visitor);
      if (!mounted) return;
      if (!next) {
        Navigator.pop(context);
        return;
      }
      _nameCtrl.clear();
      _phoneCtrl.clear();
      _noteCtrl.clear();
      setState(() {
        _saving = false;
        _interest = null;
        _last = visitor;
        _round++;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = openHouseFailureLabel(l10n, err);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final last = _last;

    return Form(
      key: _formKey,
      child: Column(
        key: ValueKey('visitor-round-$_round'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (last != null) ...[
            AppCard(
              key: const ValueKey('visitor-last'),
              nested: true,
              radius: AppMetrics.radiusSm,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 18, color: t.statusText(StatusHue.positive)),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      l10n.openHouseSignedIn(last.fullName),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: t.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: StatusChip(
                      label: last.newClient
                          ? l10n.openHouseNewClient
                          : l10n.openHouseKnownClient,
                      hue: last.newClient
                          ? StatusHue.positive
                          : StatusHue.neutral,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          LabelledField(
            label: l10n.openHouseVisitorName,
            required: true,
            child: AppTextField(
              key: const ValueKey('visitor-name'),
              controller: _nameCtrl,
              hint: l10n.openHouseVisitorNameHint,
              autofocus: true,
              textInputAction: TextInputAction.next,
              validator: (v) => v == null || v.trim().isEmpty
                  ? l10n.openHouseVisitorNameRequired
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          LabelledField(
            label: l10n.openHouseVisitorPhone,
            required: true,
            child: AppTextField(
              key: const ValueKey('visitor-phone'),
              controller: _phoneCtrl,
              hint: '+7 700 000 00 00',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(next: true),
              validator: (v) => (v ?? '').replaceAll(RegExp(r'\D'), '').length <
                      _minPhoneDigits
                  ? l10n.openHouseVisitorPhoneInvalid
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          LabelledField(
            label: l10n.openHouseInterestLabel,
            child: FilterPillWrap(pills: [
              for (final interest in OpenHouseInterest.values)
                FilterPill(
                  key: ValueKey('visitor-interest-${interest.name}'),
                  label: openHouseInterestLabel(l10n, interest),
                  selected: _interest == interest,
                  onCard: true,
                  onTap: () => setState(() =>
                      _interest = _interest == interest ? null : interest),
                ),
            ]),
          ),
          const SizedBox(height: 12),
          LabelledField(
            label: l10n.openHouseNoteLabel,
            child: AppTextField(
              key: const ValueKey('visitor-note'),
              controller: _noteCtrl,
              hint: l10n.openHouseVisitorNoteHint,
              maxLines: 3,
              minLines: 1,
              keyboardType: TextInputType.multiline,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              key: const ValueKey('visitor-error'),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: AppFonts.sans,
                  fontSize: 11.5,
                  height: 1.35,
                  color: t.dangerText),
            ),
          ],
          const SizedBox(height: 18),
          AppFilledButton(
            key: const ValueKey('visitor-save-next'),
            label: l10n.openHouseSignInNext,
            loading: _saving,
            onPressed: () => _submit(next: true),
          ),
          const SizedBox(height: 8),
          AppGhostButton(
            key: const ValueKey('visitor-save'),
            label: l10n.openHouseSignIn,
            onPressed: _saving ? null : () => _submit(next: false),
          ),
        ],
      ),
    );
  }
}
