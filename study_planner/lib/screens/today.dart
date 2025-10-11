import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../storage/storage.dart';
import 'add_task.dart';

/// Screen showing today's tasks
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  /// Create state for TodayScreen
  @override
  _TodayScreenState createState() => _TodayScreenState();
}

/// State for TodayScreen
class _TodayScreenState extends State<TodayScreen>
    with SingleTickerProviderStateMixin {
  List<Task> _tasks = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  /// Initialize state
  @override
  void initState() {
    super.initState();
    _loadTodayTasks();
    // Initialize fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  /// Dispose resources
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Generate date key in YYYY-MM-DD format
  String _dateKey(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  /// Load tasks for today
  Future<void> _loadTodayTasks() async {
    final allGrouped = await TaskStorage.loadAllGrouped();
    final todayKey = _dateKey(DateTime.now());
    setState(() {
      _tasks = allGrouped[todayKey] ?? [];
    });
  }

  /// Build UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        backgroundColor: const Color.fromARGB(255, 2, 5, 175),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today_sharp),
            onPressed: _loadTodayTasks,
          ),
        ],
      ),

      /// Body content
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _tasks.isEmpty
            ? const Center(
                child: Text(
                  'No tasks for today',
                  style: TextStyle(
                    color: Color.fromARGB(179, 255, 255, 255),
                    fontSize: 18,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _tasks.length,
                itemBuilder: (context, i) {
                  final t = _tasks[i];
                  return Card(
                    color: const Color.fromARGB(
                      255,
                      49,
                      47,
                      192,
                    )?.withOpacity(0.85),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        t.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: t.description != null
                          ? Text(
                              t.description!,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            )
                          : null,
                      trailing: Text(
                        DateFormat.Hm().format(t.dueDate),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditTaskScreen(task: t),
                          ),
                        );
                        _loadTodayTasks();
                      },
                    ),
                  );
                },
              ),
      ),

      /// Floating action button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 0, 4, 255),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        child: const Icon(Icons.add),

        /// Add new task
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
          _loadTodayTasks();
        },
      ),
    );
  }
}
