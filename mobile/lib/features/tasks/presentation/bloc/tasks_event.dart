abstract class TasksEvent {}

class TasksLoadEvent extends TasksEvent {}

class TasksResetEvent extends TasksEvent {}

class TasksCompleteEvent extends TasksEvent {
  final int id;
  TasksCompleteEvent(this.id);
}

class TasksReopenEvent extends TasksEvent {
  final int id;
  TasksReopenEvent(this.id);
}

class TasksDeleteEvent extends TasksEvent {
  final int id;
  TasksDeleteEvent(this.id);
}
