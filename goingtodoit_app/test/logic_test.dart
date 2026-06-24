import 'package:flutter_test/flutter_test.dart';
import 'package:goingtodoit_app/core/task_model.dart';
import 'package:goingtodoit_app/core/force_engine.dart';
import 'package:goingtodoit_app/core/escalation_rules.dart';

Task _task({bool completed = false, bool fullForce = false, int missed = 0}) =>
    Task(
      id: 't1',
      title: 'Test',
      dueDate: DateTime(2030, 1, 1),
      isCompleted: completed,
      isFullForce: fullForce,
      missedCount: missed,
    );

void main() {
  group('ForceEngine.evaluate', () {
    test('completed task yields no action', () {
      expect(ForceEngine.evaluate(_task(completed: true)), DeadlineAction.none);
    });

    test('full-force task yields fullForce', () {
      expect(
        ForceEngine.evaluate(_task(fullForce: true)),
        DeadlineAction.fullForce,
      );
    });

    test('normal task yields softNotify', () {
      expect(ForceEngine.evaluate(_task()), DeadlineAction.softNotify);
    });
  });

  group('EscalationRules', () {
    test('no misses means level 0', () {
      expect(EscalationRules.escalationLevelForMisses(0), 0);
    });

    test('escalation level is clamped to the max', () {
      expect(
        EscalationRules.escalationLevelForMisses(100),
        EscalationRules.maxEscalationLevels,
      );
    });

    test('archive prompt triggers at 3 misses', () {
      expect(EscalationRules.shouldPromptArchive(_task(missed: 2)), isFalse);
      expect(EscalationRules.shouldPromptArchive(_task(missed: 3)), isTrue);
    });
  });

  group('SnoozeState', () {
    test('credits decrement and gate snoozing', () {
      var s = SnoozeState();
      expect(s.canSnooze, isTrue);
      s = s.useCredit().useCredit().useCredit();
      expect(s.creditsRemaining, 0);
      expect(s.canSnooze, isFalse);
    });
  });

  group('Task', () {
    test('isOverdue reflects past due dates', () {
      final overdue = Task(id: 'x', title: 't', dueDate: DateTime(2000));
      expect(overdue.isOverdue, isTrue);
    });

    test('copyWith overrides only provided fields', () {
      final t = _task();
      final done = t.copyWith(isCompleted: true);
      expect(done.isCompleted, isTrue);
      expect(done.title, t.title);
      expect(done.id, t.id);
    });
  });
}
