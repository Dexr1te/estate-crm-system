import 'package:real_estate_crm/core/models/models.dart';

abstract class DealCommentsEvent {}

class DealCommentsLoadEvent extends DealCommentsEvent {}

class DealCommentsLoadEarlierEvent extends DealCommentsEvent {}

class DealCommentsSendEvent extends DealCommentsEvent {
  final String body;
  final List<CommentMention> mentions;
  DealCommentsSendEvent(this.body, {this.mentions = const []});
}

class DealCommentsEditEvent extends DealCommentsEvent {
  final DealComment comment;
  final String body;
  final List<CommentMention> mentions;
  DealCommentsEditEvent(this.comment, this.body, {this.mentions = const []});
}

class DealCommentsDeleteEvent extends DealCommentsEvent {
  final DealComment comment;
  DealCommentsDeleteEvent(this.comment);
}
