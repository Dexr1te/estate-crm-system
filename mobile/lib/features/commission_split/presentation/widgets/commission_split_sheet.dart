import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/commission_split/domain/commission_split_draft.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Edits [split]: the deal's agent, colleagues and co-brokers, each with a
/// share. Null when dismissed.
Future<CommissionSplitDraft?> showCommissionSplitSheet(
    BuildContext context, CommissionSplit split) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<CommissionSplitDraft>(
    context,
    title: l10n.splitsTitle,
    subtitle: l10n.splitsSheetSubtitle,
    builder: (sheet) => CommissionSplitForm(
      split: split,
      onConfirm: (draft) => Navigator.pop(sheet, draft),
    ),
  );
}

class _Line {
  final CommissionPartyKind kind;
  final int? userId;
  final String name;
  final TextEditingController coBroker;
  final TextEditingController agency;
  final TextEditingController percent;

  _Line({
    required this.kind,
    this.userId,
    this.name = '',
    String coBrokerName = '',
    String agencyName = '',
    String percentText = '',
  })  : coBroker = TextEditingController(text: coBrokerName),
        agency = TextEditingController(text: agencyName),
        percent = TextEditingController(text: percentText);

  bool get isAgent => kind == CommissionPartyKind.AGENT;
  bool get isCoBroker => kind == CommissionPartyKind.CO_BROKER;

  SplitLineDraft get draft => SplitLineDraft(
        kind: kind,
        userId: userId,
        name: isCoBroker ? coBroker.text : name,
        agency: isCoBroker ? agency.text : null,
        percent: parseSplitPercent(percent.text),
      );

  void dispose() {
    coBroker.dispose();
    agency.dispose();
    percent.dispose();
  }
}

class CommissionSplitForm extends StatefulWidget {
  final CommissionSplit split;
  final ValueChanged<CommissionSplitDraft> onConfirm;

  const CommissionSplitForm(
      {super.key, required this.split, required this.onConfirm});

  @override
  State<CommissionSplitForm> createState() => _CommissionSplitFormState();
}

class _CommissionSplitFormState extends State<CommissionSplitForm> {
  late final List<_Line> _lines = [
    for (final s in widget.split.shares)
      _Line(
        kind: s.kind,
        userId: s.userId,
        name: s.name ?? '',
        coBrokerName:
            s.kind == CommissionPartyKind.CO_BROKER ? s.name ?? '' : '',
        agencyName: s.agency ?? '',
        percentText: formatRate(s.percent),
      ),
  ];

  @override
  void dispose() {
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  CommissionSplitDraft get _draft =>
      CommissionSplitDraft([for (final l in _lines) l.draft]);

  List<CommissionColleague> get _available => [
        for (final c in widget.split.colleagues)
          if (!_lines.any((l) => l.userId == c.id)) c,
      ];

  Future<void> _addColleague() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showEntityPicker(
      context,
      title: l10n.splitsPickColleague,
      searchHint: l10n.splitsSearchColleague,
      emptyLabel: l10n.splitsNoColleagues,
      items: [
        for (final c in _available) PickerItem(id: c.id, title: c.fullName),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() => _lines.add(_Line(
        kind: CommissionPartyKind.COLLEAGUE,
        userId: picked.id,
        name: picked.title)));
  }

  void _addCoBroker() =>
      setState(() => _lines.add(_Line(kind: CommissionPartyKind.CO_BROKER)));

  void _remove(_Line line) {
    setState(() => _lines.remove(line));
    WidgetsBinding.instance.addPostFrameCallback((_) => line.dispose());
  }

  /// The agent takes whatever the others leave.
  void _balance() {
    final agent = _lines.firstWhere((l) => l.isAgent);
    final others = _lines
        .where((l) => !l.isAgent)
        .fold(0, (sum, l) => sum + splitCents(l.draft.percent ?? 0));
    setState(() => agent.percent.text = formatRate((10000 - others) / 100));
  }

  void _allToAgent() {
    final agent = _lines.firstWhere((l) => l.isAgent);
    widget.onConfirm(CommissionSplitDraft([
      SplitLineDraft(
          kind: CommissionPartyKind.AGENT,
          userId: agent.userId,
          name: agent.name,
          percent: 100),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final draft = _draft;
    final hasAgent = _lines.any((l) => l.isAgent);
    final othersCents = _lines
        .where((l) => !l.isAgent)
        .fold(0, (sum, l) => sum + splitCents(l.draft.percent ?? 0));
    final full = _lines.length >= kMaxSplitShares;
    final note = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 11.5, color: t.dangerText);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        for (var i = 0; i < _lines.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _LineEditor(
            key: ValueKey('split-line-$i'),
            index: i,
            line: _lines[i],
            onChanged: () => setState(() {}),
            onRemove: _lines[i].isAgent ? null : () => _remove(_lines[i]),
          ),
        ],
        const SizedBox(height: 14),
        AppGhostButton(
          key: const Key('split-add-colleague'),
          label: l10n.splitsAddColleague,
          icon: Icons.person_add_alt_1_outlined,
          height: AppMetrics.buttonHeightInline,
          onPressed: full || _available.isEmpty ? null : _addColleague,
        ),
        const SizedBox(height: 8),
        AppGhostButton(
          key: const Key('split-add-cobroker'),
          label: l10n.splitsAddCoBroker,
          icon: Icons.handshake_outlined,
          height: AppMetrics.buttonHeightInline,
          onPressed: full ? null : _addCoBroker,
        ),
        if (full) ...[
          const SizedBox(height: 6),
          Text(l10n.splitsTooMany,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: note.copyWith(color: t.textHint)),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.splitsTotal(formatRate(draft.total)),
          key: const Key('split-total'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: draft.totalsHundred ? t.textPrimary : t.dangerText),
        ),
        if (!draft.totalsHundred) ...[
          const SizedBox(height: 4),
          Text(l10n.splitsTotalMustBe100,
              key: const Key('split-total-wrong'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: note),
          if (hasAgent && othersCents <= 10000) ...[
            const SizedBox(height: 8),
            AppGhostButton(
              key: const Key('split-balance'),
              label: l10n.splitsBalance,
              height: AppMetrics.buttonHeightInline,
              onPressed: _balance,
            ),
          ],
        ],
        const SizedBox(height: 16),
        AppFilledButton(
          key: const Key('split-save'),
          label: l10n.coreSave,
          onPressed: draft.isValid ? () => widget.onConfirm(_draft) : null,
        ),
        if (widget.split.split && hasAgent) ...[
          const SizedBox(height: 8),
          AppGhostButton(
            key: const Key('split-clear'),
            label: l10n.splitsClear,
            height: AppMetrics.buttonHeightInline,
            onPressed: _allToAgent,
          ),
        ],
      ],
    );
  }
}

class _LineEditor extends StatelessWidget {
  final int index;
  final _Line line;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  const _LineEditor({
    super.key,
    required this.index,
    required this.line,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final draft = line.draft;
    final typed = line.percent.text.trim().isNotEmpty;
    final error = TextStyle(
        fontFamily: AppFonts.sans, fontSize: 11.5, color: t.dangerText);
    final title = switch (line.kind) {
      CommissionPartyKind.CO_BROKER => l10n.splitsCoBroker,
      _ => line.name,
    };
    final subtitle = switch (line.kind) {
      CommissionPartyKind.AGENT => l10n.splitsDealAgent,
      CommissionPartyKind.COLLEAGUE => l10n.splitsColleague,
      CommissionPartyKind.CO_BROKER => null,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.surfaceVariant,
        borderRadius: BorderRadius.circular(AppMetrics.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: AppFonts.sans,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: t.textPrimary)),
                    if (subtitle != null)
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: AppFonts.sans,
                              fontSize: 11.5,
                              color: t.textSecondary)),
                  ],
                ),
              ),
              if (onRemove != null)
                IconButton(
                  key: Key('split-remove-$index'),
                  tooltip: l10n.splitsRemove,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.close_rounded, size: 18, color: t.textHint),
                  onPressed: onRemove,
                ),
            ],
          ),
          if (line.isCoBroker) ...[
            const SizedBox(height: 10),
            LabelledField(
              label: l10n.splitsCoBrokerName,
              required: true,
              child: AppTextField(
                key: Key('split-cobroker-name-$index'),
                controller: line.coBroker,
                hint: l10n.splitsCoBrokerNameHint,
                textInputAction: TextInputAction.next,
                onChanged: (_) => onChanged(),
              ),
            ),
            if (!draft.nameValid && typed) ...[
              const SizedBox(height: 4),
              Text(l10n.splitsCoBrokerNameMissing,
                  maxLines: 2, overflow: TextOverflow.ellipsis, style: error),
            ],
            const SizedBox(height: 10),
            LabelledField(
              label: l10n.splitsCoBrokerAgency,
              child: AppTextField(
                key: Key('split-cobroker-agency-$index'),
                controller: line.agency,
                hint: l10n.splitsCoBrokerAgencyHint,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
          const SizedBox(height: 10),
          LabelledField(
            label: l10n.splitsShare,
            child: AppTextField(
              key: Key('split-percent-$index'),
              controller: line.percent,
              hint: '0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => onChanged(),
            ),
          ),
          if (typed && !draft.percentValid) ...[
            const SizedBox(height: 4),
            Text(l10n.splitsPercentInvalid,
                maxLines: 3, overflow: TextOverflow.ellipsis, style: error),
          ],
        ],
      ),
    );
  }
}
