import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/widgets/widgets.dart';
import 'package:real_estate_crm/l10n/app_localizations.dart';

/// Opens the list of colleagues who can be @mentioned and returns the one
/// picked, or null.
typedef MentionPicker = Future<CommentMention?> Function(BuildContext context);

/// Where a comment is written. Typing "@" asks [pickMention] for a colleague
/// and puts "@Name" in the text; the people picked travel with the text.
class DealCommentComposer extends StatefulWidget {
  final bool sending;
  final void Function(String body, List<CommentMention> mentions) onSend;
  final MentionPicker pickMention;
  final DealCommentDraftSlot? draftSlot;

  const DealCommentComposer({
    super.key,
    required this.sending,
    required this.onSend,
    required this.pickMention,
    this.draftSlot,
  });

  @override
  State<DealCommentComposer> createState() => DealCommentComposerState();
}

/// Lets the card hand back the text of a comment that did not go through.
class DealCommentDraftSlot {
  DealCommentComposerState? _state;

  void restore(String body, List<CommentMention> mentions) =>
      _state?.restore(body, mentions);
}

class DealCommentComposerState extends State<DealCommentComposer> {
  final _controller = TextEditingController();
  final List<CommentMention> _mentions = [];
  String _previous = '';
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    widget.draftSlot?._state = this;
    _controller.addListener(_onText);
  }

  @override
  void dispose() {
    if (widget.draftSlot?._state == this) widget.draftSlot?._state = null;
    _controller.dispose();
    super.dispose();
  }

  void restore(String body, List<CommentMention> mentions) {
    if (_controller.text.trim().isNotEmpty) return;
    _mentions
      ..clear()
      ..addAll(mentions);
    _previous = body;
    _controller.value = TextEditingValue(
        text: body, selection: TextSelection.collapsed(offset: body.length));
  }

  void _onText() {
    final text = _controller.text;
    final caret = _controller.selection.baseOffset;
    final typedAt = text.length == _previous.length + 1 &&
        caret > 0 &&
        caret <= text.length &&
        text[caret - 1] == '@' &&
        (caret == 1 || RegExp(r'\s').hasMatch(text[caret - 2]));
    _previous = text;
    setState(() {});
    if (typedAt && !_picking) _pick(caret - 1);
  }

  Future<void> _pick(int at) async {
    _picking = true;
    final picked = await widget.pickMention(context);
    _picking = false;
    if (picked == null || !mounted) return;
    final text = _controller.text;
    if (at >= text.length || text[at] != '@') return;
    final insert = '@${picked.fullName} ';
    final next = text.replaceRange(at, at + 1, insert);
    if (!_mentions.any((m) => m.id == picked.id)) _mentions.add(picked);
    _previous = next;
    _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: at + insert.length));
  }

  void _send() {
    final body = _controller.text.trim();
    if (body.isEmpty || widget.sending) return;
    widget.onSend(body, List.of(_mentions));
    _mentions.clear();
    _previous = '';
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l10n = AppLocalizations.of(context);
    final canSend = _controller.text.trim().isNotEmpty && !widget.sending;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: AppTextField(
            key: const ValueKey('deal-comment-field'),
            controller: _controller,
            hint: l10n.dealsCommentHint,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            minLines: 1,
            maxLines: 5,
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: AppMetrics.minHitTarget,
          height: AppMetrics.minHitTarget,
          child: IconButton(
            key: const ValueKey('deal-comment-send'),
            padding: EdgeInsets.zero,
            tooltip: l10n.dealsCommentSend,
            onPressed: canSend ? _send : null,
            icon: Icon(Icons.send_rounded,
                size: 20, color: canSend ? t.primary : t.textHint),
          ),
        ),
      ],
    );
  }
}
