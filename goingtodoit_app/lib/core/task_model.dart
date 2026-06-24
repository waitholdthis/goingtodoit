class Task {
  final String id;
  final String title;
  final String? contactName;
  final String? contactValue;
  final TaskType type;
  final DateTime dueDate;
  bool isCompleted;
  final bool isFullForce;
  int missedCount;
  final TaskPriority priority;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.contactName,
    this.contactValue,
    this.type = TaskType.general,
    required this.dueDate,
    this.isCompleted = false,
    this.isFullForce = false,
    this.missedCount = 0,
    this.priority = TaskPriority.normal,
    this.completedAt,
  });

  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dueDate);

  Task copyWith({
    String? id,
    String? title,
    String? contactName,
    String? contactValue,
    TaskType? type,
    DateTime? dueDate,
    bool? isCompleted,
    bool? isFullForce,
    int? missedCount,
    TaskPriority? priority,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      contactName: contactName ?? this.contactName,
      contactValue: contactValue ?? this.contactValue,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isFullForce: isFullForce ?? this.isFullForce,
      missedCount: missedCount ?? this.missedCount,
      priority: priority ?? this.priority,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

enum TaskType { general, call, email, sms, calendar }

enum TaskPriority { low, normal, high, critical }
