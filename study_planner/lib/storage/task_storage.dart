import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorage {
  static const String _key = 'tasks_by_date_v1';

  static String _dateKey(DateTime date) =>
      "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  /// Load all tasks grouped by date
  static Future<Map<String, List<Task>>> loadAllGrouped() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return {};

    final decoded = json.decode(data) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(
        key,
        (value as List)
            .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      ),
    );
  }

  /// Save all grouped tasks
  static Future<void> _saveAll(Map<String, List<Task>> groupedTasks) async {
    final prefs = await SharedPreferences.getInstance();
    final map = groupedTasks.map(
      (key, value) => MapEntry(key, value.map((t) => t.toMap()).toList()),
    );
    await prefs.setString(_key, json.encode(map));
  }

  /// Add task
  static Future<void> addTask(Task t) async {
    final all = await loadAllGrouped();
    final key = _dateKey(t.dueDate);
    all.putIfAbsent(key, () => []);
    all[key]!.add(t);
    await _saveAll(all);
  }

  /// Update task
  static Future<void> updateTask(Task t) async {
    final all = await loadAllGrouped();
    // Remove old instance
    for (final k in all.keys) {
      all[k]!.removeWhere((x) => x.id == t.id);
    }
    // Add to new date
    final key = _dateKey(t.dueDate);
    all.putIfAbsent(key, () => []);
    all[key]!.add(t);
    await _saveAll(all);
  }

  /// Delete task
  static Future<void> deleteTask(int id) async {
    final all = await loadAllGrouped();
    for (final k in all.keys) {
      all[k]!.removeWhere((x) => x.id == id);
    }
    await _saveAll(all);
  }

  /// Get all tasks flat
  static Future<List<Task>> loadAllTasks() async {
    final grouped = await loadAllGrouped();
    final tasks = <Task>[];
    for (final list in grouped.values) {
      tasks.addAll(list);
    }
    return tasks;
  }
}
