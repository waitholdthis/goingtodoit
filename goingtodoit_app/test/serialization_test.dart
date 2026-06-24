import 'package:flutter_test/flutter_test.dart';
import 'package:goingtodoit_app/core/task_model.dart';

void main() {
  group('Task JSON serialization', () {
    test('round-trips all fields', () {
      final original = Task(
        id: 'abc',
        title: 'Call mum',
        contactName: 'Mum',
        contactValue: '+15550001',
        type: TaskType.call,
        dueDate: DateTime(2030, 5, 6, 14, 30),
        isCompleted: true,
        isFullForce: true,
        missedCount: 2,
        priority: TaskPriority.critical,
        completedAt: DateTime(2030, 5, 6, 15, 0),
      );

      final restored = Task.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.contactName, original.contactName);
      expect(restored.contactValue, original.contactValue);
      expect(restored.type, original.type);
      expect(restored.dueDate, original.dueDate);
      expect(restored.isCompleted, isTrue);
      expect(restored.isFullForce, isTrue);
      expect(restored.missedCount, 2);
      expect(restored.priority, TaskPriority.critical);
      expect(restored.completedAt, original.completedAt);
    });

    test('null completedAt survives the round-trip', () {
      final t = Task(id: 'x', title: 't', dueDate: DateTime(2030));
      final restored = Task.fromJson(t.toJson());
      expect(restored.completedAt, isNull);
      expect(restored.isCompleted, isFalse);
    });

    test('unknown enum values fall back to safe defaults', () {
      final restored = Task.fromJson({
        'id': 'x',
        'title': 't',
        'type': 'bogus',
        'dueDate': DateTime(2030).toIso8601String(),
        'priority': 'nonsense',
      });
      expect(restored.type, TaskType.general);
      expect(restored.priority, TaskPriority.normal);
    });

    test('missing optional flags default sensibly', () {
      final restored = Task.fromJson({
        'id': 'x',
        'title': 't',
        'type': 'call',
        'dueDate': DateTime(2030).toIso8601String(),
        'priority': 'normal',
      });
      expect(restored.isCompleted, isFalse);
      expect(restored.isFullForce, isFalse);
      expect(restored.missedCount, 0);
    });
  });
}
