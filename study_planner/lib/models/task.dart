import 'dart:convert';

/// Model class for Task
class Task {
  final int id; // unique id
  String title;
  String? description;
  DateTime dueDate; // full date-time
  DateTime? reminder; // optional reminder DateTime
  bool done;

  /// Constructor
  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.reminder,
    this.done = false,
  });

  /// Convert Task to/from Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'reminder': reminder?.toIso8601String(),
      'done': done ? 1 : 0,
    };
  }

  /// Create Task from Map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: DateTime.parse(map['dueDate'] as String),
      reminder: map['reminder'] != null
          ? DateTime.parse(map['reminder'] as String)
          : null,
      done: (map['done'] ?? 0) == 1,
    );
  }

  /// Convert Task to/from JSON for easier storage
  String toJson() => json.encode(toMap());
  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));
}
