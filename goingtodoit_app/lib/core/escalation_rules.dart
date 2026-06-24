import '../core/task_model.dart';

class SnoozeState {
  final int creditsRemaining;
  final DateTime? nextCreditReset;

  SnoozeState({
    this.creditsRemaining = 3,
    this.nextCreditReset,
  });

  bool get canSnooze => creditsRemaining > 0;

  SnoozeState useCredit() {
    return SnoozeState(
      creditsRemaining: creditsRemaining - 1,
      nextCreditReset: nextCreditReset,
    );
  }

  SnoozeState reset() {
    final now = DateTime.now();
    final reset = DateTime(now.year, now.month, now.day + 1);
    return SnoozeState(creditsRemaining: 3, nextCreditReset: reset);
  }
}

class EscalationRules {
  static const int maxEscalationLevels = 3;

  /// Returns 1-based escalation level (1 .. max).
  static int escalationLevelForMisses(int missedCount) {
    if (missedCount <= 0) return 0;
    final level = (missedCount / 2).floor() + 1;
    return level.clamp(1, maxEscalationLevels);
  }

  static bool shouldPromptArchive(Task task) {
    return task.missedCount >= 3;
  }
}
