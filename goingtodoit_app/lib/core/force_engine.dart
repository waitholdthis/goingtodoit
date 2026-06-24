import '../core/task_model.dart';

class ForceEngine {
  /// Returns what action to take when a deadline is reached.
  static DeadlineAction evaluate(Task task) {
    if (task.isCompleted) {
      return DeadlineAction.none;
    }
    if (task.isFullForce) {
      return DeadlineAction.fullForce;
    }
    return DeadlineAction.softNotify;
  }
}

enum DeadlineAction { none, softNotify, fullForce }
