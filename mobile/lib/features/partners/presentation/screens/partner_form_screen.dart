import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_crm/core/di/injector.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/partners/domain/repositories/partners_repository.dart';
import 'package:real_estate_crm/features/partners/presentation/widgets/partner_labels.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Adds a partner, or changes [partnerId]: who, what they do, how to reach
/// them, and the referral fee — none, a share of the commission or a fixed
/// amount per won deal.
class PartnerFormScreen extends StatefulWidget {
  final int? partnerId;
  const PartnerFormScreen({super.key, this.partnerId});

  bool get isEditing => partnerId != null;

  @override
  State<PartnerFormScreen> createState() => _PartnerFormScreenState();
}

class _PartnerFormScreenState extends State<PartnerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _feeCtrl = TextEditingController();
  PartnerKind _kind = PartnerKind.mortgageBroker;
  ReferralFeeType? _feeType;
  bool _loading = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _load();
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl,
      _companyCtrl,
      _phoneCtrl,
      _emailCtrl,
      _noteCtrl,
      _feeCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final p = await Injector.partnersRepository.getPartner(widget.partnerId!);
      _nameCtrl.text = p.name;
      _companyCtrl.text = p.company ?? '';
      _phoneCtrl.text = p.phone ?? '';
      _emailCtrl.text = p.email ?? '';
      _noteCtrl.text = p.note ?? '';
      _feeCtrl.text = p.feeValue == null ? '' : formatRate(p.feeValue!);
      if (!mounted) return;
      setState(() {
        _kind = p.kind;
        _feeType = p.feeType;
        _loading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = partnerFailureLabel(AppLocalizations.of(context), err);
      });
    }
  }

  double? get _feeValue => double.tryParse(
      _feeCtrl.text.replaceAll(' ', '').replaceAll(',', '.').trim());

  String? _validateFee(String? _) {
    final l10n = AppLocalizations.of(context);
    final value = _feeValue;
    return switch (_feeType) {
      ReferralFeeType.percent when value == null || value <= 0 || value > 100 =>
        l10n.partnersFeeInvalidPercent,
      ReferralFeeType.fixed when value == null || value <= 0 =>
        l10n.partnersFeeInvalidAmount,
      _ => null,
    };
  }

  static String? _text(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final draft = PartnerDraft(
      name: _nameCtrl.text.trim(),
      kind: _kind,
      company: _text(_companyCtrl),
      phone: _text(_phoneCtrl),
      email: _text(_emailCtrl),
      note: _text(_noteCtrl),
      feeType: _feeType,
      feeValue: _feeType == null ? null : _feeValue,
    );
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = Injector.partnersRepository;
      final saved = widget.isEditing
          ? await repo.update(widget.partnerId!, draft)
          : await repo.create(draft);
      if (mounted) context.pop(saved);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = partnerFailureLabel(l10n, err);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    const pad = EdgeInsets.symmetric(horizontal: 15, vertical: 9);

    return Form(
      key: _formKey,
      child: DetailScaffold(
        title: widget.isEditing ? l10n.partnersEdit : l10n.partnersNew,
        bottomAction: _loading
            ? null
            : AppFilledButton(
                key: const ValueKey('partner-save'),
                label: l10n.partnersSave,
                loading: _saving,
                onPressed: _saving ? null : _submit,
              ),
        children: _loading
            ? const [
                ShimmerGroup(child: ShimmerFormCard(fields: 4)),
              ]
            : [
                FormSectionCard(
                  children: [
                    LabelledField(
                      label: l10n.partnersName,
                      required: true,
                      child: AppTextField(
                        key: const ValueKey('partner-name'),
                        controller: _nameCtrl,
                        hint: l10n.partnersNameHint,
                        textInputAction: TextInputAction.next,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? l10n.partnersNameRequired
                            : null,
                      ),
                    ),
                    LabelledField(
                      label: l10n.partnersKind,
                      child: FilterPillWrap(pills: [
                        for (final k in PartnerKind.values)
                          FilterPill(
                            key: ValueKey('partner-kind-${k.name}'),
                            label: partnerKindLabel(l10n, k),
                            selected: _kind == k,
                            onCard: true,
                            padding: pad,
                            onTap: () => setState(() => _kind = k),
                          ),
                      ]),
                    ),
                    LabelledField(
                      label: l10n.partnersCompany,
                      child: AppTextField(
                        key: const ValueKey('partner-company'),
                        controller: _companyCtrl,
                        hint: l10n.partnersCompanyHint,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                FormSectionCard(
                  eyebrow: l10n.partnersContact,
                  children: [
                    LabelledField(
                      label: l10n.partnersPhone,
                      child: AppTextField(
                        key: const ValueKey('partner-phone'),
                        controller: _phoneCtrl,
                        hint: '+7 ___ ___-__-__',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    LabelledField(
                      label: l10n.partnersEmail,
                      child: AppTextField(
                        key: const ValueKey('partner-email'),
                        controller: _emailCtrl,
                        hint: 'name@example.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                FormSectionCard(
                  eyebrow: l10n.partnersFee,
                  children: [
                    Text(
                      l10n.partnersFeeHint,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 12,
                          height: 1.4,
                          color: t.textSecondary),
                    ),
                    FilterPillWrap(pills: [
                      FilterPill(
                        key: const ValueKey('partner-fee-none'),
                        label: l10n.partnersFeeTypeNone,
                        selected: _feeType == null,
                        onCard: true,
                        padding: pad,
                        onTap: () => setState(() => _feeType = null),
                      ),
                      FilterPill(
                        key: const ValueKey('partner-fee-percent'),
                        label: l10n.partnersFeeTypePercent,
                        selected: _feeType == ReferralFeeType.percent,
                        onCard: true,
                        padding: pad,
                        onTap: () =>
                            setState(() => _feeType = ReferralFeeType.percent),
                      ),
                      FilterPill(
                        key: const ValueKey('partner-fee-fixed'),
                        label: l10n.partnersFeeTypeFixed,
                        selected: _feeType == ReferralFeeType.fixed,
                        onCard: true,
                        padding: pad,
                        onTap: () =>
                            setState(() => _feeType = ReferralFeeType.fixed),
                      ),
                    ]),
                    if (_feeType != null)
                      LabelledField(
                        label: _feeType == ReferralFeeType.percent
                            ? l10n.partnersFeeValuePercent
                            : l10n.partnersFeeValueAmount,
                        required: true,
                        child: AppTextField(
                          key: const ValueKey('partner-fee-value'),
                          controller: _feeCtrl,
                          hint: _feeType == ReferralFeeType.percent
                              ? '10'
                              : '150000',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: _validateFee,
                        ),
                      ),
                  ],
                ),
                FormSectionCard(
                  eyebrow: l10n.partnersNote,
                  children: [
                    AppTextField(
                      key: const ValueKey('partner-note'),
                      controller: _noteCtrl,
                      hint: l10n.partnersNoteHint,
                      maxLines: 4,
                      minLines: 2,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
                if (_error != null)
                  Text(
                    _error!,
                    key: const ValueKey('partner-error'),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFonts.sans,
                        fontSize: 11.5,
                        height: 1.35,
                        color: t.dangerText),
                  ),
              ],
      ),
    );
  }
}
