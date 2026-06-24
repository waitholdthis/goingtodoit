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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'contactName': contactName,
        'contactValue': contactValue,
        'type': type.name,
        'dueDate': dueDate.toIso8601String(),
        'isCompleted': isCompleted,
        'isFullForce': isFullForce,
        'missedCount': missedCount,
        'priority': priority.name,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        contactName: json['contactName'] as String?,
        contactValue: json['contactValue'] as String?,
        type: TaskType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => TaskType.general,
        ),
        dueDate: DateTime.parse(json['dueDate'] as String),
        isCompleted: json['isCompleted'] as bool? ?? false,
        isFullForce: json['isFullForce'] as bool? ?? false,
        missedCount: json['missedCount'] as int? ?? 0,
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => TaskPriority.normal,
        ),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );

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
