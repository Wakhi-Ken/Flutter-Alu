import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../storage/storage.dart';

/// Service to handle task reminders
class ReminderService {
  static Timer? _timer;
  static final Set<int> _shownTaskIdsThisSession = <int>{};
  static bool _running = false;

  /// Start the reminder service
  static void start(BuildContext context) {
    if (_running) return;
    _running = true;

    // Initial check shortly after startup
    _scheduleTick(context, const Duration(seconds: 3));
    // Periodic checks
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _tick(context);
    });
  }

  /// Stop the reminder service
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    _shownTaskIdsThisSession.clear();
  }

  /// Schedule a tick after a delay
  static void _scheduleTick(BuildContext context, Duration delay) {
    Future.delayed(delay, () => _tick(context));
  }

  /// Check for due tasks and show reminders
  static Future<void> _tick(BuildContext context) async {
    try {
      // Ensure we have a valid context to show dialogs
      if (!(context as dynamic).mounted) return;
      // Check if reminders are enabled
      final prefs = await SharedPreferences.getInstance();
      final remindersEnabled = prefs.getBool('remindersEnabled') ?? true;
      if (!remindersEnabled) return;
      // Load all tasks
      final now = DateTime.now();
      final tasks = await TaskStorage.loadAllTasks();

      // Find the earliest task that is due now or in the past, not already shown
      Task? due;
      for (final t in tasks) {
        final at = t.reminder ?? t.dueDate;
        if (at == null) continue;
        if (t.done) continue;
        if (_shownTaskIdsThisSession.contains(t.id)) continue;
        if (!at.isAfter(now)) {
          due = t;
          break;
        }
      }
      // Show reminder if found
      if (due != null) {
        _shownTaskIdsThisSession.add(due.id);
        if (!(context as dynamic).mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Reminder'),
            content: Text(
              due!.title +
                  (due.description?.isNotEmpty == true
                      ? '\n\n' + due.description!
                      : ''),
            ),
            // Add buttons for snooze and dismiss
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      // Intentionally ignore errors to avoid crashing the app on timer
    }
  }
}
