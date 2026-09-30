import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_estate_crm/core/network/api_error.dart';
import 'package:real_estate_crm/features/message_templates/domain/repositories/message_templates_repository.dart';
import 'package:real_estate_crm/features/message_templates/presentation/bloc/message_templates_event.dart';
import 'package:real_estate_crm/features/message_templates/presentation/bloc/message_templates_state.dart';

/// The manager's list of the agency's message templates. Unlike the
/// checklist, each template is its own record: a save or a delete goes to the
/// server at once, and the list follows what the server answered.
class MessageTemplatesBloc
    extends Bloc<MessageTemplatesEvent, MessageTemplatesState> {
  final MessageTemplatesRepository _repo;

  MessageTemplatesBloc(this._repo) : super(const MessageTemplatesState()) {
    on<MessageTemplatesLoadEvent>(_onLoad);
    on<MessageTemplatesSaveEvent>(_onSave);
    on<MessageTemplatesDeleteEvent>(_onDelete);
  }

  Future<void> _onLoad(
      MessageTemplatesLoadEvent e, Emitter<MessageTemplatesState> emit) async {
    emit(state.copyWith(status: MessageTemplatesStatus.loading));
    try {
      final templates = await _repo.getTemplates();
      emit(state.copyWith(
          status: MessageTemplatesStatus.loaded, templates: templates));
    } catch (error) {
      emit(state.copyWith(
          status: MessageTemplatesStatus.error,
          loadFailure: ApiFailure.from(error)));
    }
  }

  Future<void> _onSave(
      MessageTemplatesSaveEvent e, Emitter<MessageTemplatesState> emit) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      final id = e.id;
      final saved = id == null
          ? await _repo.createTemplate(title: e.title, body: e.body)
          : await _repo.updateTemplate(id, title: e.title, body: e.body);
      final exists = state.templates.any((t) => t.id == saved.id);
      emit(state.copyWith(
        saving: false,
        templates: exists
            ? [for (final t in state.templates) t.id == saved.id ? saved : t]
            : [...state.templates, saved],
        outcome: MessageTemplateSaved(),
      ));
    } catch (error) {
      emit(state.copyWith(
          saving: false,
          outcome: MessageTemplateWriteFailed(ApiFailure.from(error))));
    }
  }

  Future<void> _onDelete(MessageTemplatesDeleteEvent e,
      Emitter<MessageTemplatesState> emit) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true));
    try {
      await _repo.deleteTemplate(e.id);
      emit(state.copyWith(
        saving: false,
        templates: state.templates.where((t) => t.id != e.id).toList(),
        outcome: MessageTemplateDeleted(),
      ));
    } catch (error) {
      emit(state.copyWith(
          saving: false,
          outcome: MessageTemplateWriteFailed(ApiFailure.from(error))));
    }
  }
}
