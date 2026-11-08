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

/// The longest title and text the server keeps.
const kTemplateTitleMaxLength = 80;
const kTemplateBodyMaxLength = 1000;

/// A template as the manager wants it saved.
class MessageTemplateDraft {
  final String title;
  final String body;
  const MessageTemplateDraft(this.title, this.body);
}

/// Saves through [onSave], which throws when the save did not go through;
/// the sheet closes only once it has, so a failure keeps what was typed.
Future<void> showMessageTemplateSheet(
  BuildContext context, {
  MessageTemplate? initial,
  required Future<void> Function(MessageTemplateDraft draft) onSave,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppBottomSheet<void>(
    context,
    title: initial == null ? l10n.templatesNew : l10n.templatesEdit,
    builder: (sheet) => MessageTemplateForm(initial: initial, onSave: onSave),
  );
}

class MessageTemplateForm extends StatefulWidget {
  final MessageTemplate? initial;
  final Future<void> Function(MessageTemplateDraft draft) onSave;

  const MessageTemplateForm({super.key, this.initial, required this.onSave});

  @override
  State<MessageTemplateForm> createState() => _MessageTemplateFormState();
}

class _MessageTemplateFormState extends State<MessageTemplateForm> {
  late final _title = TextEditingController(text: widget.initial?.title);
  late final _body = TextEditingController(text: widget.initial?.body);
  bool _saving = false;
  String? _failure;

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

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _failure = null;
    });
    try {
      await widget
          .onSave(MessageTemplateDraft(_title.text.trim(), _body.text.trim()));
      if (mounted) Navigator.pop(context);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failure = apiFailureLabel(
            l10n, err is ApiFailure ? err : ApiFailure.from(err));
      });
    }
  }

  Widget _problem(String text, Key key) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          text,
          key: key,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: AppFonts.sans,
              fontSize: AppType.footnote,
              color: context.tokens.dangerText),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unknown = unknownPlaceholders(_body.text);
    final titleTooLong = _title.text.trim().length > kTemplateTitleMaxLength;
    final bodyTooLong = _body.text.trim().length > kTemplateBodyMaxLength;
    final ready = _title.text.trim().isNotEmpty &&
        _body.text.trim().isNotEmpty &&
        unknown.isEmpty &&
        !titleTooLong &&
        !bodyTooLong;

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
        if (titleTooLong)
          _problem(l10n.templatesTitleTooLong(kTemplateTitleMaxLength),
              const Key('template-title-too-long')),
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
        if (bodyTooLong)
          _problem(l10n.templatesBodyTooLong(kTemplateBodyMaxLength),
              const Key('template-body-too-long')),
        if (unknown.isNotEmpty)
          _problem(l10n.templatesUnknownPlaceholder(unknown.join(', ')),
              const Key('template-unknown')),
        const SizedBox(height: 14),
        EyebrowLabel(l10n.templatesInsert),
        const SizedBox(height: 8),
        FilterPillWrap(pills: [
          for (final name in kTemplatePlaceholders)
            FilterPill(
              key: ValueKey('placeholder-$name'),
              label: placeholderLabel(l10n, name),
              selected: false,
              onCard: true,
              onTap: () => _insert(name),
            ),
        ]),
        if (_failure != null)
          _problem(_failure!, const Key('template-save-failed')),
        const SizedBox(height: 18),
        AppFilledButton(
          key: const Key('template-save'),
          label: l10n.coreSave,
          loading: _saving,
          onPressed: ready && !_saving ? _save : null,
        ),
      ],
    );
  }
}
