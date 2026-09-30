import 'package:real_estate_crm/core/bloc/action_outcome.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/core/widgets/messages.dart';

enum MessageTemplatesStatus { loading, loaded, error }

class MessageTemplatesState {
  final MessageTemplatesStatus status;

  /// Oldest first, as the server keeps them and the picker offers them.
  final List<MessageTemplate> templates;

  /// A write is on its way; the editor waits for it.
  final bool saving;
  final ApiFailure? loadFailure;
  final ActionOutcome? outcome;

  const MessageTemplatesState({
    this.status = MessageTemplatesStatus.loading,
    this.templates = const [],
    this.saving = false,
    this.loadFailure,
    this.outcome,
  });

  MessageTemplatesState copyWith({
    MessageTemplatesStatus? status,
    List<MessageTemplate>? templates,
    bool? saving,
    ApiFailure? loadFailure,
    ActionOutcome? outcome,
  }) =>
      MessageTemplatesState(
        status: status ?? this.status,
        templates: templates ?? this.templates,
        saving: saving ?? this.saving,
        loadFailure: loadFailure,
        outcome: outcome,
      );
}

class MessageTemplateSaved with ActionSucceeded {
  @override
  ActionMessage get message => ActionMessage.templateSaved;
}

class MessageTemplateDeleted with ActionSucceeded {
  @override
  ActionMessage get message => ActionMessage.templateDeleted;
}

class MessageTemplateWriteFailed with ActionFailed {
  @override
  final ApiFailure failure;
  MessageTemplateWriteFailed(this.failure);
}
