import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/features/message_templates/domain/template_filler.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// What a placeholder stands for, in the reader's language.
String placeholderLabel(AppLocalizations l10n, String name) => switch (name) {
      'client' => l10n.templatesPlaceholderClient,
      'agent' => l10n.templatesPlaceholderAgent,
      'listing' => l10n.templatesPlaceholderListing,
      'price' => l10n.templatesPlaceholderPrice,
      'address' => l10n.templatesPlaceholderAddress,
      'link' => l10n.templatesPlaceholderLink,
      _ => name,
    };

/// The names in braces in [body] that the app would not know how to fill,
/// as they were typed. The server refuses a template with any of them.
List<String> unknownPlaceholders(String body) => [
      for (final m in RegExp(r'\{([^{}]*)\}').allMatches(body))
        if (!kTemplatePlaceholders.contains(m[1]!.trim().toLowerCase())) m[0]!,
    ];

/// A template as the manager wants it saved.
class MessageTemplateDraft {
  final String title;
  final String body;
  const MessageTemplateDraft(this.title, this.body);
}

Future<MessageTemplateDraft?> showMessageTemplateSheet(
  BuildContext context, {
  MessageTemplate? initial,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<MessageTemplateDraft>(
    context,
    title: initial == null ? l10n.templatesNew : l10n.templatesEdit,
    builder: (sheet) => MessageTemplateForm(
      initial: initial,
      onConfirm: (draft) => Navigator.pop(sheet, draft),
    ),
  );
}

class MessageTemplateForm extends StatefulWidget {
  final MessageTemplate? initial;
  final ValueChanged<MessageTemplateDraft> onConfirm;

  const MessageTemplateForm({super.key, this.initial, required this.onConfirm});

  @override
  State<MessageTemplateForm> createState() => _MessageTemplateFormState();
}

class _MessageTemplateFormState extends State<MessageTemplateForm> {
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _body = TextEditingController(text: widget.initial?.body);

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  /// Puts `{name}` where the cursor is, or at the end when the field has not
  /// been touched yet.
  void _insert(String name) {
    final token = placeholderToken(name);
    final text = _body.text;
    final selection = _body.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    _body.value = TextEditingValue(
      text: text.replaceRange(start, end, token),
      selection: TextSelection.collapsed(offset: start + token.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = context.tokens;
    final unknown = unknownPlaceholders(_body.text);
    final ready = _title.text.trim().isNotEmpty &&
        _body.text.trim().isNotEmpty &&
        unknown.isEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        LabelledField(
          label: l10n.templatesTitleLabel,
          required: true,
          child: AppTextField(
            key: const Key('template-title-field'),
            controller: _title,
            hint: l10n.templatesTitleHint,
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 16),
        LabelledField(
          label: l10n.templatesBodyLabel,
          required: true,
          child: AppTextField(
            key: const Key('template-body-field'),
            controller: _body,
            hint: l10n.templatesBodyHint,
            minLines: 4,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (unknown.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.templatesUnknownPlaceholder(unknown.join(', ')),
            key: const Key('template-unknown'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: AppFonts.sans, fontSize: 12, color: t.dangerText),
          ),
        ],
        const SizedBox(height: 14),
        EyebrowLabel(l10n.templatesInsert),
        const SizedBox(height: 8),
        FilterPillWrap(pills: [
          for (final name in kTemplatePlaceholders)
            FilterPill(
              key: ValueKey('placeholder-$name'),
              label: placeholderLabel(l10n, name),
              selected: false,
              onTap: () => _insert(name),
            ),
        ]),
        const SizedBox(height: 18),
        AppFilledButton(
          key: const Key('template-save'),
          label: l10n.coreSave,
          onPressed: ready
              ? () => widget.onConfirm(
                  MessageTemplateDraft(_title.text.trim(), _body.text.trim()))
              : null,
        ),
      ],
    );
  }
}
